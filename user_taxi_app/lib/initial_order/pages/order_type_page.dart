import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:reown_appkit/reown_appkit.dart';
import 'package:shared/models/ride_price_model.dart';
import 'package:shared/utils/map_utils.dart';
import 'package:taxiapp/auth/cubit/auth_cubit.dart';
import 'package:taxiapp/initial_order/cubit/initial_order_cubit.dart';
import 'package:taxiapp/initial_order/cubit/initial_order_state.dart';
import 'package:taxiapp/location/cubit/location_cubit.dart';
import 'package:taxiapp/location/cubit/location_state.dart';
import 'package:taxiapp/order/cubit/order_cubit.dart';

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
  List<RidePriceModel> prices = [];
  int _selectedTaxiIndex = 0;
  String sourceAddress = "";
  String sourceLocation = "";
  String destinationLocation = "";
  String destinationAddress = "";
  int distance = 0;

  late ReownAppKitModal _appKitModal;
  MapUtils mapUtils = MapUtils();

  @override
  void initState() {
    super.initState();
    sourceAddress = (context.read<InitialOrderCubit>().state as OrderWithPoints)
        .sourceAddress;
    destinationAddress =
        (context.read<InitialOrderCubit>().state as OrderWithPoints)
            .destinationAddress;
    sourceLocation =
        "${(context.read<InitialOrderCubit>().state as OrderWithPoints).source.latitude},${(context.read<InitialOrderCubit>().state as OrderWithPoints).source.longitude}";
    destinationLocation =
        "${(context.read<InitialOrderCubit>().state as OrderWithPoints).destination.latitude},${(context.read<InitialOrderCubit>().state as OrderWithPoints).destination.longitude}";

    _appKitModal = ReownAppKitModal(
      context: context,
      appKit: context.read<AuthCubit>().appKit,
    );
    _appKitModal.init();
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
                  final (polyline, dist) = await mapUtils.getPolyline(
                      source, destination);
                  prices = await context
                      .read<InitialOrderCubit>()
                      .getPrices(source, destination, dist);
                  distance = dist;
                  polylines[polyline.polylineId] = polyline;
                  setState(() {});

                  _addMarker(source, "Source", BitmapDescriptor.defaultMarker);
                  _addMarker(destination, "Destination",
                      BitmapDescriptor.defaultMarkerWithHue(90));

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
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        'Select a car type',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.only(
                              top: 16), // Padding at the top

                          itemCount: prices.length,
                          itemBuilder: (context, index) {
                            final price = prices[index];
                            final isSelected = _selectedTaxiIndex == index;

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedTaxiIndex = index;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: isSelected
                                      ? Border.all(
                                          color: Colors.greenAccent, width: 2)
                                      : Border.all(
                                          color: Colors.grey, width: 1),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          price.carType.toString(),
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: isSelected
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .surface
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          "ETH ${price.price.toStringAsPrecision(2)}",
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: isSelected
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .surface
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Icon(
                                      isSelected
                                          ? Icons.check_circle
                                          : Icons.circle_outlined,
                                      color: isSelected
                                          ? Theme.of(context)
                                              .colorScheme
                                              .surface
                                          : Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                      size: 24,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () async {
                          final resp = await context
                              .read<OrderCubit>()
                              .createRide(
                                  _appKitModal,
                                  prices[_selectedTaxiIndex].price,
                                  sourceAddress,
                                  destinationAddress,
                                  sourceLocation,
                                  destinationLocation,
                                  distance);
                          if (resp) {
                            context.go("/order");
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
