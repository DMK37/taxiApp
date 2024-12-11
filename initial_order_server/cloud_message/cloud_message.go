package cloud_message

import (
	"context"

	"firebase.google.com/go/messaging"
)

type CloudMessage interface {
	Send(ctx context.Context, message *messaging.Message) (string, error)
}