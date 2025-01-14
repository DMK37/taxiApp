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
	t.Run("Test RideCreated event", func(t *testing.T) {
		// Send a test message
		event := RideCreated{
			RideId: 1,
			Client: common.Address(common.FromHex("0x1234567890123456789012345678901234567890")),
			Cost:   big.NewInt(100),
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

		require.Equal(t, event.RideId, receivedEvent.RideId)
		require.Equal(t, event.Cost.String(), receivedEvent.Cost.String())
		require.Equal(t, event.Client.Hex(), receivedEvent.Client.Hex())

		require.Equal(t, event.RideId, dbEvent.RideId)
		require.Equal(t, event.Cost.String(), dbEvent.Cost.String())
		require.Equal(t, event.Client.Hex(), dbEvent.Client.Hex())
	})

	t.Run("Test RideStarted event", func(t *testing.T) {
		createEvent := RideCreated{
			RideId: 1,
			Client: common.Address(common.FromHex("0x1234567890123456789012345678901234567890")),
			Cost:   big.NewInt(100),
		}
		event := RideStarted{
			RideId:    1,
			StartTime: 1001,
		}
		type Log struct {
			RideId    uint64
			StartTime uint64
			Client    common.Address
			Cost      *big.Int
		}
		expectedLog := Log{
			RideId:    createEvent.RideId,
			StartTime: event.StartTime,
			Client:    createEvent.Client,
			Cost:      createEvent.Cost,
		}

		HandleRideCreatedEvent(createEvent, firestoreService, client, queueURL, dbClientMock)
		HandleRideStartedEvent(event, firestoreService, dbClientMock)

		dbEventSnapshot, err := firestoreService.GetDocument(ctx, "rides", fmt.Sprintf("%d", event.RideId))
		require.NoError(t, err)

		dbLog := Log{}
		print(dbEventSnapshot.Data())
		id, err := strconv.ParseUint(dbEventSnapshot.Ref.ID, 10, 64)
		require.NoError(t, err)
		dbLog.RideId = id
		dbLog.Client = common.HexToAddress(dbEventSnapshot.Data()["client"].(string))
		dbLog.Cost = new(big.Int)
		dbLog.Cost.SetString(dbEventSnapshot.Data()["cost"].(string), 10)
		startTime, err := strconv.ParseUint(dbEventSnapshot.Data()["startTime"].(string), 10, 64)
		require.NoError(t, err)
		dbLog.StartTime = startTime

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
