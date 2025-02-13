import 'package:shared/models/car_type.dart';
import 'package:shared/models/driver_model.dart';
import 'package:shared/repositories/driver/driver_repository_abstract.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared/utils/config.dart';

class DriverRepository implements DriverRepositoryAbstract {
  @override
  Future<DriverModel?> createDriver(DriverModel driver) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrlDriver),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(driver.toJson()),
      );

      if (response.statusCode == 201) {
        print("Driver created successfully");
        return driver;
      } else {
        print("Failed to create driver: ${response.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
    }
    return null;
  }

  @override
  Future<DriverModel?> getDriver(String id) async {
    try {
      final response = await http.get(Uri.parse('$apiUrlDriver/$id'));

      if (response.statusCode == 200) {
        print("Driver fetched successfully");
        final json = jsonDecode(response.body);
        return DriverModel.fromJson(json);
      } else {
        print("Failed to fetch driver: ${response.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
    }
    return null;
  }

  @override
  Future<DriverModel?> updateDriver(DriverModel driver) async {
    try {
      final response = await http.put(
        Uri.parse('$apiUrlDriver'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(driver.toJson()),
      );

      if (response.statusCode == 200) {
        print("Driver updated successfully");
        final json = jsonDecode(response.body);
        return DriverModel.fromJson(json);
      } else {
        print("Failed to update driver: ${response.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
    }
    return null;
  }

  Future<List<CarType>> getCarTypes() async {
    try {
      final response = await http.get(Uri.parse('$apiUrlDriver/car-types'));

      if (response.statusCode == 200) {
        print("Car types fetched successfully");
        final json = jsonDecode(response.body);
        return json.map<CarType>((type) => type).toList();
      } else {
        print("Failed to fetch client: ${response.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
    }
    return [];
  }
}
