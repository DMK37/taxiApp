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
	rideId           uint64
	driver           common.Address
	confirmationTime uint64
}

func HandleRideConfirmedEvent(parsedABI abi.ABI, vLog types.Log, firestoreService db.FirestoreService) {
	event := RideConfirmed{}
	err := parsedABI.UnpackIntoInterface(&event, "RideConfirmed", vLog.Data)
	if err != nil {
		log.Fatalf("Failed to unpack RideConfirmed event: %v", err)
	}

	event.rideId = binary.BigEndian.Uint64(vLog.Topics[1].Bytes()[24:])
	event.driver = common.HexToAddress(vLog.Topics[2].Hex())
	event.confirmationTime = binary.BigEndian.Uint64(vLog.Topics[3].Bytes()[24:])

	fmt.Printf("Ride confirmed: %d, driver: %s, confirmation time: %d\n", event.rideId, event.driver.Hex(), event.confirmationTime)

	firestoreService.AddFields(context.Background(), "rides", fmt.Sprintf("%d", event.rideId), []firestore.Update{
		{Path: "driver", Value: event.driver.Hex()},
		{Path: "confirmationTime", Value: event.confirmationTime},
		{Path: "status", Value: "confirmed"},
	})
}

func RideConfirmedHash() common.Hash {
	bytes := []byte("RideConfirmed(uint64,address,uint256)")
	return crypto.Keccak256Hash(bytes)
}
