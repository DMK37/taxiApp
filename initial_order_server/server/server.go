package server

import (
	"context"
	"encoding/json"
	"fmt"
	"log/slog"
	"net/http"
	"order_server/cloud_message"
	"order_server/config"
	"time"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/service/sqs"
	"github.com/aws/aws-sdk-go-v2/service/sqs/types"
)

type Server struct {
	client       SQSClient
	queueURL     string
	cloudMessage cloud_message.FirebaseCloudMessage
}

func NewServer(client SQSClient, queueURL string, cloudMessage cloud_message.FirebaseCloudMessage) *Server {
	return &Server{
		client:       client,
		queueURL:     queueURL,
		cloudMessage: cloudMessage,
	}
}

func (s *Server) Start() {

	for {
		input := &sqs.ReceiveMessageInput{
			QueueUrl:            aws.String(s.queueURL),
			MaxNumberOfMessages: 1,
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

func (s *Server) getRideStatus(rideId string, message types.Message) error {

	resp, err := http.Get(config.BACKEND_URL + "/ride/" + rideId + "/status")
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

	// pick closest drivers to source
	// pick first driver from not sent to driver list
	// send notification to driver
	s.cloudMessage.SendMessage(rideMessage.Client, "token")
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
