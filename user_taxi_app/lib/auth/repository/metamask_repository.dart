import 'package:taxiapp/auth/repository/auth_repository.dart';
import 'package:taxiapp/models/user_model.dart';

class MetamaskRepository implements AuthRepository {
  @override
  Future<void> logout() async {}

  @override
  Future<UserModel> signIn() async {
    return UserModel(
      walletId: "0x1234567890",
    );
  }

  @override
  Future<bool> isAuthenticated() async {
    return true;
  }
}
