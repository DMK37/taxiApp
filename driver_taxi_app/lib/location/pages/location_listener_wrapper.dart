import 'package:driver_taxi_app/location/cubit/location_cubit.dart';
import 'package:driver_taxi_app/location/cubit/location_state.dart';
import 'package:shared/widgets/error_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LocationListenerWrapper extends StatelessWidget {
  final Widget child;

  const LocationListenerWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocListener<LocationCubit, LocationState>(
      listener: (context, state) {
        switch (state) {
          case LocationLoadingState():
            // display a loading indicator
            break;

          case NoPermissionState():
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.transparent,
              elevation: 0,
              content: ErrorSnackBar(
                errorMessage: 'Location permission denied. Please enable it.',
              ),
            ));
            break;
        }
      },
      child:
          BlocBuilder<LocationCubit, LocationState>(builder: (context, state) {
        switch (state) {
          case LocationLoadingState() || NoPermissionState():
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );

          case LocationSuccessState():
            return child;

          default:
            return const SizedBox.shrink();
        }
      }),
    );
  }
}
