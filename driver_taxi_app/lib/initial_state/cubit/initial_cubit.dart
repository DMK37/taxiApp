import 'package:driver_taxi_app/initial_state/cubit/initial_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DriverInitCubit extends Cubit<DriverInitState> {
  DriverInitCubit() : super(InitState());

  void clearPoints() {
    emit(InitState());
  }
}
