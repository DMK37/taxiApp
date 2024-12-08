package contract_types

import (
	"context"
	"contract_listener/db"
	"encoding/binary"
	"fmt"
	"log"
	"math/big"

	"github.com/ethereum/go-ethereum/accounts/abi"
	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/core/types"
	"github.com/ethereum/go-ethereum/crypto"
)

type RideCreated struct {
	rideId uint64
	client common.Address
	cost   *big.Int
}

func HandleRideCreatedEvent(parsedABI abi.ABI, vLog types.Log, firestoreService db.FirestoreService) {
	event := RideCreated{}
	err := parsedABI.UnpackIntoInterface(&event, "RideCreated", vLog.Data)
	if err != nil {
		log.Fatalf("Failed to unpack RideCreated event: %v", err)
	}

	event.rideId = binary.BigEndian.Uint64(vLog.Topics[1].Bytes()[24:])
	event.client = common.HexToAddress(vLog.Topics[2].Hex())
	event.cost = new(big.Int).SetBytes(vLog.Topics[3].Bytes())

	fmt.Printf("Ride created: %d, client: %s, cost: %s\n", event.rideId, event.client.Hex(), event.cost.String())
	firestoreService.AddDocument(context.Background(), "rides", fmt.Sprintf("%d", event.rideId), map[string]interface{}{
		"client": event.client.Hex(),
		"cost":   event.cost.String(),
		"status": "created",
	})
}

func RideCreatedHash() common.Hash {
	bytes := []byte("RideCreated(uint64,address,uint256)")
	return crypto.Keccak256Hash(bytes)
}
