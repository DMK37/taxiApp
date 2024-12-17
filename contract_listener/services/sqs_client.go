package services

import (
	"context"

	"github.com/aws/aws-sdk-go-v2/service/sqs"
)

type SQSClient interface {
	SendMessage(ctx context.Context, input *sqs.SendMessageInput, options ...func(*sqs.Options)) (*sqs.SendMessageOutput, error)
	ReceiveMessage(ctx context.Context, input *sqs.ReceiveMessageInput, options ...func(*sqs.Options)) (*sqs.ReceiveMessageOutput, error)
	DeleteMessage(ctx context.Context, input *sqs.DeleteMessageInput, options ...func(*sqs.Options)) (*sqs.DeleteMessageOutput, error)
}
