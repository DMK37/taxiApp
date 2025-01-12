import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared/utils/map_utils.dart';
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
  final mapUtils = MapUtils();

  bool _isDestination = true;

  final FocusNode _sourceFocusNode = FocusNode();
  final FocusNode _destinationFocusNode = FocusNode();
  LatLng? _source;
  LatLng? _destination;
  List<dynamic> _autoCompleteSuggestions = [];

  @override
  void initState() {
    super.initState();
    _sourceController.text =
        (context.read<LocationCubit>().state as LocationSuccessState).address;
    context.read<InitialOrderCubit>().pickSource(
        (context.read<LocationCubit>().state as LocationSuccessState).location,
        (context.read<LocationCubit>().state as LocationSuccessState).address);
    _source =
        (context.read<LocationCubit>().state as LocationSuccessState).location;

    _sourceFocusNode.addListener(() {
      if (_sourceFocusNode.hasFocus) {
        _sourceController.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _sourceController.text.length,
        );
      }
    });

    _destinationFocusNode.addListener(() {
      if (_destinationFocusNode.hasFocus) {
        _destinationController.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _destinationController.text.length,
        );
      }
    });

    
  }

  @override
  void dispose() {
    _sourceController.dispose();
    _destinationController.dispose();
    _sourceFocusNode.dispose();
    _destinationFocusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.8,
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
                onCameraMove: (CameraPosition position) {
                  if (_isDestination) {
                    _destination = position.target;
                  } else {
                    _source = position.target;
                  }
                },
                onCameraIdle: () async {
                  setState(() {
                    _autoCompleteSuggestions = [];
                  });
                  final loc = _isDestination ? _destination : _source;
                  final places = await placemarkFromCoordinates(
                      loc!.latitude, loc.longitude);
                  final address = "${places[0].street}, ${places[0].locality}";
                  if (_isDestination) {
                    _destinationController.text = address;
                  } else {
                    _sourceController.text = address;
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
                onPressed: () {
                  context.push('/user');
                },
                child: Icon(
                  Icons.person,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.24,
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
          MainDraggableScrollableSheet(
              isDestination: _isDestination,
              firstChild: _isDestination
                  ? Column(
                      children: [
                        Center(
                          child: Text("Pick Destination",
                              style: Theme.of(context).textTheme.titleMedium),
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
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            context.read<InitialOrderCubit>().pickDestination(
                                _destination!, _destinationController.text);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            foregroundColor:
                                Theme.of(context).colorScheme.surface,
                          ),
                          child: Text(
                            'Confirm Destination Point',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.surface,
                              fontSize: 16.0,
                            ),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        Center(
                          child: Text(
                            "Pick Source",
                            style: Theme.of(context).textTheme.titleMedium,
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
                                .pickSource(_source!, _sourceController.text);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            foregroundColor:
                                Theme.of(context).colorScheme.surface,
                          ),
                          child: Text(
                            'Confirm Pick Up Point',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.surface,
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
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _sourceController,
                  focusNode: _sourceFocusNode,
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Source',
                    hintStyle: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius:
                          const BorderRadius.all(Radius.circular(10.0)),
                      borderSide: BorderSide(
                        width: 1.5,
                        color:
                            Theme.of(context).inputDecorationTheme.fillColor!,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius:
                          const BorderRadius.all(Radius.circular(10.0)),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 1.5,
                      ),
                    ),
                    prefixIcon: const Icon(Icons.adjust_sharp),
                    suffixIcon: IconButton(
                        onPressed: () {
                          _sourceController.clear();
                          _destinationFocusNode.unfocus();
                          _sourceFocusNode.requestFocus();

                          setState(() {
                            _autoCompleteSuggestions = [];
                          });
                        },
                        icon: const Icon(Icons.clear)),
                  ),
                  onTap: () async {
                    if (_sourceController.text != "") {
                      _autoCompleteSuggestions = await context
                          .read<LocationCubit>()
                          .getAutoCompleteSuggestions(_sourceController.text);
                    } else {
                      _autoCompleteSuggestions = [];
                    }
                    setState(() {
                      _isDestination = false;
                    });
                  },
                  onChanged: (value) async {
                    if (value.isNotEmpty) {
                      _autoCompleteSuggestions = await context
                          .read<LocationCubit>()
                          .getAutoCompleteSuggestions(value);
                      setState(() {});
                    }
                  },
                ),
                TextField(
                  controller: _destinationController,
                  focusNode: _destinationFocusNode,
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Destination',
                    hintStyle: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius:
                          const BorderRadius.all(Radius.circular(10.0)),
                      borderSide: BorderSide(
                        width: 1.5,
                        color:
                            Theme.of(context).inputDecorationTheme.fillColor!,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius:
                          const BorderRadius.all(Radius.circular(10.0)),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 1.5,
                      ),
                    ),
                    prefixIcon: const Icon(Icons.crop_square_outlined),
                    suffixIcon: IconButton(
                        onPressed: () {
                          _destinationController.clear();
                          _sourceFocusNode.unfocus();
                          _destinationFocusNode.requestFocus();
                          setState(() {
                            _autoCompleteSuggestions = [];
                          });
                        },
                        icon: const Icon(Icons.clear)),
                  ),
                  onTap: () async {
                    if (_destinationController.text != "") {
                      _autoCompleteSuggestions = await context
                          .read<LocationCubit>()
                          .getAutoCompleteSuggestions(
                              _destinationController.text);
                    } else {
                      _autoCompleteSuggestions = [];
                    }
                    setState(() {
                      _isDestination = true;
                    });
                  },
                  onChanged: (value) async {
                    if (value.isNotEmpty) {
                      _autoCompleteSuggestions = await context
                          .read<LocationCubit>()
                          .getAutoCompleteSuggestions(value);
                      setState(() {});
                    }
                  },
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: MediaQuery.of(context).viewInsets.bottom > 0
                      ? MediaQuery.of(context).size.height * 0.755 -
                          MediaQuery.of(context).viewInsets.bottom
                      : MediaQuery.of(context).size.height * 0.73,
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: _autoCompleteSuggestions.length,
                    itemBuilder: (context, index) {
                      String suggestion =
                          _autoCompleteSuggestions[index]['description'];
                      return Column(
                        children: [
                          ListTile(
                            leading: Icon(Icons.location_on,
                                color: Theme.of(context).colorScheme.primary),
                            title: Text(
                              suggestion,
                              style: const TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            onTap: () async {
                              final LatLng? loc = await context
                                  .read<LocationCubit>()
                                  .getPlaceCoordinates(
                                      _autoCompleteSuggestions[index]
                                          ['place_id']);
                              if (_isDestination) {
                                context
                                    .read<InitialOrderCubit>()
                                    .pickDestination(loc!, suggestion);
                                _destinationController.text = suggestion;
                                _destination = loc;
                              } else {
                                context
                                    .read<InitialOrderCubit>()
                                    .pickSource(loc!, suggestion);
                                _sourceController.text = suggestion;
                                _source = loc;
                              }
                              setState(() {
                                _autoCompleteSuggestions = [];
                              });
                            },
                          ),
                          if (index != _autoCompleteSuggestions.length - 1)
                            SizedBox(
                              width: MediaQuery.of(context).size.width *
                                  0.85, // Adjust the width as needed
                              child: Divider(
                                color: Theme.of(context).colorScheme.secondary,
                                height: 1,
                                thickness: 1,
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                )
              ]))
        ],
      ),
    );
  }
}
