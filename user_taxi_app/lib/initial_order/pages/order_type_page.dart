import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:reown_appkit/reown_appkit.dart';
import 'package:taxiapp/auth/cubit/auth_cubit.dart';
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

  late ReownAppKitModal _appKitModal;
  final deployedContract = DeployedContract(
    ContractAbi.fromJson(
      jsonEncode([
        {
          "anonymous": false,
          "inputs": [
            {
              "indexed": false,
              "internalType": "uint64",
              "name": "rideId",
              "type": "uint64"
            }
          ],
          "name": "RideCancelled",
          "type": "event"
        },
        {
          "anonymous": false,
          "inputs": [
            {
              "indexed": false,
              "internalType": "uint64",
              "name": "rideId",
              "type": "uint64"
            },
            {
              "indexed": false,
              "internalType": "uint256",
              "name": "endTime",
              "type": "uint256"
            }
          ],
          "name": "RideCompleted",
          "type": "event"
        },
        {
          "anonymous": false,
          "inputs": [
            {
              "indexed": false,
              "internalType": "uint64",
              "name": "rideId",
              "type": "uint64"
            },
            {
              "indexed": false,
              "internalType": "address",
              "name": "driver",
              "type": "address"
            },
            {
              "indexed": false,
              "internalType": "uint256",
              "name": "confirmationTime",
              "type": "uint256"
            }
          ],
          "name": "RideConfirmed",
          "type": "event"
        },
        {
          "anonymous": false,
          "inputs": [
            {
              "indexed": false,
              "internalType": "uint64",
              "name": "rideId",
              "type": "uint64"
            },
            {
              "indexed": false,
              "internalType": "address",
              "name": "client",
              "type": "address"
            },
            {
              "indexed": false,
              "internalType": "uint256",
              "name": "cost",
              "type": "uint256"
            }
          ],
          "name": "RideCreated",
          "type": "event"
        },
        {
          "anonymous": false,
          "inputs": [
            {
              "indexed": false,
              "internalType": "uint64",
              "name": "rideId",
              "type": "uint64"
            },
            {
              "indexed": false,
              "internalType": "uint256",
              "name": "startTime",
              "type": "uint256"
            }
          ],
          "name": "RideStarted",
          "type": "event"
        },
        {
          "inputs": [
            {"internalType": "uint64", "name": "_rideId", "type": "uint64"}
          ],
          "name": "cancelRide",
          "outputs": [],
          "stateMutability": "nonpayable",
          "type": "function"
        },
        {
          "inputs": [
            {"internalType": "uint64", "name": "_rideId", "type": "uint64"}
          ],
          "name": "confirmDestinationArrivalByClient",
          "outputs": [],
          "stateMutability": "nonpayable",
          "type": "function"
        },
        {
          "inputs": [
            {"internalType": "uint64", "name": "_rideId", "type": "uint64"}
          ],
          "name": "confirmDestinationArrivalByDriver",
          "outputs": [],
          "stateMutability": "nonpayable",
          "type": "function"
        },
        {
          "inputs": [
            {"internalType": "uint64", "name": "_rideId", "type": "uint64"}
          ],
          "name": "confirmRide",
          "outputs": [],
          "stateMutability": "nonpayable",
          "type": "function"
        },
        {
          "inputs": [
            {"internalType": "uint64", "name": "_rideId", "type": "uint64"}
          ],
          "name": "confirmSourceArrivalByClient",
          "outputs": [],
          "stateMutability": "nonpayable",
          "type": "function"
        },
        {
          "inputs": [
            {"internalType": "uint64", "name": "_rideId", "type": "uint64"}
          ],
          "name": "confirmSourceArrivalByDriver",
          "outputs": [],
          "stateMutability": "nonpayable",
          "type": "function"
        },
        {
          "inputs": [
            {"internalType": "uint64", "name": "_distance", "type": "uint64"},
            {"internalType": "string", "name": "_source", "type": "string"},
            {"internalType": "string", "name": "_destination", "type": "string"}
          ],
          "name": "createRide",
          "outputs": [
            {"internalType": "uint64", "name": "", "type": "uint64"}
          ],
          "stateMutability": "payable",
          "type": "function"
        },
        {
          "inputs": [],
          "name": "rideCounter",
          "outputs": [
            {"internalType": "uint64", "name": "", "type": "uint64"}
          ],
          "stateMutability": "view",
          "type": "function"
        },
        {
          "inputs": [
            {"internalType": "uint64", "name": "", "type": "uint64"}
          ],
          "name": "rides",
          "outputs": [
            {
              "internalType": "address payable",
              "name": "client",
              "type": "address"
            },
            {
              "internalType": "address payable",
              "name": "driver",
              "type": "address"
            },
            {"internalType": "uint256", "name": "cost", "type": "uint256"},
            {"internalType": "uint64", "name": "distance", "type": "uint64"},
            {"internalType": "string", "name": "source", "type": "string"},
            {"internalType": "string", "name": "destination", "type": "string"},
            {
              "internalType": "uint256",
              "name": "confirmationTime",
              "type": "uint256"
            },
            {"internalType": "uint256", "name": "startTime", "type": "uint256"},
            {"internalType": "uint256", "name": "endTime", "type": "uint256"},
            {
              "internalType": "enum Ride.RideStatus",
              "name": "status",
              "type": "uint8"
            }
          ],
          "stateMutability": "view",
          "type": "function"
        }
      ]), // ABI object
      'Tether USD',
    ),
    EthereumAddress.fromHex('0xA3391Cc3a3e0AAFA305AEEE03E00999151B5df5A'),
  );

  @override
  void initState() {
    super.initState();

    final appKit = context.read<AuthCubit>().appKit;
    final testNetworks = ReownAppKitModalNetworks.test['eip155'] ?? [];
    ReownAppKitModalNetworks.addNetworks('eip155', testNetworks);
    _appKitModal = ReownAppKitModal(
      context: context,
      appKit: appKit,
    );
    _appKitModal.init();
  }

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
                        onPressed: () async {
                          final result = await _appKitModal.requestWriteContract(
                              topic: _appKitModal.session!.topic,
                              chainId: _appKitModal.selectedChain!.chainId,
                              deployedContract: deployedContract,
                              functionName: "createRide",
                              transaction: Transaction(
                                from: EthereumAddress.fromHex(
                                    _appKitModal.session!.address!),
                                value: EtherAmount.inWei(
                                    BigInt.from(100000000000)),
                              ),
                              parameters: [BigInt.from(25), "A", "B"]);
                          print("Result: $result");
                        },
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
