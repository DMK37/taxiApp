import 'dart:async';

import 'package:driver_taxi_app/initial_state/cubit/initial_cubit.dart';
import 'package:driver_taxi_app/initial_state/cubit/initial_state.dart';
import 'package:driver_taxi_app/location/cubit/location_cubit.dart';
import 'package:driver_taxi_app/location/cubit/location_state.dart';
import 'package:driver_taxi_app/models/order_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared/utils/map_utils.dart';

class ReceivedMessagePage extends StatefulWidget {
  const ReceivedMessagePage({super.key});

  @override
  State<ReceivedMessagePage> createState() => _ReceivedMessagePageState();
}

class _ReceivedMessagePageState extends State<ReceivedMessagePage> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  final mapUtils = MapUtils();
  late OrderMessageModel message;

  Map<PolylineId, Polyline> polylines = {};
  Map<MarkerId, Marker> markers = {};

  @override
  void initState() {
    super.initState();
    message =
        (context.read<DriverInitCubit>().state as DriverMessagedState).message;
  }

  _addMarker(LatLng position, String id, BitmapDescriptor descriptor) {
    MarkerId markerId = MarkerId(id);
    Marker marker =
        Marker(markerId: markerId, icon: descriptor, position: position);
    markers[markerId] = marker;
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
                  final (polyline, dist) = await mapUtils.getPolyline(
                      message.sourceLocation, message.destinationLocation);

                  polylines[polyline.polylineId] = polyline;
                  setState(() {});
                  print(polyline.points);
                  _addMarker(message.sourceLocation, "Source",
                      BitmapDescriptor.defaultMarker);
                  _addMarker(message.destinationLocation, "Destination",
                      BitmapDescriptor.defaultMarkerWithHue(90));

                  LatLngBounds bounds =
                      mapUtils.calculateBounds(polyline.points);
                  final GoogleMapController ctr = await _controller.future;
                  await ctr
                      .animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
                },
                initialCameraPosition: CameraPosition(
                  target: (context.read<LocationCubit>().state
                          as LocationSuccessState)
                      .location,
                  zoom: 17.0,
                ),
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
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
                        'Received new order',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Expanded(
                        child: const CircularProgressIndicator(),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
