import 'package:firebase_database/firebase_database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DriverLocationDataProvider {
  final db = FirebaseDatabase.instance.ref('drivers');

  Future<void> setDriverCurrenLocation(LatLng driverLocation) async {
    await db.child("driver1").set({
      'latitude': driverLocation.latitude,
      'longtitude': driverLocation.longitude,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Future<void> removeActiveDriver() async {
    await db.child("driver1").remove();
  }
}