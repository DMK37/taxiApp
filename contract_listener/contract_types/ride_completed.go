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
	rideId  uint64
	endTime uint64
}

func HandleRideCompletedEvent(parsedABI abi.ABI, vLog types.Log, firestoreService db.FirestoreService) {
	event := RideCompleted{}
	err := parsedABI.UnpackIntoInterface(&event, "RideCompleted", vLog.Data)
	if err != nil {
		log.Fatalf("Failed to unpack RideCompleted event: %v", err)
	}

	event.rideId = binary.BigEndian.Uint64(vLog.Topics[1].Bytes()[24:])
	event.endTime = binary.BigEndian.Uint64(vLog.Topics[2].Bytes()[24:])

	fmt.Printf("Ride completed: %d, end time: %d\n", event.rideId, event.endTime)

	firestoreService.AddFields(context.Background(), "rides", fmt.Sprintf("%d", event.rideId), []firestore.Update{
		{Path: "endTime", Value: event.endTime},
		{Path: "status", Value: "completed"},
	})
}

func RideCompletedHash() common.Hash {
	bytes := []byte("RideCompleted(uint64,uint256)")
	return crypto.Keccak256Hash(bytes)
}
