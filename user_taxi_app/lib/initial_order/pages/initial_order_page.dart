import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:taxiapp/components/main_draggable_scrollable_sheet.dart';
import 'package:taxiapp/initial_order/cubit/initial_order_cubit.dart';
import 'package:taxiapp/location/cubit/location_cubit.dart';
import 'package:taxiapp/location/cubit/location_state.dart';

class InitialOrderPage extends StatefulWidget {
  const InitialOrderPage({super.key});

  @override
  State<InitialOrderPage> createState() => _InitialOrderPageState();
}

class _InitialOrderPageState extends State<InitialOrderPage> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _sourceController = TextEditingController();

  bool _isDestination = true;

  final FocusNode _sourceFocusNode = FocusNode();
  final FocusNode _destinationFocusNode = FocusNode();
  LatLng? _source;
  LatLng? _destination;

  @override
  void dispose() {
    _sourceController.dispose();
    _destinationController.dispose();
    _sourceFocusNode.dispose();
    _destinationFocusNode.dispose();
    super.dispose();
  }

  Future<void> _goToTheLocation(LatLng location) async {
    final GoogleMapController controller = await _controller.future;
    await controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: location, zoom: 17)));
  }

  @override
  Widget build(BuildContext context) {
    if (_sourceController.text == "") {
      setState(() {
        _isDestination = false;
      });
      _sourceController.text =
          (context.read<LocationCubit>().state as LocationSuccessState).address;
      context.read<InitialOrderCubit>().pickSource(
          (context.read<LocationCubit>().state as LocationSuccessState)
              .location);
      _source = (context.read<LocationCubit>().state as LocationSuccessState)
          .location;
    }
    return Scaffold(
      body: Stack(
        children: [
          LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
            return SizedBox(
              height: constraints.maxHeight * 0.8,
              child: Stack(children: [
                GoogleMap(
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
                  // markers: {
                  //   Marker(
                  //     markerId: const MarkerId('user_location'),
                  //     position: (context.read<LocationCubit>().state
                  //             as LocationSuccessState)
                  //         .location,
                  //     infoWindow: const InfoWindow(title: 'Your Location'),
                  //     icon: BitmapDescriptor.defaultMarkerWithHue(
                  //       BitmapDescriptor.hueBlue,
                  //     ),
                  //   ),
                  // },
                  onCameraMove: (CameraPosition position) {
                    // update position order cubit
                    if (_isDestination) {
                      _destination = position.target;
                    } else {
                      _source = position.target;
                    }
                  },
                  onCameraIdle: () async {
                    // get address
                    final loc = _isDestination ? _destination : _source;
                    final places = await placemarkFromCoordinates(loc!.latitude, loc.longitude);
                    final addressBeforeComma = places[0].street;
                    if (_isDestination) {
                      _destinationController.text = addressBeforeComma!;
                    } else {
                      _sourceController.text = addressBeforeComma!;
                    }
                  },
                ),
                const Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 25.0),
                    child: Icon(
                      Icons.location_pin,
                      size: 50.0,
                      color: Colors.black,
                    ),
                  ),
                ),
              ]),
            );
          }),
          Positioned(
            bottom: 220,
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
          MainDraggableScrollableSheet(
              firstChild: _isDestination
                  ? Column(
                      children: [
                        const Center(
                          child: Text(
                            "Pick Destination",
                            style: TextStyle(
                              fontSize: 20.0, // Larger font size
                              fontWeight: FontWeight.bold, // Bold font weight
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          textAlign: TextAlign.center,
                          controller: _destinationController,
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
                        const SizedBox(height: 20), // Add some spacing
                        ElevatedButton(
                          onPressed: () {
                            context
                                .read<InitialOrderCubit>()
                                .pickDestination(_destination!);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .primary, // Set the background color to green
                          ),
                          child: const Text(
                            'Confirm Destination Point',
                            style: TextStyle(
                              color:
                                  Colors.white, // Set the text color to white
                              fontSize: 16.0, // Adjust font size
                            ),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        const Center(
                          child: Text(
                            "Pick Source",
                            style: TextStyle(
                              fontSize: 20.0, // Larger font size
                              fontWeight: FontWeight.bold, // Bold font weight
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _sourceController,
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
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _isDestination = true;
                            });
                            context
                                .read<InitialOrderCubit>()
                                .pickSource(_source!);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                          ),
                          child: const Text(
                            'Confirm Pick Up Point',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                            ),
                          ),
                        ),
                      ],
                    ),
              secondChild: Column(children: [
                const Center(
                  child: Text(
                    "Your Ride",
                    style: TextStyle(
                      fontSize: 20.0, // Larger font size
                      fontWeight: FontWeight.bold, // Bold font weight
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _sourceController,
                  focusNode: _sourceFocusNode,
                  decoration: InputDecoration(
                    hintText: 'Source',
                    hintStyle: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.normal,
                    ),
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.adjust_sharp),
                    suffixIcon: IconButton(
                        onPressed: () {
                          _sourceController.clear();
                          _destinationFocusNode.unfocus();
                          _sourceFocusNode.requestFocus();
                        },
                        icon: const Icon(Icons.clear)),
                  ),
                  onTap: () {
                    setState(() {
                      _isDestination = false;
                    });
                  },
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _destinationController,
                  focusNode: _destinationFocusNode,
                  decoration: InputDecoration(
                    hintText: 'Destination',
                    hintStyle: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.normal,
                    ),
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.location_on),
                    suffixIcon: IconButton(
                        onPressed: () {
                          _destinationController.clear();
                          _sourceFocusNode.unfocus();
                          _destinationFocusNode.requestFocus();
                        },
                        icon: const Icon(Icons.clear)),
                  ),
                  onTap: () {
                    setState(() {
                      _isDestination = true;
                    });
                  },
                ),
              ]))
        ],
      ),
    );
  }
}
