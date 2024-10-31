import 'package:driver_taxi_app/auth/repository/auth_repository.dart';
import 'package:driver_taxi_app/models/driver.dart';

class MetamaskDriverRepository implements DriverAuthRepository {

  @override
  Future<DriverModel> signIn() async {
    return DriverModel(
      walletId: "0x1234567890",
    );
  }

  @override
  Future<bool> isAuthenticated() async {
    return true;
  }
  
  @override
  Future<bool> signOut() async {
    return true;
  }

}