import 'dart:async';

import 'package:driver_taxi_app/auth/cubit/auth_cubit.dart';
import 'package:driver_taxi_app/initial_state/cubit/initial_cubit.dart';
import 'package:driver_taxi_app/location/cubit/location_cubit.dart';
import 'package:driver_taxi_app/location/cubit/location_state.dart';
import 'package:driver_taxi_app/models/order_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:reown_appkit/modal/appkit_modal_impl.dart';
import 'package:shared/utils/map_utils.dart';

class ReceivedMessagePage extends StatefulWidget {
  const ReceivedMessagePage({super.key, required this.message});
  final OrderMessageModel message;

  @override
  State<ReceivedMessagePage> createState() => _ReceivedMessagePageState();
}

class _ReceivedMessagePageState extends State<ReceivedMessagePage> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  final mapUtils = MapUtils();
  late double cost;

  late Timer _timer;
  double _progress = 0.0;

  late ReownAppKitModal _appKitModal;

  Map<PolylineId, Polyline> polylines = {};
  Map<MarkerId, Marker> markers = {};

  @override
  void initState() {
    super.initState();
    cost = double.parse(widget.message.cost) / 1000000000000000000;
    final appKit = context.read<DriverAuthCubit>().appKit;
    _appKitModal = ReownAppKitModal(
      context: context,
      appKit: appKit,
    );
    _appKitModal.init().then((value) => setState(() {}));
    _startLoading();
  }

  void _startLoading() {
    const duration = Duration(milliseconds: 100);
    _timer = Timer.periodic(duration, (timer) {
      setState(() {
        _progress += 0.1 / 60;
        if (_progress >= 1.0) {
          _progress = 1.0;
          _timer.cancel();
          context.read<DriverInitCubit>().cancelRide();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();

    super.dispose();
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
                        widget.message.sourceLocation,
                        widget.message.destinationLocation);

                    polylines[polyline.polylineId] = polyline;

                    _addMarker(widget.message.sourceLocation, "Source",
                        BitmapDescriptor.defaultMarker);
                    _addMarker(
                        widget.message.destinationLocation,
                        "Destination",
                        BitmapDescriptor.defaultMarkerWithHue(90));
                    setState(() {});
                    LatLngBounds bounds =
                        mapUtils.calculateBounds(polyline.points);
                    final GoogleMapController ctr = await _controller.future;
                    await ctr.animateCamera(
                        CameraUpdate.newLatLngBounds(bounds, 50));
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
                  polylines: Set<Polyline>.of(polylines.values)),
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
                      const SizedBox(
                        height: 25,
                      ),
                      Text(
                        "Cost: $cost ETH",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 25),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(width: 8),
                          const Icon(Icons.location_on, color: Colors.green),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Pickup: ${widget.message.source}",
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          const SizedBox(width: 8),
                          const Icon(Icons.flag, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Drop-off: ${widget.message.destination}",
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: LinearProgressIndicator(
                          value: _progress,
                          backgroundColor: Colors.grey[300],
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(Colors.blue),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          final res = await context
                              .read<DriverInitCubit>()
                              .confirmRide(_appKitModal, widget.message.rideId,
                                  widget.message);
                          if (res) {
                            // context.go('/order');
                          }
                        },
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
                          'Confirm',
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
