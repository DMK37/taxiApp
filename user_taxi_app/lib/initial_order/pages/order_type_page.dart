import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:taxiapp/initial_order/cubit/initial_order_cubit.dart';
import 'package:taxiapp/initial_order/cubit/initial_order_state.dart';
import 'package:taxiapp/location/cubit/location_cubit.dart';
import 'package:taxiapp/location/cubit/location_state.dart';

class OrderTypePage extends StatefulWidget {
  const OrderTypePage({super.key});

  @override
  State<OrderTypePage> createState() => _OrderTypePageState();
}

class _OrderTypePageState extends State<OrderTypePage> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  Map<PolylineId, Polyline> polylines = {};
  Map<MarkerId, Marker> markers = {};

  _addMarker(LatLng position, String id, BitmapDescriptor descriptor) {
    MarkerId markerId = MarkerId(id);
    Marker marker =
        Marker(markerId: markerId, icon: descriptor, position: position);
    markers[markerId] = marker;
  }

  LatLngBounds _calculateBounds(List<LatLng> polylineCoordinates) {
    double southWestLat = polylineCoordinates.first.latitude;
    double southWestLng = polylineCoordinates.first.longitude;
    double northEastLat = polylineCoordinates.first.latitude;
    double northEastLng = polylineCoordinates.first.longitude;

    for (LatLng point in polylineCoordinates) {
      if (point.latitude < southWestLat) southWestLat = point.latitude;
      if (point.longitude < southWestLng) southWestLng = point.longitude;
      if (point.latitude > northEastLat) northEastLat = point.latitude;
      if (point.longitude > northEastLng) northEastLng = point.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(southWestLat, southWestLng),
      northeast: LatLng(northEastLat, northEastLng),
    );
  }

  Future<void> _goToTheLocation(LatLng location) async {
    final GoogleMapController controller = await _controller.future;
    await controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: location, zoom: 17)));
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
                  final source = (context.read<InitialOrderCubit>().state
                          as OrderWithPoints)
                      .source;
                  final destination = (context.read<InitialOrderCubit>().state
                          as OrderWithPoints)
                      .destination;
                  final polyline = await context
                      .read<LocationCubit>()
                      .getPolyline(source, destination);
                  polylines[polyline.polylineId] = polyline;
                  setState(() {});

                  _addMarker(source, "Source", BitmapDescriptor.defaultMarker);
                  _addMarker(destination, "Destination",
                      BitmapDescriptor.defaultMarkerWithHue(90));

                  LatLngBounds bounds = _calculateBounds(polyline.points);
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
                markers: Set<Marker>.of(markers.values),
                polylines: Set<Polyline>.of(polylines.values),
              ),
            ),
            Positioned(
              top: 45,
              left: 16,
              child: SizedBox(
                height: 40,
                width: 40,
                child: FloatingActionButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  onPressed: () {
                    context.read<InitialOrderCubit>().clearPoints();
                  },
                  child: Icon(
                    Icons.arrow_back,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
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
                    _goToTheLocation(location.$1);
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
                      ListTile(
                        leading: const Icon(Icons.directions_car),
                        title: Text('Comfort',
                            style: Theme.of(context).textTheme.titleSmall),
                        subtitle: Text('Affordable, everyday rides',
                            style: Theme.of(context).textTheme.bodyMedium),
                        onTap: () {
                          // Handle UberX selection
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.local_taxi),
                        title: Text('Family',
                            style: Theme.of(context).textTheme.titleSmall),
                        subtitle: Text(
                          'Affordable rides for groups up to 6',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        onTap: () {
                          // Handle UberXL selection
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.directions_car_filled),
                        title: Text('Premium',
                            style: Theme.of(context).textTheme.titleSmall),
                        subtitle: Text('Luxury rides with professional drivers',
                            style: Theme.of(context).textTheme.bodyMedium),
                        onTap: () {
                          // Handle UberBlack selection
                        },
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor:
                              Theme.of(context).colorScheme.surface,
                        ),
                        child: Text(
                          'Pay',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.surface,
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      )
                    ],
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
