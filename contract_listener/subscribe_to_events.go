package main

import (
	"context"
	"contract_listener/contract_types"
	"contract_listener/db"
	"log"

	"github.com/ethereum/go-ethereum"
	"github.com/ethereum/go-ethereum/accounts/abi"
	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/core/types"
	"github.com/ethereum/go-ethereum/ethclient"
)

// Subscribe to Contract Events
func subscribeToEvents(client *ethclient.Client, contractABI abi.ABI, contractAddress common.Address, firestoreService db.FirestoreService) {
	query := ethereum.FilterQuery{
		Addresses: []common.Address{contractAddress},
	}

	logs := make(chan types.Log)

	sub, err := client.SubscribeFilterLogs(context.Background(), query, logs)
	if err != nil {
		log.Fatalf("Failed to subscribe to contract logs: %v", err)
	}

	// Event Handling Loop
	for {
		select {
		case err := <-sub.Err():
			log.Fatalf("Subscription error: %v", err)
		case vLog := <-logs:
			handleEvent(contractABI, vLog, firestoreService)
		}
	}
}

// Handle Events
func handleEvent(contractABI abi.ABI, vLog types.Log, firestoreService db.FirestoreService) {
	switch vLog.Topics[0].Hex() {
	case contract_types.RideCreatedHash().Hex():
		contract_types.HandleRideCreatedEvent(contractABI, vLog, firestoreService)
	case contract_types.RideConfirmedHash().Hex():
		contract_types.HandleRideConfirmedEvent(contractABI, vLog, firestoreService)
	case contract_types.RideCancelledHash().Hex():
		contract_types.HandleRideCancelledEvent(contractABI, vLog, firestoreService)
	case contract_types.RideCompletedHash().Hex():
		contract_types.HandleRideCompletedEvent(contractABI, vLog, firestoreService)
	case contract_types.RideStartedHash().Hex():
		contract_types.HandleRideStartedEvent(contractABI, vLog, firestoreService)
	default:
		log.Printf("Unknown event with topic: %s", vLog.Topics[0].Hex())
	}
}