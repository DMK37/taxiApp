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

type RideCompleted struct {
	RideId  uint64 `json:"rideId"`
	EndTime uint64 `json:"endTime"`
}

func NewRideCompleted(parsedABI abi.ABI, vLog types.Log) RideCompleted {
	event := RideCompleted{}
	err := parsedABI.UnpackIntoInterface(&event, "RideCompleted", vLog.Data)
	if err != nil {
		log.Fatalf("Failed to unpack RideCompleted event: %v", err)
	}

	event.RideId = binary.BigEndian.Uint64(vLog.Topics[1].Bytes()[24:])
	event.EndTime = binary.BigEndian.Uint64(vLog.Topics[2].Bytes()[24:])

	return event
}

func HandleRideCompletedEvent(event RideCompleted, firestoreService db.FirestoreService) {

	fmt.Printf("Ride completed: %d, end time: %d\n", event.RideId, event.EndTime)

	err := firestoreService.AddFields(context.Background(), "rides", fmt.Sprintf("%d", event.RideId), []firestore.Update{
		{Path: "endTime", Value: fmt.Sprint(event.EndTime)},
		{Path: "status", Value: "completed"},
	})

	if err != nil {
		log.Fatalf("Failed to add fields to Firestore: %v", err)
	}
}

func RideCompletedHash() common.Hash {
	bytes := []byte("RideCompleted(uint64,uint256)")
	return crypto.Keccak256Hash(bytes)
}
