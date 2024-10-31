import 'package:driver_taxi_app/models/driver.dart';
import 'package:equatable/equatable.dart';

abstract class DriverAuthState extends Equatable{}

class DriverAuthenticatedState extends DriverAuthState{
  final DriverModel driver;

  DriverAuthenticatedState({required this.driver});

  @override
  List<Object?> get props => [];
}

class DriverUnauthenticatedState extends DriverAuthState{
  @override
  List<Object?> get props => [];

}

class DriverAuthLoadingState extends DriverAuthState{
  @override
  List<Object?> get props => [];

}

class DriverAuthFailureState extends DriverAuthState{
  final String errorMessage;

  DriverAuthFailureState({required this.errorMessage});

  @override
  List<Object?> get props => [];

}