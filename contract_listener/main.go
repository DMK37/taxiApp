package main

import (
	"contract_listener/config"
	"log"
	"os"
	"strings"

	"github.com/ethereum/go-ethereum/accounts/abi"
	"github.com/ethereum/go-ethereum/ethclient"
)

func main() {
	// Connect to Ethereum Node
	client := connectToEthereum(config.WS_URL)
	defer client.Close()

	log.Println("Connected to Ethereum node!")

	// Read Contract ABI
	contractABI := readContractABI("abi/abi.json")

	// Subscribe to Contract Events
	subscribeToEvents(client, contractABI, config.CONTRACT_ADDRESS)
}

// Connect to Ethereum Node
func connectToEthereum(url string) *ethclient.Client {
	client, err := ethclient.Dial(url)
	if err != nil {
		log.Fatalf("Failed to connect to Ethereum node: %v", err)
	}
	return client
}

// Read Contract ABI
func readContractABI(abiPath string) abi.ABI {
	abiData, err := os.ReadFile(abiPath)
	if err != nil {
		log.Fatalf("Failed to read ABI file: %v", err)
	}

	contractABI, err := abi.JSON(strings.NewReader(string(abiData)))
	if err != nil {
		log.Fatalf("Failed to parse ABI: %v", err)
	}

	return contractABI
}
