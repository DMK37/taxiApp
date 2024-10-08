import 'package:taxiapp/models/user_model.dart';

abstract class AuthState {}

class AuthenticatedState extends AuthState {
  final UserModel user;

  AuthenticatedState({required this.user});
}

class UnauthenticatedState extends AuthState {}

class AuthLoadingState extends AuthState {}

class AuthFailureState extends AuthState {
  final String errorMessage;

  AuthFailureState({required this.errorMessage});
}