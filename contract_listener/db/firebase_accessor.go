package db

import (
	"context"
	"fmt"
	"log"

	"cloud.google.com/go/firestore"
)

type FirestoreService interface {
	AddDocument(ctx context.Context, collection string, key string, data map[string]interface{}) error
	AddFields(ctx context.Context, collection string, key string, updates []firestore.Update) error
	Close() error
}

type FirestoreAccessor struct {
	Client *firestore.Client
}

func NewFirestoreAccessor(projectID string) (*FirestoreAccessor, error) {

	ctx := context.Background()
	client, err := firestore.NewClient(ctx, projectID)
	if err != nil {
		return nil, err
	}

	return &FirestoreAccessor{
		Client: client,
	}, nil
}

func (fa *FirestoreAccessor) AddDocument(ctx context.Context, collection string, key string, data map[string]interface{}) error {

	docRef := fa.Client.Collection(collection).Doc(key)

	// Set the document data
	_, err := docRef.Set(ctx, data)
	if err != nil {
		return fmt.Errorf("failed to add document with key %s: %v", key, err)
	}

	log.Printf("Document with key %s added successfully!", key)
	return nil
}

func (fa *FirestoreAccessor) AddFields(ctx context.Context, collection string, key string, updates []firestore.Update) error {
	docRef := fa.Client.Collection(collection).Doc(key)

	_, err := docRef.Update(ctx, updates)
	if err != nil {
		return fmt.Errorf("failed to update document %s: %v", key, err)
	}

	log.Printf("Fields updated in document %s successfully!", key)
	return nil
}

func (fa *FirestoreAccessor) Close() error {
	return fa.Client.Close()
}
