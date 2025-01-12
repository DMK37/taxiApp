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

type RideConfirmed struct {
	RideId           uint64         `json:"rideId"`
	Driver           common.Address `json:"driver"`
	ConfirmationTime uint64         `json:"confirmationTime"`
}

func NewRideConfirmed(parsedABI abi.ABI, vLog types.Log) RideConfirmed {
	event := RideConfirmed{}
	err := parsedABI.UnpackIntoInterface(&event, "RideConfirmed", vLog.Data)
	if err != nil {
		log.Fatalf("Failed to unpack RideConfirmed event: %v", err)
	}

	event.RideId = binary.BigEndian.Uint64(vLog.Topics[1].Bytes()[24:])
	event.Driver = common.HexToAddress(vLog.Topics[2].Hex())
	event.ConfirmationTime = binary.BigEndian.Uint64(vLog.Topics[3].Bytes()[24:])

	return event
}

func HandleRideConfirmedEvent(event RideConfirmed, firestoreService db.FirestoreService, realtimeDatabase db.RealtimeDatabaseService) {

	fmt.Printf("Ride confirmed: %d, driver: %s, confirmation time: %d\n", event.RideId, event.Driver.Hex(), event.ConfirmationTime)

	err := firestoreService.AddFields(context.Background(), "rides", fmt.Sprintf("%d", event.RideId), []firestore.Update{
		{Path: "driver", Value: event.Driver.Hex()},
		{Path: "confirmationTime", Value: fmt.Sprint(event.ConfirmationTime)},
		{Path: "status", Value: "confirmed"},
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
	} {}
	data := doc.Data()
	if client, ok := data["client"].(string); ok {
		ride.client = client
	} else {
		log.Fatalf("Failed to get client from Firestore: %v", err)
	}

	err = realtimeDatabase.PushRideConfirmedNotification(ride.client, event.RideId, event.Driver.Hex())
	if err != nil {
		log.Fatalf("Failed to push ride confirmed notification: %v", err)
	}
}

func RideConfirmedHash() common.Hash {
	bytes := []byte("RideConfirmed(uint64,address,uint256)")
	return crypto.Keccak256Hash(bytes)
}
