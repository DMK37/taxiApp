import 'dart:async';
import 'package:driver_taxi_app/auth/cubit/auth_cubit.dart';
import 'package:driver_taxi_app/auth/cubit/auth_state.dart';
import 'package:driver_taxi_app/initial_state/cubit/initial_cubit.dart';
import 'package:driver_taxi_app/location/cubit/location_cubit.dart';
import 'package:driver_taxi_app/location/cubit/location_state.dart';
import 'package:driver_taxi_app/models/order_message.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/services.dart' show rootBundle;

class InitialDriverPage extends StatefulWidget {
  const InitialDriverPage({super.key});

  @override
  State<InitialDriverPage> createState() => _InitialDriverPageState();
}

class _InitialDriverPageState extends State<InitialDriverPage> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  final TextEditingController _currentAddressController =
      TextEditingController();
  bool isOnline = false;
  late DatabaseReference _databaseRef;

  LatLng? _currentAddress;
  late String driverId;

  String _darkMapStyle = '''[]''';
  String _lightMapStyle = '''[]''';

  @override
  void initState() {
    super.initState();

    _loadMapStyles();

    _currentAddressController.text =
        (context.read<LocationCubit>().state as LocationSuccessState).address;
    driverId =
        (context.read<DriverAuthCubit>().state as DriverAuthenticatedState)
            .driver
            .id;
    _databaseRef = FirebaseDatabase.instance.ref("notifications/$driverId");
    _listenForNewItems();
  }

  void _listenForNewItems() {
    _databaseRef.onChildAdded.listen((event) {
      final timenow = DateTime.now().toUtc().millisecondsSinceEpoch;
      final childData = (event.snapshot.value as Map).cast<String, dynamic>();
      final int until = int.parse(childData['validUntil']);
      if (timenow < until && isOnline) {
        final message = OrderMessageModel.fromMap(childData);
        context.read<DriverInitCubit>().messageReceived(driverId, message);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadMapStyles() async {
    try {
      _darkMapStyle = await rootBundle.loadString('assets/map_styles/dark_map_style.json');
      print('loaded dart map theme');
    } catch (e) {
      print('cant load dart map theme');
    }
    try {
      _lightMapStyle = await rootBundle.loadString('assets/map_styles/light_map_style.json');
      print('loaded light map theme');
    } catch (e) {
      print('cant load light map theme');
    }
  }

  @override
  Widget build(BuildContext context) {
    final String currentStyle = Theme.of(context).brightness == Brightness.dark ? _darkMapStyle : _lightMapStyle;
    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.8,
            child: Stack(
              children: [
                GoogleMap(
                  style: currentStyle,
                  tiltGesturesEnabled: false,
                  mapType: MapType.normal,
                  onMapCreated: (GoogleMapController controller) {
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
                  onCameraIdle: () async {
                    setState(() {});
                    final loc = _currentAddress;
                    if (loc != null) {
                      final places = await placemarkFromCoordinates(
                          loc.latitude, loc.longitude);
                      final address =
                          "${places[0].street}, ${places[0].locality}";
                      _currentAddressController.text = address;
                    }
                  },
                ),
              ],
            ),
          ),
          Positioned(
            top: 45,
            left: 16,
            child: SizedBox(
              height: 40,
              width: 40,
              child: FloatingActionButton(
                heroTag: 'user-page',
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                backgroundColor: Theme.of(context).colorScheme.surface,
                onPressed: () async {
                  context.push('/driver');
                },
                child: Icon(
                  Icons.person,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.28,
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
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                height: 150,
                width: 350,
                child: Column(
                  children: [
                    TextField(
                      maxLines: 2,
                      controller: _currentAddressController,
                      textAlign: TextAlign.center,
                      readOnly: true,
                      decoration: InputDecoration(
                        fillColor: Theme.of(context).colorScheme.surface,
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        isOnline
                            ? showGoOfflineDialog(context)
                            : showGoOnlineDialog(context);
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 15),
                        backgroundColor:
                            isOnline ? Colors.red[800] : Colors.green[800],
                      ),
                      child: Text(
                        isOnline ? 'Go offline' : 'Go online',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> showGoOnlineDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: const Text("You are online!"),
          
          content: const Text(
              "You are now online and clients can see your localization.",
              ),
          actions: [
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  isOnline = !isOnline;
                });
              },
            ),
          ],
        );
      },
    );
    final location = await context.read<LocationCubit>().getLocation();
    await context
        .read<DriverInitCubit>()
        .startLocationUpdate(location.$1, driverId, "drivers");
  }

  void showGoOfflineDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.primary,
          title: const Text("You are offline!"),
          content: const Text(
              "You are now offline and clients can't see your localization."),
          actions: [
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  isOnline = !isOnline;
                });
              },
            ),
          ],
        );
      },
    );
    await context.read<DriverInitCubit>().stopLocationUpdate(driverId, "drivers");
  }
}
