package contract_types

import (
	"context"
	"encoding/json"
	"fmt"
	"log/slog"
	"math/big"
	"os"
	"strconv"

	"testing"

	cfg "contract_listener/config"
	"contract_listener/db"
	"contract_listener/db/mock"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/sqs"
	"github.com/docker/go-connections/nat"
	"github.com/ethereum/go-ethereum/common"
	"github.com/joho/godotenv"
	"github.com/stretchr/testify/require"
	"github.com/testcontainers/testcontainers-go"
	"github.com/testcontainers/testcontainers-go/modules/gcloud"
	"github.com/testcontainers/testcontainers-go/modules/localstack"
)

func TestIntegrationEventRetrieving(t *testing.T) {
	ctx := context.Background()

	err := godotenv.Load("../.env")
	require.NoError(t, err)
	os.Setenv("GOOGLE_APPLICATION_CREDENTIALS", "../config/taxiapp-6761d-firebase-adminsdk-4yxbd-536043c9c8.json")
	defer os.Unsetenv("GOOGLE_APPLICATION_CREDENTIALS")
	// Start LocalStack container
	localstackContainer, err := localstack.Run(ctx, "localstack/localstack:latest", testcontainers.WithEnv(map[string]string{
		"SERVICES":           "sqs",
		"AWS_DEFAULT_REGION": "us-east-1",
	}))
	defer func() {
		if err := testcontainers.TerminateContainer(localstackContainer); err != nil {
			slog.Error("failed to terminate localstack container", "error", err)
		}
	}()
	require.NoError(t, err)

	mappedPort, err := localstackContainer.MappedPort(ctx, nat.Port("4566/tcp"))
	require.NoError(t, err)

	host, err := localstackContainer.Host(ctx)
	require.NoError(t, err)

	endpoint := fmt.Sprintf("http://%s:%d", host, mappedPort.Int())
	fmt.Println(endpoint)

	client, err := initSQS(endpoint)
	require.NoError(t, err)

	queueName := "test-queue.fifo"
	createQueueOutput, err := client.CreateQueue(ctx, &sqs.CreateQueueInput{
		QueueName: aws.String(queueName),
		Attributes: map[string]string{
			"FifoQueue": "true",
		},
	})
	require.NoError(t, err)
	queueURL := *createQueueOutput.QueueUrl

	// Start Firestore emulator
	firestoreContainer, err := gcloud.RunFirestore(
		ctx,
		"gcr.io/google.com/cloudsdktool/cloud-sdk:367.0.0-emulators",
		gcloud.WithProjectID(cfg.FIREBASE_PROJECT_ID),
	)
	defer func() {
		if err := testcontainers.TerminateContainer(firestoreContainer); err != nil {
			slog.Error("failed to terminate firestore container", "error", err)
		}
	}()
	require.NoError(t, err)
	host, err = firestoreContainer.Host(ctx)
	require.NoError(t, err)

	mappedPort, err = firestoreContainer.MappedPort(ctx, "8080")
	require.NoError(t, err)

	emulatorHost := host + ":" + mappedPort.Port()
	os.Setenv("FIRESTORE_EMULATOR_HOST", emulatorHost)
	defer os.Unsetenv("FIRESTORE_EMULATOR_HOST")
	firestoreService, err := db.NewFirestoreAccessor(cfg.FIREBASE_PROJECT_ID)
	require.NoError(t, err)

	dbClientMock := mock.NewMockRealtimeDatabase()

	firestoreService.AddDocument(ctx, "clients", "0x1234567890123456789012345678901234567890", map[string]interface{}{
		"FirstName": "John",
		"LastName":  "Doe"})
	firestoreService.AddDocument(ctx, "drivers", "0x0987654321098765432109876543210987654321", map[string]interface{}{
		"FirstName": "Jane",
		"LastName":  "Smith"})
	t.Run("Test RideCreated event", func(t *testing.T) {
		// Send a test message
		event := RideCreated{
			RideId: 1,
			Client: common.Address(common.FromHex("0x1234567890123456789012345678901234567890")),
			Cost:   big.NewInt(100),
			Destination: "destination",
			Source: "source",
			SourceLocation: "sourceLocation",
			DestinationLocation: "destinationLocation",
		}
		HandleRideCreatedEvent(event, firestoreService, client, queueURL, dbClientMock)

		// Receive the test message
		receiveMessageOutput, err := client.ReceiveMessage(ctx, &sqs.ReceiveMessageInput{
			QueueUrl:            aws.String(queueURL),
			MaxNumberOfMessages: 1,
			WaitTimeSeconds:     1,
		})
		require.NoError(t, err)

		require.Len(t, receiveMessageOutput.Messages, 1)

		receivedEvent := RideCreated{}

		require.NoError(t, json.Unmarshal([]byte(*receiveMessageOutput.Messages[0].Body), &receivedEvent))

		dbEventSnapshot, err := firestoreService.GetDocument(ctx, "rides", fmt.Sprintf("%d", event.RideId))
		require.NoError(t, err)

		dbEvent := RideCreated{}
		id, err := strconv.ParseUint(dbEventSnapshot.Ref.ID, 10, 64)
		require.NoError(t, err)
		dbEvent.RideId = id
		dbEvent.Client = common.HexToAddress(dbEventSnapshot.Data()["client"].(string))
		dbEvent.Cost = new(big.Int)
		dbEvent.Cost.SetString(dbEventSnapshot.Data()["cost"].(string), 10)
		dbEvent.Destination = dbEventSnapshot.Data()["destination"].(string)
		dbEvent.Source = dbEventSnapshot.Data()["source"].(string)
		dbEvent.SourceLocation = dbEventSnapshot.Data()["sourceLocation"].(string)
		dbEvent.DestinationLocation = dbEventSnapshot.Data()["destinationLocation"].(string)

		require.Equal(t, event.RideId, receivedEvent.RideId)
		require.Equal(t, event.Cost.String(), receivedEvent.Cost.String())
		require.Equal(t, event.Client.Hex(), receivedEvent.Client.Hex())

		require.Equal(t, event.RideId, dbEvent.RideId)
		require.Equal(t, event.Cost.String(), dbEvent.Cost.String())
		require.Equal(t, event.Client.Hex(), dbEvent.Client.Hex())
		require.Equal(t, event.Destination, dbEvent.Destination)
		require.Equal(t, event.Source, dbEvent.Source)
		require.Equal(t, event.SourceLocation, dbEvent.SourceLocation)
		require.Equal(t, event.DestinationLocation, dbEvent.DestinationLocation)
	})

	t.Run("Test RideConfirmed event", func(t *testing.T) {
		createEvent := RideCreated{
			RideId:              1,
			Client:              common.Address(common.FromHex("0x1234567890123456789012345678901234567890")),
			Cost:                big.NewInt(100),
			Source:              "source",
			SourceLocation:      "sourceLocation",
			Destination:         "destination",
			DestinationLocation: "destinationLocation",
		}
		event := RideConfirmed{
			RideId:           1,
			Driver:           common.Address(common.FromHex("0x0987654321098765432109876543210987654321")),
			ConfirmationTime: 1001,
		}
		type Log struct {
			RideId              uint64
			ConfirmationTime    uint64
			Client              common.Address
			Driver              common.Address
			Cost                *big.Int
			Destination         string
			Source              string
			SourceLocation      string
			DestinationLocation string
		}
		expectedLog := Log{
			RideId:           createEvent.RideId,
			ConfirmationTime: event.ConfirmationTime,
			Client:           createEvent.Client,
			Cost:             createEvent.Cost,
			Driver:           event.Driver,
			Destination:      createEvent.Destination,
			Source:           createEvent.Source,
			SourceLocation:   createEvent.SourceLocation,
			DestinationLocation: createEvent.DestinationLocation,
		}

		HandleRideCreatedEvent(createEvent, firestoreService, client, queueURL, dbClientMock)
		HandleRideConfirmedEvent(event, firestoreService, dbClientMock)

		dbEventSnapshot, err := firestoreService.GetDocument(ctx, "rides", fmt.Sprintf("%d", event.RideId))
		require.NoError(t, err)

		dbLog := Log{}
		print(dbEventSnapshot.Data())
		id, err := strconv.ParseUint(dbEventSnapshot.Ref.ID, 10, 64)
		require.NoError(t, err)
		dbLog.RideId = id
		dbLog.Client = common.HexToAddress(dbEventSnapshot.Data()["client"].(string))
		dbLog.Driver = common.HexToAddress(dbEventSnapshot.Data()["driver"].(string))
		dbLog.Cost = new(big.Int)
		dbLog.Cost.SetString(dbEventSnapshot.Data()["cost"].(string), 10)
		confirmationTime, err := strconv.ParseUint(dbEventSnapshot.Data()["confirmationTime"].(string), 10, 64)
		require.NoError(t, err)
		dbLog.ConfirmationTime = confirmationTime
		dbLog.Destination = dbEventSnapshot.Data()["destination"].(string)
		dbLog.Source = dbEventSnapshot.Data()["source"].(string)
		dbLog.SourceLocation = dbEventSnapshot.Data()["sourceLocation"].(string)
		dbLog.DestinationLocation = dbEventSnapshot.Data()["destinationLocation"].(string)


		require.Equal(t, expectedLog, dbLog)
	})

}

func initSQS(endpoint string) (sqsClient *sqs.Client, err error) {
	ctx := context.Background()
	cfg, err := config.LoadDefaultConfig(ctx, config.WithRegion("us-east-1"), config.WithBaseEndpoint(endpoint))
	if err != nil {
		slog.Error("failed to load config for production SQS", "error", err)
		return nil, err
	}

	return sqs.NewFromConfig(cfg), nil
}
