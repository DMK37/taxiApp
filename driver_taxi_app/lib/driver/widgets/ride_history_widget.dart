import 'package:driver_taxi_app/driver/widgets/ride_tile.dart';
import 'package:driver_taxi_app/firebase/data_providers/ride_dp.dart';
import 'package:flutter/material.dart';
import 'package:shared/models/driver_model.dart';
import 'package:shared/models/ride_history_model.dart';

class RideHistoryWidget extends StatefulWidget {
  RideHistoryWidget({
    Key? key,
    required BuildContext context,
    required this.driver,
  }) : super(key: key);

  final DriverModel driver;

  @override
  State<RideHistoryWidget> createState() => _RideHistoryWidgetState();
}

class _RideHistoryWidgetState extends State<RideHistoryWidget> {
  final RidesDataProvider ridesDataProvider = RidesDataProvider();
  late List<HistoryRide> rides = [];

  @override
  void initState() {
    super.initState();
    _fetchDriverRides();
  }

  _fetchDriverRides() async {
    final fetchedRides = await ridesDataProvider.fetchFinishedRidesByDriver(widget.driver.id);
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