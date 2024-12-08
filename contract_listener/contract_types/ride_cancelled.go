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
	rideId uint64
}

func HandleRideCancelledEvent(parsedABI abi.ABI, vLog types.Log, firestoreService db.FirestoreService) {
	event := RideCancelled{}
	err := parsedABI.UnpackIntoInterface(&event, "RideCancelled", vLog.Data)
	if err != nil {
		log.Fatalf("Failed to unpack RideCancelled event: %v", err)
	}

	event.rideId = binary.BigEndian.Uint64(vLog.Topics[1].Bytes()[24:])

	fmt.Printf("Ride cancelled: %d\n", event.rideId)

	firestoreService.AddFields(context.Background(), "rides", fmt.Sprintf("%d", event.rideId), []firestore.Update{
		{Path: "status", Value: "cancelled"},
	})
}

func RideCancelledHash() common.Hash {
	bytes := []byte("RideCancelled(uint64)")
	return crypto.Keccak256Hash(bytes)
}
