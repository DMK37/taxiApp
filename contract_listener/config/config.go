package config

import "github.com/ethereum/go-ethereum/common"

var (
	WS_URL                   = "wss://sepolia.infura.io/ws/v3/eb54180721764626b9eea2db4bb7fa9f"
	WS_HARDHAT_URL           = "ws://192.168.18.115:8545"
	HARDHAT_CONTRACT_ADDRESS = common.HexToAddress("0x882cD5bB50caC0c874016a52EC8883459c158318")
	CONTRACT_ADDRESS         = common.HexToAddress("0x9A841D91a524BBc413c688b6aF5BB7bAca0b510f")
	FIREBASE_PROJECT_ID      = "taxiapp-6761d"
	AWS_QUEUE_URL            = "https://sqs.us-east-1.amazonaws.com/703671903373/Order.fifo"
	FIREBASE_JSON_PATH       = "./config/taxiapp-6761d-firebase-adminsdk-4yxbd-536043c9c8.json"
	FIREBASE_DB_URL          = "https://taxiapp-6761d-default-rtdb.europe-west1.firebasedatabase.app"
)
