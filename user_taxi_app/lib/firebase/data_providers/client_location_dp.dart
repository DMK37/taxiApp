import 'package:firebase_database/firebase_database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ClientLocationDataProvider {
  final DatabaseReference db;

  ClientLocationDataProvider({required this.db});

  Future<void> setClientCurrenLocation(
      LatLng clientLocation, String clientId) async {
    await db.child(clientId).set({
      'latitude': clientLocation.latitude,
      'longtitude': clientLocation.longitude,
      'timestamp': DateTime.now().microsecondsSinceEpoch / 1000,
    });
  }

  Future<void> removeActiveClient(String clientId) async {
    await db.child(clientId).remove();
  }
}
