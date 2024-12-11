package main

import (
	"context"
	"log/slog"
	"order_server/cloud_message"
	"order_server/server"

	firebase "firebase.google.com/go"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/sqs"
	"github.com/joho/godotenv"
	"google.golang.org/api/option"
)

func main() {
	ctx := context.Background()

	err := godotenv.Load()
	if err != nil {
		slog.Warn("failed to load .env file")
	}
	cfg, err := config.LoadDefaultConfig(ctx, config.WithRegion("us-east-1"))
	if err != nil {
		slog.Error("failed to load config for production SQS", "error", err)
		return
	}

	sqsClient := sqs.NewFromConfig(cfg)
	queueURL := "https://sqs.us-east-1.amazonaws.com/703671903373/Order.fifo"

	opt := option.WithCredentialsFile("./config/taxiapp-6761d-firebase-adminsdk-4yxbd-536043c9c8.json")

	app, err := firebase.NewApp(ctx, nil, opt)
	if err != nil {
		slog.Error("error initializing app", "error", err)
	}

	client, err := app.Messaging(ctx)
	if err != nil {
		slog.Error("error getting messaging client", "error", err)
	}

	firebaseCloudMessage := cloud_message.NewFirebaseCloudMessageService(client)

	server := server.NewServer(sqsClient, queueURL, firebaseCloudMessage)

	server.Start()
}
