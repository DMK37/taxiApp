import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:reown_appkit/modal/appkit_modal_impl.dart';
import 'package:taxiapp/auth/cubit/auth_cubit.dart';
import 'package:taxiapp/auth/cubit/auth_state.dart';
import 'package:taxiapp/location/cubit/location_cubit.dart';
import 'package:taxiapp/location/cubit/location_state.dart';
import 'package:taxiapp/order/cubit/order_cubit.dart';

class WaitingPage extends StatefulWidget {
  const WaitingPage({super.key});

  @override
  State<WaitingPage> createState() => _WaitingPageState();
}

class _WaitingPageState extends State<WaitingPage> {
  late DatabaseReference _databaseRef;
  bool _isButtonEnabled = false;
  final initTime = DateTime.now().millisecondsSinceEpoch;

  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  late ReownAppKitModal _appKitModal;
  @override
  void initState() {
    super.initState();
    print((context.read<AuthCubit>().state as AuthenticatedState).user.id);
    _databaseRef = FirebaseDatabase.instance.ref(
        "notifications/ride_created/${(context.read<AuthCubit>().state as AuthenticatedState).user.id}");
    _appKitModal = ReownAppKitModal(
      context: context,
      appKit: context.read<AuthCubit>().appKit,
    );
    _appKitModal.init();
    _listenForNewItems();
  }

  void _listenForNewItems() {
    _databaseRef.onChildAdded.listen((event) {
      print(event.snapshot.value);
      final childData = event.snapshot.value as Map;
      if (initTime > childData['timestamp']) {
        setState(() {
          _isButtonEnabled = true;
        });
      }
    });
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
                  height: MediaQuery.of(context).size.height * 0.3,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(25.0),
                      topRight: Radius.circular(25.0),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Waiting for the driver',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 30),
                      const CircularProgressIndicator(),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: _isButtonEnabled
                            ? () async {
                                await context
                                    .read<OrderCubit>()
                                    .cancelRide(_appKitModal);
                              }
                            : null, // Disable the button if `_isButtonEnabled` is false
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isButtonEnabled
                              ? Theme.of(context).colorScheme.primary
                              : Colors
                                  .grey, // Optional: Change color when disabled
                          foregroundColor:
                              Theme.of(context).colorScheme.surface,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 50, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          'Cancel Ride',
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
