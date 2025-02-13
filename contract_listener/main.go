package main

import (
	"context"
	conf "contract_listener/config"
	"contract_listener/db"
	"contract_listener/server"
	"log/slog"
	"os"
	"strings"

	firebase "firebase.google.com/go/v4"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/sqs"
	"github.com/ethereum/go-ethereum/accounts/abi"
	"github.com/ethereum/go-ethereum/ethclient"
	"github.com/joho/godotenv"
	"google.golang.org/api/option"
)

func main() {

	err := godotenv.Load()
	if err != nil {
		slog.Warn("Failed to load .env file", "error", err)
	}

	firestoreService, err := db.NewFirestoreAccessor(conf.FIREBASE_PROJECT_ID)
	if err != nil {
		slog.Error("Failed to create Firestore Service", "error", err)
	}

	// Connect to Ethereum Node
	client := connectToEthereum(conf.WS_URL)
	defer client.Close()

	slog.Info("Connected to Ethereum Node")

	// Read Contract ABI
	contractABI := readContractABI("abi/abi.json")

	ctx := context.Background()

	cfg, err := config.LoadDefaultConfig(ctx, config.WithRegion("us-east-1"))
	if err != nil {
		slog.Error("failed to load config for production SQS", "error", err)
		return
	}

	sqsClient := sqs.NewFromConfig(cfg)

	opt := option.WithCredentialsFile(conf.FIREBASE_JSON_PATH)
	cnf := &firebase.Config{DatabaseURL: conf.FIREBASE_DB_URL}
	app, err := firebase.NewApp(ctx, cnf, opt)
	if err != nil {
		slog.Error("Failed to initialize app", "error", err)
		return
	}

	dbClient, err := app.Database(ctx)
	if err != nil {
		slog.Error("Failed to initialize database", "error", err)
		return
	}

	rds := db.NewFirebaseRealtimeDatabaseService(dbClient)

	server := server.NewServer(sqsClient, conf.AWS_QUEUE_URL, client,
		firestoreService, contractABI, conf.CONTRACT_ADDRESS, rds)

	server.Start()
}

// Connect to Ethereum Node
func connectToEthereum(url string) *ethclient.Client {
	client, err := ethclient.Dial(url)
	if err != nil {
		slog.Error("Failed to connect to Ethereum Node", "error", err)
	}
	return client
}

// Read Contract ABI
func readContractABI(abiPath string) abi.ABI {
	abiData, err := os.ReadFile(abiPath)
	if err != nil {
		slog.Error("Failed to read ABI file", "error", err)
	}

	contractABI, err := abi.JSON(strings.NewReader(string(abiData)))
	if err != nil {
		slog.Error("Failed to parse ABI", "error", err)
	}

	return contractABI
}
