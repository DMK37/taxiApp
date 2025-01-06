package server

import (
	"context"
	"contract_listener/contract_types"
	"contract_listener/db"
	"contract_listener/services"
	"log/slog"

	"github.com/ethereum/go-ethereum"
	"github.com/ethereum/go-ethereum/accounts/abi"
	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/core/types"
	"github.com/ethereum/go-ethereum/ethclient"
)

type Server struct {
	sqsClient        services.SQSClient
	queueURL         string
	ethClient        *ethclient.Client
	firestoreService db.FirestoreService
	realtimeDatabase *db.FirebaseRealtimeDatabaseService
	abi              abi.ABI
	address          common.Address
}

func NewServer(sqsClient services.SQSClient, queueURL string, ethClient *ethclient.Client,
	firestoreService db.FirestoreService, abi abi.ABI, address common.Address, realtimeDatabase *db.FirebaseRealtimeDatabaseService) *Server {
	return &Server{
		sqsClient:        sqsClient,
		queueURL:         queueURL,
		ethClient:        ethClient,
		abi:              abi,
		address:          address,
		firestoreService: firestoreService,
		realtimeDatabase: realtimeDatabase,
	}
}

func (s *Server) Start() {
	query := ethereum.FilterQuery{
		Addresses: []common.Address{s.address},
	}

	logs := make(chan types.Log)

	sub, err := s.ethClient.SubscribeFilterLogs(context.Background(), query, logs)
	if err != nil {
		slog.Error("Failed to subscribe to contract logs", "error", err)
	}

	// Event Handling Loop
	for {
		select {
		case err := <-sub.Err():
			slog.Error("Subscription error", "error", err)
		case vLog := <-logs:
			s.handleEvent(vLog)
		}
	}
}

func (s *Server) handleEvent(vLog types.Log) {
	switch vLog.Topics[0].Hex() {
	case contract_types.RideCreatedHash().Hex():
		createdEvent := contract_types.NewRideCreated(s.abi, vLog)
		contract_types.HandleRideCreatedEvent(createdEvent, s.firestoreService, s.sqsClient, s.queueURL, s.realtimeDatabase)
	case contract_types.RideConfirmedHash().Hex():
		confirmedEvent := contract_types.NewRideConfirmed(s.abi, vLog)
		contract_types.HandleRideConfirmedEvent(confirmedEvent, s.firestoreService)
	case contract_types.RideCancelledHash().Hex():
		cancelledEvent := contract_types.NewRideCancelled(s.abi, vLog)
		contract_types.HandleRideCancelledEvent(cancelledEvent, s.firestoreService)
	case contract_types.RideCompletedHash().Hex():
		completedEvent := contract_types.NewRideCompleted(s.abi, vLog)
		contract_types.HandleRideCompletedEvent(completedEvent, s.firestoreService)
	case contract_types.RideStartedHash().Hex():
		startedEvent := contract_types.NewRideStarted(s.abi, vLog)
		contract_types.HandleRideStartedEvent(startedEvent, s.firestoreService)
	default:
		slog.Error("Unknown event with topic", "topic", vLog.Topics[0].Hex())
	}
}
