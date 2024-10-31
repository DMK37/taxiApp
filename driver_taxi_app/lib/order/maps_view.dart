import 'package:driver_taxi_app/location/cubit/location_cubit.dart';
import 'package:driver_taxi_app/location/cubit/location_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapsView extends StatelessWidget {
  const MapsView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'User Location Map',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: UserCurrentLocation(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class UserCurrentLocation extends StatefulWidget {
  @override
  _UserCurrentLocationState createState() => _UserCurrentLocationState();
}

class _UserCurrentLocationState extends State<UserCurrentLocation> {
  GoogleMapController? mapController;
  @override
  void initState() {
    super.initState();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Location Map'),
      ),
      body: SizedBox(
        height: double.infinity,
        child: GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target:
                (context.read<DriverLocationCubit>().state as DriverLocationSuccessState)
                    .location,
            zoom: 15.0,
          ),
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          markers: {
            Marker(
              markerId: const MarkerId('user_location'),
              position:
                  (context.read<DriverLocationCubit>().state as DriverLocationSuccessState)
                      .location,
              infoWindow: const InfoWindow(title: 'Your Location'),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueBlue,
              ),
            ),
          },
        ),
      ),
    );
  }
}
