import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:reown_appkit/modal/appkit_modal_impl.dart';
import 'package:shared/utils/map_utils.dart';
import 'package:taxiapp/auth/cubit/auth_cubit.dart';
import 'package:taxiapp/auth/cubit/auth_state.dart';
import 'package:taxiapp/initial_order/cubit/initial_order_cubit.dart';
import 'package:taxiapp/initial_order/cubit/initial_order_state.dart';
import 'package:taxiapp/location/cubit/location_cubit.dart';
import 'package:taxiapp/location/cubit/location_state.dart';
import 'package:taxiapp/order/cubit/order_cubit.dart';

class InProgressPage extends StatefulWidget {
  final int rideId;
  const InProgressPage({super.key, required this.rideId});

  @override
  State<InProgressPage> createState() => _InProgressPageState();
}

class _InProgressPageState extends State<InProgressPage> {
  final _controller = Completer<GoogleMapController>();
  final mapUtils = MapUtils();
  final initTime = DateTime.now().millisecondsSinceEpoch / 1000;
  late ReownAppKitModal _appKitModal;
  Map<PolylineId, Polyline> polylines = {};
  Map<MarkerId, Marker> markers = {};
  DatabaseReference? _databaseRef;
  StreamSubscription? _subscrition;

  @override
  void initState() {
    super.initState();
    _appKitModal = ReownAppKitModal(
      context: context,
      appKit: context.read<AuthCubit>().appKit,
    );
    _appKitModal.init();
    _databaseRef = FirebaseDatabase.instance.ref(
        "notifications/ride_completed/${(context.read<AuthCubit>().state as AuthenticatedState).user.id}");
    _completedListener();
  }

    void _completedListener() {
    _subscrition = _databaseRef?.onChildAdded.listen((event) {
      final childData = (event.snapshot.value as Map).cast<String, dynamic>();
      final int time = childData['timestamp'];
      if (initTime < time && childData['rideId'] == widget.rideId) {
        context.read<OrderCubit>().completedOrder();
      }
    });
  }

  @override
  void dispose() {
    _subscrition?.cancel();
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
                  final source = (context.read<InitialOrderCubit>().state
                          as OrderWithPoints)
                      .source;
                  final destination = (context.read<InitialOrderCubit>().state
                          as OrderWithPoints)
                      .destination;
                  final (polyline, _) =
                      await mapUtils.getPolyline(source, destination);
                  polylines[const PolylineId('polyline')] = polyline;
                  _addMarker(source, "Source", BitmapDescriptor.defaultMarker);
                  _addMarker(destination, "Destination",
                      BitmapDescriptor.defaultMarkerWithHue(90));
                  setState(() {});
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
                    mapUtils.goToTheLocation(location.$1, _controller);
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
                      const SizedBox(height: 20),
                      Text(
                        'Ride in Progress',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const Spacer(),
                      const CircularProgressIndicator(),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () async {
                          await context
                              .read<OrderCubit>()
                              .confirmDestinationArrival(
                                  _appKitModal, widget.rideId);
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
                          'Confirm Destination Arrival',
                          style: TextStyle(
                            fontSize: 18,
                            color: Theme.of(context).colorScheme.surface,
                          ),
                        ),
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
