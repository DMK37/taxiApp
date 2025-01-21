import 'package:flutter/material.dart';
import 'package:shared/models/client_model.dart';
import 'package:shared/models/ride_history_model.dart';
import 'package:taxiapp/firebase/data_providers/rides_dp.dart';
import 'package:taxiapp/user/widgets/ride_tile.dart';

class RideHistoryWidget extends StatefulWidget {
  const RideHistoryWidget({
    super.key,
    required BuildContext context,
    required this.client,
  });

  final ClientModel client;

  @override
  State<RideHistoryWidget> createState() => _RideHistoryWidgetState();
}

class _RideHistoryWidgetState extends State<RideHistoryWidget> {
  final RidesDataProvider ridesDataProvider = RidesDataProvider();
  late List<HistoryRide> rides = [];

    @override
  void initState() {
    super.initState();
    _fetchClientRides();
  }

  _fetchClientRides() async {
    final fetchedRides = await ridesDataProvider.fetchFinishedRidesByClient(widget.client.id);
    setState(() {
      rides = fetchedRides;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: rides.length,
      itemBuilder: (context, index) {
        final ride = rides[index];
        return RideTile(ride: ride);
      },
    );
  }
}
