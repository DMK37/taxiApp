import 'package:shared/models/client_model.dart';

abstract class AuthState {}

class AuthenticatedState extends AuthState {
  final ClientModel user;

  AuthenticatedState({required this.user});
}

class UnauthenticatedState extends AuthState {}

class AuthLoadingState extends AuthState {}

class AuthFailureState extends AuthState {
  final String errorMessage;

  AuthFailureState({required this.errorMessage});
}

class FirstLoginState extends AuthState {
  final String address;

  FirstLoginState({required this.address});
}