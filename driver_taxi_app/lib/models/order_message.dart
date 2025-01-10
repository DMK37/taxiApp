import 'package:google_maps_flutter/google_maps_flutter.dart';

class OrderMessageModel {
  final int rideId;
  final String client;
  final String cost;
  final String destination;
  final LatLng destinationLocation;
  final String source;
  final LatLng sourceLocation;
  final int validUntil;

  OrderMessageModel({
    required this.rideId,
    required this.client,
    required this.cost,
    required this.destination,
    required this.destinationLocation,
    required this.source,
    required this.sourceLocation,
    required this.validUntil,
  });

  factory OrderMessageModel.fromMap(Map<String, dynamic> map) {
    final destLocation = (map['destinationLocation'] as String)
        .split(',')
        .map((e) => double.parse(e))
        .toList();
    final sourceLocation = (map['sourceLocation'] as String)
        .split(',')
        .map((e) => double.parse(e))
        .toList();
    return OrderMessageModel(
      rideId: int.parse(map['rideId'] as String),
      client: map['client'] as String,
      cost: map['cost'] as String,
      destination: map['destination'] as String,
      destinationLocation: LatLng(destLocation[0], destLocation[1]),
      source: map['source'] as String,
      sourceLocation: LatLng(sourceLocation[0], sourceLocation[1]),
      validUntil: int.parse(map['validUntil'] as String),
    );
  }
}
