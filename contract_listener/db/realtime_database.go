package db

import (
	"context"
	"time"

	"firebase.google.com/go/v4/db"
)

type RealtimeDatabaseService interface {
	PushRideCreatedNotification(id string, rideId uint64) error
	PushRideConfirmedNotification(id string, rideId uint64, driverId string) error
}

type FirebaseRealtimeDatabaseService struct {
	Client *db.Client
}

func NewFirebaseRealtimeDatabaseService(client *db.Client) *FirebaseRealtimeDatabaseService {
	return &FirebaseRealtimeDatabaseService{
		Client: client,
	}
}

func (rds *FirebaseRealtimeDatabaseService) PushRideCreatedNotification(id string, rideId uint64) error {
	ref := rds.Client.NewRef("notifications/ride_created/" + id)
	if _, err := ref.Push(context.Background(), map[string]interface{}{"id": rideId, "timestamp": time.Now().Unix()}); err != nil {
		return err
	}

	return nil
}

func (rds *FirebaseRealtimeDatabaseService) PushRideConfirmedNotification(id string, rideId uint64, driverId string) error {
	ref := rds.Client.NewRef("notifications/ride_confirmed/" + id)
	if _, err := ref.Push(context.Background(), map[string]interface{}{"id": rideId, "driverId": driverId, "timestamp": time.Now().Unix()}); err != nil {
		return err
	}

	return nil
}
