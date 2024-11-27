import 'package:firebase_database/firebase_database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ClientLocationDataProvider {
  final db = FirebaseDatabase.instance.ref('clients');

  Future<void> setClientCurrenLocation(LatLng clientLocation, String clientId) async {
    await db.child(clientId).set({
      'latitude': clientLocation.latitude,
      'longtitude': clientLocation.longitude,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Future<void> removeActiveClient(String clientId) async {
    await db.child(clientId).remove();
  }
}