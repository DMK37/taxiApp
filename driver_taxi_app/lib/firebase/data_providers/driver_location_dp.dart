import 'package:firebase_database/firebase_database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DriverLocationDataProvider {
  final DatabaseReference db;

  DriverLocationDataProvider({required this.db});

  Future<void> setDriverCurrenLocation(
      LatLng driverLocation, String driverId) async {
    await db.child(driverId).set({
      'latitude': driverLocation.latitude,
      'longitude': driverLocation.longitude,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Future<void> removeActiveDriver(String driverId) async {
    await db.child(driverId).remove();
  }
}
