import 'package:shared/models/ride_history_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RidesDataProvider {
  final CollectionReference _ridesCollection =
      FirebaseFirestore.instance.collection("rides");

  Future<List<HistoryRide>> fetchFinishedRidesByClient(String client) async {
    try {
      final QuerySnapshot querySnapshot = await _ridesCollection
          .where("client", isEqualTo: client)
          .where("status", isEqualTo: "finished")
          .get();

      return querySnapshot.docs.map((doc) {
        final rideId = doc.id;
        final rideData = doc.data() as Map<String, dynamic>;
        return HistoryRide.fromJson(rideId, rideData);
      }).toList();
    } catch (e) {
      print('Error fetching finished rides for client "$client": $e');
      throw Exception('Failed to load finished rides for client');
    }
  }
}
