import 'dart:convert';

import 'package:reown_appkit/reown_appkit.dart';
import 'package:shared/repositories/ride_contract/ride_contract_abstract.dart';
import 'package:url_launcher/url_launcher.dart';

class RideContract implements RideContractAbstract {
  @override
  Future<void> cancelRide(ReownAppKitModal modal, int rideId) async {
    await modal.requestWriteContract(
        topic: modal.session!.topic,
        chainId: modal.selectedChain!.chainId,
        deployedContract: deployedContract,
        functionName: "cancelRide",
        transaction: Transaction(
          from: EthereumAddress.fromHex(modal.session!.address!),
        ),
        parameters: [rideId]);
  }

  @override
  Future<void> confirmDestinationArrivalByClient(
      ReownAppKitModal modal, int rideId) async {
    await modal.requestWriteContract(
        topic: modal.session!.topic,
        chainId: modal.selectedChain!.chainId,
        deployedContract: deployedContract,
        functionName: "confirmDestinationArrivalByClient",
        transaction: Transaction(
          from: EthereumAddress.fromHex(modal.session!.address!),
        ),
        parameters: [rideId]);
  }

  @override
  Future<void> confirmDestinationArrivalByDriver(
      ReownAppKitModal modal, int rideId) async {
    await modal.requestWriteContract(
        topic: modal.session!.topic,
        chainId: modal.selectedChain!.chainId,
        deployedContract: deployedContract,
        functionName: "confirmDestinationArrivalByDriver",
        transaction: Transaction(
          from: EthereumAddress.fromHex(modal.session!.address!),
        ),
        parameters: [rideId]);
  }

  @override
  Future<void> confirmRide(ReownAppKitModal modal, int rideId) async {
    await modal.requestWriteContract(
        topic: modal.session!.topic,
        chainId: modal.selectedChain!.chainId,
        deployedContract: deployedContract,
        functionName: "confirmRide",
        transaction: Transaction(
          from: EthereumAddress.fromHex(modal.session!.address!),
        ),
        parameters: [rideId]);
  }

  @override
  Future<void> confirmSourceArrivalByClient(
      ReownAppKitModal modal, int rideId) async {
    await modal.requestWriteContract(
        topic: modal.session!.topic,
        chainId: modal.selectedChain!.chainId,
        deployedContract: deployedContract,
        functionName: "confirmSourceArrivalByClient",
        transaction: Transaction(
          from: EthereumAddress.fromHex(modal.session!.address!),
        ),
        parameters: [rideId]);
  }

  @override
  Future<void> confirmSourceArrivalByDriver(
      ReownAppKitModal modal, int rideId) async {
    await modal.requestWriteContract(
        topic: modal.session!.topic,
        chainId: modal.selectedChain!.chainId,
        deployedContract: deployedContract,
        functionName: "confirmSourceArrivalByDriver",
        transaction: Transaction(
          from: EthereumAddress.fromHex(modal.session!.address!),
        ),
        parameters: [rideId]);
  }

  @override
  Future<bool> createRide(ReownAppKitModal modal, int distance, String source,
      String destination, BigInt price) async {
    if (await canLaunchUrl(Uri.parse("metamask://"))) {
      await launchUrl(Uri.parse("metamask://"));
    } else {
      throw 'Could not launch metamask://';
    }

    final resp = await modal.requestWriteContract(
        topic: modal.session!.topic,
        chainId: modal.selectedChain!.chainId,
        deployedContract: deployedContract,
        functionName: "createRide",
        transaction: Transaction(
          from: EthereumAddress.fromHex(modal.session!.address!),
          value: EtherAmount.inWei(price),
        ),
        parameters: [BigInt.from(distance), source, destination]);

    return resp != null;
  }

  final deployedContract = DeployedContract(
    ContractAbi.fromJson(
      jsonEncode([
        {
          "anonymous": false,
          "inputs": [
            {
              "indexed": true,
              "internalType": "uint64",
              "name": "rideId",
              "type": "uint64"
            }
          ],
          "name": "RideCancelled",
          "type": "event"
        },
        {
          "anonymous": false,
          "inputs": [
            {
              "indexed": true,
              "internalType": "uint64",
              "name": "rideId",
              "type": "uint64"
            },
            {
              "indexed": true,
              "internalType": "uint256",
              "name": "endTime",
              "type": "uint256"
            }
          ],
          "name": "RideCompleted",
          "type": "event"
        },
        {
          "anonymous": false,
          "inputs": [
            {
              "indexed": true,
              "internalType": "uint64",
              "name": "rideId",
              "type": "uint64"
            },
            {
              "indexed": true,
              "internalType": "address",
              "name": "driver",
              "type": "address"
            },
            {
              "indexed": true,
              "internalType": "uint256",
              "name": "confirmationTime",
              "type": "uint256"
            }
          ],
          "name": "RideConfirmed",
          "type": "event"
        },
        {
          "anonymous": false,
          "inputs": [
            {
              "indexed": true,
              "internalType": "uint64",
              "name": "rideId",
              "type": "uint64"
            },
            {
              "indexed": true,
              "internalType": "address",
              "name": "client",
              "type": "address"
            },
            {
              "indexed": true,
              "internalType": "uint256",
              "name": "cost",
              "type": "uint256"
            }
          ],
          "name": "RideCreated",
          "type": "event"
        },
        {
          "anonymous": false,
          "inputs": [
            {
              "indexed": true,
              "internalType": "uint64",
              "name": "rideId",
              "type": "uint64"
            },
            {
              "indexed": true,
              "internalType": "uint256",
              "name": "startTime",
              "type": "uint256"
            }
          ],
          "name": "RideStarted",
          "type": "event"
        },
        {
          "inputs": [
            {"internalType": "uint64", "name": "_rideId", "type": "uint64"}
          ],
          "name": "cancelRide",
          "outputs": [],
          "stateMutability": "nonpayable",
          "type": "function"
        },
        {
          "inputs": [
            {"internalType": "uint64", "name": "_rideId", "type": "uint64"}
          ],
          "name": "confirmDestinationArrivalByClient",
          "outputs": [],
          "stateMutability": "nonpayable",
          "type": "function"
        },
        {
          "inputs": [
            {"internalType": "uint64", "name": "_rideId", "type": "uint64"}
          ],
          "name": "confirmDestinationArrivalByDriver",
          "outputs": [],
          "stateMutability": "nonpayable",
          "type": "function"
        },
        {
          "inputs": [
            {"internalType": "uint64", "name": "_rideId", "type": "uint64"}
          ],
          "name": "confirmRide",
          "outputs": [],
          "stateMutability": "nonpayable",
          "type": "function"
        },
        {
          "inputs": [
            {"internalType": "uint64", "name": "_rideId", "type": "uint64"}
          ],
          "name": "confirmSourceArrivalByClient",
          "outputs": [],
          "stateMutability": "nonpayable",
          "type": "function"
        },
        {
          "inputs": [
            {"internalType": "uint64", "name": "_rideId", "type": "uint64"}
          ],
          "name": "confirmSourceArrivalByDriver",
          "outputs": [],
          "stateMutability": "nonpayable",
          "type": "function"
        },
        {
          "inputs": [
            {"internalType": "uint64", "name": "_distance", "type": "uint64"},
            {"internalType": "string", "name": "_source", "type": "string"},
            {"internalType": "string", "name": "_destination", "type": "string"}
          ],
          "name": "createRide",
          "outputs": [
            {"internalType": "uint64", "name": "", "type": "uint64"}
          ],
          "stateMutability": "payable",
          "type": "function"
        },
        {
          "inputs": [],
          "name": "rideCounter",
          "outputs": [
            {"internalType": "uint64", "name": "", "type": "uint64"}
          ],
          "stateMutability": "view",
          "type": "function"
        },
        {
          "inputs": [
            {"internalType": "uint64", "name": "", "type": "uint64"}
          ],
          "name": "rides",
          "outputs": [
            {
              "internalType": "address payable",
              "name": "client",
              "type": "address"
            },
            {
              "internalType": "address payable",
              "name": "driver",
              "type": "address"
            },
            {"internalType": "uint256", "name": "cost", "type": "uint256"},
            {"internalType": "uint64", "name": "distance", "type": "uint64"},
            {"internalType": "string", "name": "source", "type": "string"},
            {"internalType": "string", "name": "destination", "type": "string"},
            {
              "internalType": "uint256",
              "name": "confirmationTime",
              "type": "uint256"
            },
            {"internalType": "uint256", "name": "startTime", "type": "uint256"},
            {"internalType": "uint256", "name": "endTime", "type": "uint256"},
            {
              "internalType": "enum Ride.RideStatus",
              "name": "status",
              "type": "uint8"
            }
          ],
          "stateMutability": "view",
          "type": "function"
        }
      ]), // ABI object
      'ETH',
    ),
    EthereumAddress.fromHex('0x01fC6D67e0d121e00643e82Ea03bd6206a1bf39a'),
  );
}
