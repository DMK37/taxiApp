package server

import (
	"context"
	"fmt"
	"log/slog"
	"order_server/cloud_message"
	"time"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/service/sqs"
	"github.com/aws/aws-sdk-go-v2/service/sqs/types"
)

type Server struct {
	client       SQSClient
	queueURL     string
	cloudMessage cloud_message.FirebaseCloudMessage
}

func NewServer(client SQSClient, queueURL string, cloudMessage cloud_message.FirebaseCloudMessage) *Server {
	return &Server{
		client:       client,
		queueURL:     queueURL,
		cloudMessage: cloudMessage,
	}
}

func (s *Server) Start() {
	for {
		input := &sqs.ReceiveMessageInput{
			QueueUrl:            aws.String(s.queueURL),
			MaxNumberOfMessages: 1,
			WaitTimeSeconds:     10,
		}

		result, err := s.client.ReceiveMessage(context.Background(), input)
		if err != nil {
			slog.Error("could not receive message", "error", err.Error())
			time.Sleep(5 * time.Second) // Wait before retrying
			continue
		}

		for _, message := range result.Messages {

			fmt.Printf("Message received: %s\n", *message.Body)

			// Process the message
			s.processMessage(message)

			// Delete the message after processing
			s.deleteMessage(message.ReceiptHandle)
		}
	}
}

func (s *Server) processMessage(message types.Message) {
	// fetch active drivers

	// pick closest driver to order
	// wait for driver to accept order
	// if yes send message to the
	fmt.Printf("Processing message: %s\n", *message.Body)
}

func (s *Server) deleteMessage(receiptHandle *string) {
	input := &sqs.DeleteMessageInput{
		QueueUrl:      aws.String(s.queueURL),
		ReceiptHandle: receiptHandle,
	}

	_, err := s.client.DeleteMessage(context.Background(), input)
	if err != nil {
		slog.Error("could not delete message", "error", err.Error())
	} else {
		slog.Info("message deleted")
	}
}
