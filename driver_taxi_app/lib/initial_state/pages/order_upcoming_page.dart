import 'dart:async';

import 'package:driver_taxi_app/auth/cubit/auth_cubit.dart';
import 'package:driver_taxi_app/auth/cubit/auth_state.dart';
import 'package:driver_taxi_app/firebase/data_providers/driver_location_dp.dart';
import 'package:driver_taxi_app/initial_state/cubit/initial_cubit.dart';
import 'package:driver_taxi_app/location/cubit/location_cubit.dart';
import 'package:driver_taxi_app/location/cubit/location_state.dart';
import 'package:driver_taxi_app/models/order_message.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:reown_appkit/modal/appkit_modal_impl.dart';
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
  final initTime = DateTime.now().millisecondsSinceEpoch / 1000;
  late DatabaseReference _databaseRef;
  DatabaseReference? _databaseRef2;
  StreamSubscription? _subscrition2;
  final mapUtils = MapUtils();
  Map<MarkerId, Marker> markers = {};
  Map<PolylineId, Polyline> polylines = {};
  late DriverLocationDataProvider provider;
  String? driverId;
  Timer? _locationTimer;
  late ReownAppKitModal _appKitModal;
  late BitmapDescriptor _userIcon;
  @override
  void initState() {
    super.initState();

    final appKit = context.read<DriverAuthCubit>().appKit;
    _appKitModal = ReownAppKitModal(
      context: context,
      appKit: appKit,
    );
    _appKitModal.init().then((value) => setState(() {}));
    driverId =
        (context.read<DriverAuthCubit>().state as DriverAuthenticatedState)
            .driver
            .id;
    _databaseRef = FirebaseDatabase.instance
        .ref("rides/${widget.message.rideId}/client/${widget.message.client}");
    provider = DriverLocationDataProvider(
        db: FirebaseDatabase.instance
            .ref("rides/${widget.message.rideId}/driver"));
    markers[const MarkerId('source')] = Marker(
      markerId: const MarkerId('source'),
      position: widget.message.sourceLocation,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );
    _clientLocationListener();
    _driverDirectionUpdates();
    _showLocation();
    _databaseRef2 =
        FirebaseDatabase.instance.ref("notifications/ride_started/$driverId");
    _startedListener();
    _loadUserIcon();
  }

  Future<void> _loadUserIcon() async {
    final icon = await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(30, 30)),
        'assets/images/user_icon.png');
    _userIcon = icon;
  }

  void _startedListener() {
    _subscrition2 = _databaseRef2?.onChildAdded.listen((event) {
      final childData = (event.snapshot.value as Map).cast<String, dynamic>();
      print(childData);
      final int time = childData['timestamp'];
      if (initTime < time && childData['id'] == widget.message.rideId) {
        context.read<DriverInitCubit>().orderInProgress(widget.message);
      }
    });
  }

  void _showLocation() async {
    final location = await context.read<LocationCubit>().getLocation();
    startLocationUpdate(location.$1);
  }

  void _clientLocationListener() {
    _databaseRef.onChildChanged.listen((event) async {
      print(event.snapshot.value);
      final parentSnapshot = await _databaseRef.get();
      if (parentSnapshot.exists) {
        final childData = (parentSnapshot.value as Map).cast<String, dynamic>();

        final position = LatLng(childData['latitude'], childData['longitude']);
        markers[const MarkerId('client')] = Marker(
          markerId: const MarkerId('client'),
          position: position,
          icon: _userIcon,
        );
        setState(() {});
      }
    });
  }

  void _driverDirectionUpdates() {
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

  void startLocationUpdate(LatLng driverLocation) async {
    provider.setDriverCurrenLocation(driverLocation, driverId!);
    _locationTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      provider.setDriverCurrenLocation(driverLocation, driverId!);
    });
  }

  void stopLocationUpdate() async {
    _locationTimer?.cancel();
    provider.removeActiveDriver(driverId!);
  }

  @override
  void dispose() {
    if (driverId != null) {
      stopLocationUpdate();
    }
    _subscrition2?.cancel();

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
                  final (location, _) =
                      await context.read<LocationCubit>().getLocation();
                  final (polyline, _) = await mapUtils.getPolyline(
                      location, widget.message.sourceLocation);
                  polylines[const PolylineId('polyline')] = polyline;
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
                        onPressed: () async {
                          await context
                              .read<DriverInitCubit>()
                              .confirmSourceArrival(_appKitModal,
                                  widget.message.rideId, widget.message);
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
