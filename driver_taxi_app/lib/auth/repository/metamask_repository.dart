import 'package:driver_taxi_app/auth/repository/auth_repository.dart';
import 'package:driver_taxi_app/models/driver.dart';
//import 'package:flutter/services.dart';

class MetamaskDriverRepository implements DriverAuthRepository {
  //static const platform = MethodChannel('metamask');
  @override
  Future<DriverModel> signIn() async {
    //await platform.invokeMethod('connectToMetaMask');
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