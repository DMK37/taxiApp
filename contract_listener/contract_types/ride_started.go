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

func HandleRideStartedEvent(event RideStarted, firestoreService db.FirestoreService) {

	fmt.Printf("Ride started: %d, start time: %d\n", event.RideId, event.StartTime)

	err := firestoreService.AddFields(context.Background(), "rides", fmt.Sprintf("%d", event.RideId), []firestore.Update{
		{Path: "startTime", Value: fmt.Sprint(event.StartTime)},
		{Path: "status", Value: "started"},
	})
	if err != nil {
		log.Fatalf("Failed to add fields to Firestore: %v", err)
	}
}

func RideStartedHash() common.Hash {
	bytes := []byte("RideStarted(uint64,uint256)")
	return crypto.Keccak256Hash(bytes)
}
