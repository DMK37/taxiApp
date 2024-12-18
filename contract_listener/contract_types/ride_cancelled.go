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

type RideCancelled struct {
	RideId uint64 `json:"rideId"`
}

func NewRideCancelled(parsedABI abi.ABI, vLog types.Log) RideCancelled {
	event := RideCancelled{}
	err := parsedABI.UnpackIntoInterface(&event, "RideCancelled", vLog.Data)
	if err != nil {
		log.Fatalf("Failed to unpack RideCancelled event: %v", err)
	}

	event.RideId = binary.BigEndian.Uint64(vLog.Topics[1].Bytes()[24:])

	return event
}

func HandleRideCancelledEvent(event RideCancelled, firestoreService db.FirestoreService) {

	fmt.Printf("Ride cancelled: %d\n", event.RideId)

	err := firestoreService.AddFields(context.Background(), "rides", fmt.Sprintf("%d", event.RideId), []firestore.Update{
		{Path: "status", Value: "cancelled"},
	})

	if err != nil {
		log.Fatalf("Failed to add fields to Firestore: %v", err)
	}
}

func RideCancelledHash() common.Hash {
	bytes := []byte("RideCancelled(uint64)")
	return crypto.Keccak256Hash(bytes)
}
