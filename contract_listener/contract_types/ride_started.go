package contract_types

import (
	"encoding/binary"
	"fmt"
	"log"

	"github.com/ethereum/go-ethereum/accounts/abi"
	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/core/types"
	"github.com/ethereum/go-ethereum/crypto"
)

type RideStarted struct {
	rideId    uint64
	startTime uint64
}

func HandleRideStartedEvent(parsedABI abi.ABI, vLog types.Log) {
	event := RideStarted{}
	err := parsedABI.UnpackIntoInterface(&event, "RideStarted", vLog.Data)
	if err != nil {
		log.Fatalf("Failed to unpack RideStarted event: %v", err)
	}

	event.rideId = binary.BigEndian.Uint64(vLog.Topics[1].Bytes()[24:])
	event.startTime = binary.BigEndian.Uint64(vLog.Topics[2].Bytes()[24:])

	fmt.Printf("Ride started: %d, start time: %d\n", event.rideId, event.startTime)
}

func RideStartedHash() common.Hash {
	bytes := []byte("RideStarted(uint64,uint256)")
	return crypto.Keccak256Hash(bytes)
}
