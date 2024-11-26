import 'package:equatable/equatable.dart';
import 'package:shared/models/driver_model.dart';

abstract class DriverAuthState extends Equatable {}

class DriverAuthenticatedState extends DriverAuthState {
  final DriverModel driver;

  DriverAuthenticatedState({required this.driver});

  @override
  List<Object?> get props => [];
}

class DriverUnauthenticatedState extends DriverAuthState {
  @override
  List<Object?> get props => [];
}

class DriverAuthLoadingState extends DriverAuthState {
  @override
  List<Object?> get props => [];
}

class DriverAuthFailureState extends DriverAuthState {
  final String errorMessage;

  DriverAuthFailureState({required this.errorMessage});

  @override
  List<Object?> get props => [];
}

class DriverRegisterState extends DriverAuthState {
  final String address;

  DriverRegisterState({required this.address});

  @override
  List<Object?> get props => [];
}
