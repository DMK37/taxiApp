package cloud_message

import (
	"context"
	"log/slog"

	"firebase.google.com/go/messaging"
)

type FirebaseCloudMessage interface {
	SendMessage(message string, token string) error
}

type FirebaseCloudMessageService struct {
	client CloudMessage
}

func NewFirebaseCloudMessageService(client CloudMessage) *FirebaseCloudMessageService {
	return &FirebaseCloudMessageService{
		client: client,
	}
}

func (f *FirebaseCloudMessageService) SendMessage(message string, token string) error {
	notification := &messaging.Message{
		Notification: &messaging.Notification{
			Title: "New Order",
			Body:  message,
		},
		Token: token,
	}

	response, err := f.client.Send(context.Background(), notification)
	if err != nil {
		slog.Error("Failed to send message", "error", err)
	}

	slog.Info("Successfully sent message", "response", response)
	return nil
}
