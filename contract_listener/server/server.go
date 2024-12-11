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
	abi              abi.ABI
	address          common.Address
}

func NewServer(sqsClient services.SQSClient, queueURL string, ethClient *ethclient.Client,
	firestoreService db.FirestoreService, abi abi.ABI, address common.Address) *Server {
	return &Server{
		sqsClient:        sqsClient,
		queueURL:         queueURL,
		ethClient:        ethClient,
		abi:              abi,
		address:          address,
		firestoreService: firestoreService,
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
		contract_types.HandleRideCreatedEvent(s.abi, vLog, s.firestoreService, s.sqsClient, s.queueURL)
	case contract_types.RideConfirmedHash().Hex():
		contract_types.HandleRideConfirmedEvent(s.abi, vLog, s.firestoreService)
	case contract_types.RideCancelledHash().Hex():
		contract_types.HandleRideCancelledEvent(s.abi, vLog, s.firestoreService)
	case contract_types.RideCompletedHash().Hex():
		contract_types.HandleRideCompletedEvent(s.abi, vLog, s.firestoreService)
	case contract_types.RideStartedHash().Hex():
		contract_types.HandleRideStartedEvent(s.abi, vLog, s.firestoreService)
	default:
		slog.Error("Unknown event with topic", "topic", vLog.Topics[0].Hex())
	}
}
