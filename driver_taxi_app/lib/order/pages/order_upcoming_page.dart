import 'dart:async';

import 'package:driver_taxi_app/location/cubit/location_cubit.dart';
import 'package:driver_taxi_app/location/cubit/location_state.dart';
import 'package:driver_taxi_app/models/order_message.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared/utils/map_utils.dart';

class OrderUpcomingPage extends StatefulWidget {
  const OrderUpcomingPage({super.key, required this.message});
  final OrderMessageModel message;
  @override
  State<OrderUpcomingPage> createState() => _OrderUpcomingPageState();
}

class _OrderUpcomingPageState extends State<OrderUpcomingPage> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  late DatabaseReference _databaseRef;
  final mapUtils = MapUtils();

  Map<MarkerId, Marker> markers = {};
  Map<PolylineId, Polyline> polylines = {};

  @override
  void initState() {
    super.initState();
    _databaseRef =
        FirebaseDatabase.instance.ref("notifications/${widget.message.client}");
    _listenForNewItems();
    _startLocationUpdates();
  }

  void _listenForNewItems() {
    _databaseRef.onChildChanged.listen((event) {
      final childData = (event.snapshot.value as Map).cast<String, dynamic>();
      final position = LatLng(double.parse(childData['latitude']),
          double.parse(childData['longitude']));
      markers[const MarkerId('client')] = Marker(
        markerId: const MarkerId('client'),
        position: position,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      );
      setState(() {});
    });
  }

  void _startLocationUpdates() {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 50,
    );

    Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position? position) async {
      if (position != null) {
        final ctr = await _controller.future;

        final (polyline, _) = await mapUtils.getPolyline(
            LatLng(position.latitude, position.longitude),
            widget.message.sourceLocation);
        polylines[const PolylineId('route')] = polyline;

        ctr.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
            target: LatLng(position.latitude, position.longitude), zoom: 17)));
        if (mounted) {
          setState(() {});
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.63,
              child: GoogleMap(
                tiltGesturesEnabled: false,
                mapType: MapType.normal,
                onMapCreated: (GoogleMapController controller) async {
                  _controller.complete(controller);
                },
                initialCameraPosition: CameraPosition(
                  target: (context.read<LocationCubit>().state
                          as LocationSuccessState)
                      .location,
                  zoom: 17.0,
                ),
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                markers: Set<Marker>.of(markers.values),
                polylines: Set<Polyline>.of(polylines.values),
              ),
            ),
            Positioned(
              bottom: MediaQuery.of(context).size.height * 0.41,
              right: 16,
              child: SizedBox(
                height: 45,
                width: 45,
                child: FloatingActionButton(
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  onPressed: () async {
                    final location =
                        await context.read<LocationCubit>().getLocation();
                    context
                        .read<LocationCubit>()
                        .goToTheLocation(location.$1, _controller);
                  },
                  child: Icon(
                    Icons.gps_fixed,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
            Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(25.0),
                      topRight: Radius.circular(25.0),
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        'Source arrival',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 25),
                      const Spacer(),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor:
                              Theme.of(context).colorScheme.surface,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 50, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          'Confirm source arrival',
                          style: TextStyle(
                              fontSize: 18,
                              color: Theme.of(context).colorScheme.surface),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
