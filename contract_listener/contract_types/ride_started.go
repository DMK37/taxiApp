package contract_types

import (
	"context"
	"contract_listener/db"
	"encoding/binary"
	"fmt"
	"log"

	"cloud.google.com/go/firestore"
	"github.com/ethereum/go-ethereum/accounts/abi"
	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/core/types"
	"github.com/ethereum/go-ethereum/crypto"
)

type RideStarted struct {
	RideId    uint64 `json:"rideId"`
	StartTime uint64 `json:"startTime"`
}

func NewRideStarted(parsedABI abi.ABI, vLog types.Log) RideStarted {
	event := RideStarted{}
	err := parsedABI.UnpackIntoInterface(&event, "RideStarted", vLog.Data)
	if err != nil {
		log.Fatalf("Failed to unpack RideStarted event: %v", err)
	}

	event.RideId = binary.BigEndian.Uint64(vLog.Topics[1].Bytes()[24:])
	event.StartTime = binary.BigEndian.Uint64(vLog.Topics[2].Bytes()[24:])

	return event
}

func HandleRideStartedEvent(event RideStarted, firestoreService db.FirestoreService, realtimeDatabase db.RealtimeDatabaseService) {

	fmt.Printf("Ride started: %d, start time: %d\n", event.RideId, event.StartTime)

	err := firestoreService.AddFields(context.Background(), "rides", fmt.Sprintf("%d", event.RideId), []firestore.Update{
		{Path: "startTime", Value: fmt.Sprint(event.StartTime)},
		{Path: "status", Value: "started"},
	})
	if err != nil {
		log.Fatalf("Failed to add fields to Firestore: %v", err)
	}

	doc, err := firestoreService.GetDocument(context.Background(), "rides", fmt.Sprintf("%d", event.RideId))
	if err != nil {
		log.Fatalf("Failed to get document from Firestore: %v", err)
	}

	ride := struct {
		client string `firestore:"client"`
		driver string `firestore:"driver"`
	}{}
	data := doc.Data()
	if client, ok := data["client"].(string); ok {
		ride.client = client
	} else {
		log.Fatalf("Failed to get client from Firestore: %v", err)
	}

	if driver, ok := data["driver"].(string); ok {
		ride.driver = driver
	} else {
		log.Fatalf("Failed to get driver from Firestore: %v", err)
	}

	err = realtimeDatabase.PushRideStartedNotification(ride.client, event.RideId)
	if err != nil {
		log.Fatalf("Failed to push ride started notification: %v", err)
	}

	err = realtimeDatabase.PushRideStartedNotification(ride.driver, event.RideId)
	if err != nil {
		log.Fatalf("Failed to push ride started notification: %v", err)
	}
}

func RideStartedHash() common.Hash {
	bytes := []byte("RideStarted(uint64,uint256)")
	return crypto.Keccak256Hash(bytes)
}
