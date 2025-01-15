import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:reown_appkit/reown_appkit.dart';
import 'package:shared/models/driver_model.dart';
import 'package:shared/utils/map_utils.dart';
import 'package:taxiapp/auth/cubit/auth_cubit.dart';
import 'package:taxiapp/auth/cubit/auth_state.dart';
import 'package:taxiapp/firebase/data_providers/client_location_dp.dart';
import 'package:taxiapp/location/cubit/location_cubit.dart';
import 'package:taxiapp/location/cubit/location_state.dart';
import 'package:taxiapp/order/cubit/order_cubit.dart';

class UpcomingPage extends StatefulWidget {
  final int rideId;
  final String driverId;
  const UpcomingPage({super.key, required this.rideId, required this.driverId});

  @override
  State<UpcomingPage> createState() => _UpcomingPageState();
}

class _UpcomingPageState extends State<UpcomingPage> {
  final _controller = Completer<GoogleMapController>();
  final mapUtils = MapUtils();
  late ReownAppKitModal _appKitModal;
  Map<MarkerId, Marker> markers = {};
  late DatabaseReference _databaseRef;
  StreamSubscription? _subscrition;
  DriverModel? driver;
  DatabaseReference? _databaseRef2;
  StreamSubscription? _subscrition2;
  final initTime = DateTime.now().millisecondsSinceEpoch / 1000;
  late BitmapDescriptor _carIcon;
  late ClientLocationDataProvider provider;
  late String clientId;

  @override
  void initState() {
    super.initState();
    _appKitModal = ReownAppKitModal(
      context: context,
      appKit: context.read<AuthCubit>().appKit,
    );
    _appKitModal.init();
    clientId = (context.read<AuthCubit>().state as AuthenticatedState).user.id;
    _databaseRef = FirebaseDatabase.instance
        .ref("rides/${widget.rideId}/driver/${widget.driverId}");
    _driverLocationListener();
    _databaseRef2 = FirebaseDatabase.instance.ref(
        "notifications/ride_started/${(context.read<AuthCubit>().state as AuthenticatedState).user.id}");
    _startedListener();
    context
        .read<LocationCubit>()
        .startLocationUpdate(clientId, "rides/${widget.rideId}/client");
    _loadCarIcon();
    context.read<OrderCubit>().getDriver(widget.driverId).then((value) {
      driver = value;
      setState(() {});
    });
  }


  void _startedListener() {
    _subscrition2 = _databaseRef2?.onChildAdded.listen((event) {
      final childData = (event.snapshot.value as Map).cast<String, dynamic>();
      print(childData);
      final int time = childData['timestamp'];
      if (initTime < time && childData['id'] == widget.rideId) {
        context.read<OrderCubit>().destinationArrival(widget.rideId);
      }
    });
  }

  void _driverLocationListener() {
    _subscrition = _databaseRef.onChildChanged.listen((event) async {
      final parentSnapshot = await _databaseRef.get();
      if (parentSnapshot.exists) {
        final childData = (parentSnapshot.value as Map).cast<String, dynamic>();
        final position = LatLng(childData['latitude'], childData['longitude']);
        markers[const MarkerId('driver')] = Marker(
          markerId: const MarkerId('driver'),
          position: position,
          icon: _carIcon,
        );
        setState(() {});
      }
    });
  }


  Future<void> _loadCarIcon() async {
    _carIcon = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(30, 30)),
      'assets/images/car_icon.png',
    );
    setState(() {});
  }

  @override
  void dispose() {
    _subscrition?.cancel();
    _subscrition2?.cancel();
    final clientId =
        (context.read<AuthCubit>().state as AuthenticatedState).user.id;
    context
        .read<LocationCubit>()
        .stopLocationUpdate(clientId, "rides/${widget.rideId}/client");
    super.dispose();
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
                        'Waiting for the driver arrival',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const Spacer(),
                      Text("Driver: ${driver?.firstName} ${driver?.lastName}"),
                      const SizedBox(height: 20),
                      Text("Car: ${driver?.car.carName}"),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () async {
                          await context.read<OrderCubit>().confirmSourceArrival(
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
                          'Confirm Source Arrival',
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
