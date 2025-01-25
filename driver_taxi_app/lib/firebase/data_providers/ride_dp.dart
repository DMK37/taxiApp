import 'package:firebase_database/firebase_database.dart';
import 'package:shared/models/ride_history_model.dart';

class RidesDataProvider {
  final DatabaseReference _ridesRef = FirebaseDatabase.instance.ref("rides");
   Future<List<HistoryRide>> fetchFinishedRidesByDriver(String driver) async {
    try {

      final Query query = _ridesRef.orderByChild("driver").equalTo(driver);
      final DataSnapshot snapshot = await query.get();

      if (snapshot.exists) {
        final ridesData = snapshot.value as Map<String, dynamic>;

        return ridesData.entries
            .map((entry) {
              final rideId = entry.key;
              final rideData = entry.value as Map<String, dynamic>;
              return HistoryRide.fromJson(rideId, rideData);
            })
            .where((ride) => ride.status == "finished")
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching finished rides for client "$driver": $e');
      throw Exception('Failed to load finished rides for client');
    }
  }
}