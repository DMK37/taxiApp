package server

import (
	"context"
	"encoding/json"
	"fmt"
	"log/slog"
	"net/http"
	"order_server/config"
	"strconv"
	"strings"
	"time"

	"firebase.google.com/go/v4/db"
	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/service/sqs"
	"github.com/aws/aws-sdk-go-v2/service/sqs/types"
	"github.com/umahmood/haversine"
)

type Server struct {
	client         SQSClient
	queueURL       string
	databaseClient *db.Client
}

func NewServer(client SQSClient, queueURL string, databaseClient *db.Client) *Server {
	return &Server{
		client:         client,
		queueURL:       queueURL,
		databaseClient: databaseClient,
	}
}

func (s *Server) Start() {

	slog.Info("Initial Order Server started")

	for {
		input := &sqs.ReceiveMessageInput{
			QueueUrl:            aws.String(s.queueURL),
			MaxNumberOfMessages: 5,
			WaitTimeSeconds:     10,
		}

		result, err := s.client.ReceiveMessage(context.Background(), input)
		if err != nil {
			slog.Error("could not receive message", "error", err.Error())
			time.Sleep(5 * time.Second) // Wait before retrying
			continue
		}

		for _, message := range result.Messages {
			go func() {
				fmt.Printf("Message received: %s\n", *message.Body)

				// deserialize message
				rideMessage := RideMessage{}
				err := json.Unmarshal([]byte(*message.Body), &rideMessage)
				if err != nil {
					slog.Error("could not deserialize message", "error", err.Error())
					s.deleteMessage(message.ReceiptHandle)
					return
				}

				// get ride status
				err = s.getRideStatus(rideMessage.RideId, message)
				if err != nil {
					return
				}

				// Process the message
				s.processMessage(rideMessage)
			}()

		}
	}
}

func (s *Server) getRideStatus(rideId uint64, message types.Message) error {

	resp, err := http.Get(config.BACKEND_URL + "/ride/" + fmt.Sprint(rideId) + "/status")
	if err != nil {
		slog.Error("could not get ride status", "error", err.Error())
		return err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		slog.Error("ride not found", "rideId", rideId)
		s.deleteMessage(message.ReceiptHandle)
		return fmt.Errorf("ride not found")
	}

	status := struct {
		Status string `json:"status"`
	}{}

	err = json.NewDecoder(resp.Body).Decode(&status)
	if err != nil {
		slog.Error("could not decode ride status", "error", err.Error())
		s.deleteMessage(message.ReceiptHandle)
		return err
	}

	if status.Status != "created" {
		slog.Error("ride already processed", "rideId", rideId)
		s.deleteMessage(message.ReceiptHandle)
		return fmt.Errorf("ride already processed")
	}

	return nil
}

func (s *Server) processMessage(rideMessage RideMessage) {

	ctx := context.Background()
	// pick all drivers from database
	ref := s.databaseClient.NewRef("drivers")

	var rawData map[string]map[string]interface{}

	if err := ref.Get(ctx, &rawData); err != nil {
		slog.Error("could not get drivers from database", "error", err.Error())
		return
	}

	var drivers []DriverInfo
	for id, data := range rawData {
		itemJSON, _ := json.Marshal(data)
		var driver DriverInfo
		json.Unmarshal(itemJSON, &driver)
		driver.DriverId = id
		drivers = append(drivers, driver)
	}

	// remove send to drivers
	ref = s.databaseClient.NewRef("rides/" + fmt.Sprint(rideMessage.RideId) + "/send_to")
	var sendTo []string
	if err := ref.Get(ctx, &sendTo); err != nil {
		slog.Error("could not get send to drivers from database", "error", err.Error())
		return
	}

	// var sendTo []string
	// sendToJSON, _ := json.Marshal(rawData2)
	// json.Unmarshal(sendToJSON, &sendTo)
	fmt.Println(sendTo)
	for _, id := range sendTo {
		for i, driver := range drivers {
			if driver.DriverId == id {
				drivers = append(drivers[:i], drivers[i+1:]...)
				break
			}
		}
	}

	if len(drivers) == 0 {
		slog.Error("no drivers available")
		return
	}

	// pick closest driver
	sourceLat, err := strconv.ParseFloat(strings.Split(rideMessage.SourceLocation, ",")[0], 64)
	if err != nil {
		slog.Error("could not parse source latitude", "error", err.Error())
		return
	}

	sourceLong, err := strconv.ParseFloat(strings.Split(rideMessage.SourceLocation, ",")[1], 64)
	if err != nil {
		slog.Error("could not parse source longitude", "error", err.Error())
		return
	}

	source := haversine.Coord{Lat: sourceLat, Lon: sourceLong}

	var closestDriver DriverInfo
	closestDistance := 1000000000.0
	for _, driver := range drivers {
		driverLoc := haversine.Coord{Lat: driver.Latitude, Lon: driver.Longitude}
		_, km := haversine.Distance(source, driverLoc)
		if km < closestDistance {
			closestDistance = km
			closestDriver = driver
		}
	}
	// send notification to driver
	_, err = s.databaseClient.NewRef("notifications/"+fmt.Sprint(closestDriver.DriverId)).Push(ctx, map[string]string{
		"rideId":              fmt.Sprint(rideMessage.RideId),
		"client":              rideMessage.Client,
		"cost":                fmt.Sprint(rideMessage.Cost),
		"source":              rideMessage.Source,
		"destination":         rideMessage.Destination,
		"sourceLocation":      rideMessage.SourceLocation,
		"destinationLocation": rideMessage.DestinationLocation,
		"validUntil":          time.Now().Add(1 * time.Minute).Format(time.RFC3339),
	})
	if err != nil {
		slog.Error("could not push to database", "error", err.Error())
		return
	}

	// update send to
	sendTo = append(sendTo, closestDriver.DriverId)
	ref = s.databaseClient.NewRef("rides/" + fmt.Sprint(rideMessage.RideId) + "/send_to")
	if err := ref.Set(ctx, sendTo); err != nil {
		slog.Error("could not set send to drivers to database", "error", err.Error())
		return
	}
}

func (s *Server) deleteMessage(receiptHandle *string) {
	input := &sqs.DeleteMessageInput{
		QueueUrl:      aws.String(s.queueURL),
		ReceiptHandle: receiptHandle,
	}

	_, err := s.client.DeleteMessage(context.Background(), input)
	if err != nil {
		slog.Error("could not delete message", "error", err.Error())
	} else {
		slog.Info("message deleted")
	}
}
