package contract_types

import (
	"context"
	"contract_listener/db"
	"contract_listener/services"
	"encoding/binary"
	"encoding/json"
	"fmt"
	"log"
	"math/big"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/service/sqs"
	"github.com/ethereum/go-ethereum/accounts/abi"
	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/core/types"
	"github.com/ethereum/go-ethereum/crypto"
)

type RideCreated struct {
	RideId              uint64         `json:"rideId"`
	Client              common.Address `json:"client"`
	Cost                *big.Int       `json:"cost"`
	Source              string         `json:"source"`
	Destination         string         `json:"destination"`
	SourceLocation      string         `json:"sourceLocation"`
	DestinationLocation string         `json:"destinationLocation"`
}

func (r *RideCreated) UnmarshalJSON(data []byte) error {
	// Define an alias to avoid infinite recursion
	type Alias RideCreated
	aux := &struct {
		Cost string `json:"cost"` // Handle `*big.Int` as a string
		*Alias
	}{
		Alias: (*Alias)(r),
	}

	// Unmarshal into the auxiliary struct
	if err := json.Unmarshal(data, aux); err != nil {
		return err
	}

	// Convert `Cost` from string to *big.Int
	r.Cost = new(big.Int)
	_, ok := r.Cost.SetString(aux.Cost, 10)
	if !ok {
		return fmt.Errorf("invalid cost value: %s", aux.Cost)
	}

	return nil
}

func NewRideCreated(parsedABI abi.ABI, vLog types.Log) RideCreated {
	event := RideCreated{}
	err := parsedABI.UnpackIntoInterface(&event, "RideCreated", vLog.Data)
	if err != nil {
		log.Fatalf("Failed to unpack RideCreated event: %v", err)
	}

	event.RideId = binary.BigEndian.Uint64(vLog.Topics[1].Bytes()[24:])
	event.Client = common.HexToAddress(vLog.Topics[2].Hex())
	event.Cost = new(big.Int).SetBytes(vLog.Topics[3].Bytes())

	return event
}

func (r *RideCreated) ToJSON() string {
	return fmt.Sprintf(`{"rideId":%d,"client":"%s","cost":"%s","source":"%s","destination":"%s","sourceLocation":"%s","destinationLocation":"%s"}`,
		r.RideId, r.Client.Hex(), r.Cost.String(), r.Source, r.Destination, r.SourceLocation, r.DestinationLocation)
}

func HandleRideCreatedEvent(event RideCreated, firestoreService db.FirestoreService, sqsClient services.SQSClient, queueURL string) {

	fmt.Printf("Ride created: %d, client: %s, cost: %s\n", event.RideId, event.Client.Hex(), event.Cost.String())
	firestoreService.AddDocument(context.Background(), "rides", fmt.Sprintf("%d", event.RideId), map[string]interface{}{
		"client":              event.Client.Hex(),
		"cost":                event.Cost.String(),
		"source":              event.Source,
		"destination":         event.Destination,
		"sourceLocation":      event.SourceLocation,
		"destinationLocation": event.DestinationLocation,
		"status":              "created",
	})

	res, err := sqsClient.SendMessage(context.Background(), &sqs.SendMessageInput{
		QueueUrl:               aws.String(queueURL),
		MessageBody:            aws.String(event.ToJSON()),
		MessageGroupId:         aws.String("ride_created"),
		MessageDeduplicationId: aws.String(fmt.Sprintf("%d", event.RideId)),
	})
	if err != nil {
		log.Fatalf("Failed to send message to SQS: %v", err)
	}
	fmt.Printf("Message sent: %s\n", *res.MessageId)
}

func RideCreatedHash() common.Hash {
	bytes := []byte("RideCreated(uint64,address,uint256,string,string,string,string)")
	return crypto.Keccak256Hash(bytes)
}
