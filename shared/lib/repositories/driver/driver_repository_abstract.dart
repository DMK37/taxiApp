
import 'package:shared/models/driver_model.dart';

abstract class DriverRepositoryAbstract {
  Future<DriverModel?> getDriver(String id);
  Future<DriverModel?> updateDriver(DriverModel driver);
  Future<DriverModel?> createDriver(DriverModel driver);
}