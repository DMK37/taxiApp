import 'package:driver_taxi_app/auth/cubit/auth_state.dart';
import 'package:driver_taxi_app/auth/repository/auth_repository.dart';
import 'package:driver_taxi_app/models/driver.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DriverAuthCubit extends Cubit<DriverAuthState> {
  final DriverAuthRepository repository;
  DriverAuthCubit(this.repository) : super(DriverUnauthenticatedState());

  Future<void> signIn() async {
    emit(DriverAuthLoadingState());
    try {
      final driver = await repository.signIn();
      emit(DriverAuthenticatedState(driver: driver));
    } catch (e) {
      emit(DriverAuthFailureState(errorMessage: e.toString()));
    }
  }

  Future<void> signOut() async {
    emit(DriverAuthLoadingState());
    try {
        emit(DriverUnauthenticatedState());
    } catch (e) {
      emit(DriverAuthFailureState(errorMessage: e.toString()));
    }
  }

  Future<void> isAuthenticated() async {
    emit(DriverAuthLoadingState());
    try {
      final isAuth = await repository.isAuthenticated();
      if(isAuth) {
        emit(DriverAuthenticatedState(driver: DriverModel(walletId: "1234", name: "Alina")));
      }
      else{
        emit(DriverUnauthenticatedState());
      }
    } catch (e) {
      emit(DriverAuthFailureState(errorMessage: e.toString()));
    }
  }
}
