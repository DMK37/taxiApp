import 'package:taxiapp/models/user_model.dart';

abstract class AuthRepository {
  Future<UserModel> signIn();
  Future<void> logout();
  Future<bool> isAuthenticated();
}