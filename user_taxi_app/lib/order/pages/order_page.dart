import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:taxiapp/order/cubit/order_cubit.dart';
import 'package:taxiapp/order/cubit/order_state.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  GoogleMapController? mapController;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('User Location Map'),
        ),
        body: BlocBuilder<OrderCubit, OrderState>(
          builder: (context, state) {
            switch (state) {
              case OrderLoading():
                return const Center(child: CircularProgressIndicator());
              case OrderInitial(location: final location):
                return SizedBox(
                  height: double.infinity,
                  child: GoogleMap(
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: CameraPosition(
                      target: location,
                      zoom: 15.0,
                    ),
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    markers: {
                      Marker(
                        markerId: const MarkerId('user_location'),
                        position: location,
                        infoWindow: const InfoWindow(title: 'Your Location'),
                      ),
                    },
                  ),
                );
              case OrderFailure(errorMessage: final errorMessage):
                return Center(
                  child: Text(errorMessage),
                );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ));
  }
}
