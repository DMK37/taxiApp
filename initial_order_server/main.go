package main

import (
	"context"
	"log/slog"
	conf "order_server/config"
	"order_server/server"

	firebase "firebase.google.com/go/v4"
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
	queueURL := conf.AWS_QUEUE_URL

	opt := option.WithCredentialsFile(conf.FIREBASE_JSON_PATH)
	cnf := &firebase.Config{DatabaseURL: conf.FIREBASE_DB_URL}
	app, err := firebase.NewApp(ctx, cnf, opt)
	if err != nil {
		slog.Error("error initializing app", "error", err)
		return
	}

	client, err := app.Database(ctx)
	if err != nil {
		slog.Error("error initializing database", "error", err)
		return
	}

	server := server.NewServer(sqsClient, queueURL, client)

	server.Start()
}
