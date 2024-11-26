// import 'dart:convert';
// import 'package:driver_taxi_app/auth/repository/auth_repository.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared/models/driver_model.dart';

// class MetamaskDriverRepository implements DriverAuthRepository {
//   final String apiUrl = "http://192.168.18.81:5112/api/client";

//   @override
//   Future<DriverModel?> getDriver(String id) async {
//     try {
//       final response = await http.get(Uri.parse('$apiUrl/$id'));

//       if (response.statusCode == 200) {
//         print("Driver fetched successfully");
//         final json = jsonDecode(response.body);
//         return DriverModel.fromJson(json);
//       } else {
//         print("Failed to fetch driver: ${response.statusCode}");
//       }
//     } catch (e) {
//       print("Error: $e");
//     }
//     return null;
//   }

//   @override
//   Future<DriverModel?> createDriver(DriverModel driver) async {
//     try {
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: {
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode(driver.toJson()),
//       );

//       if (response.statusCode == 201) {
//         print("Driver created successfully");
//         return driver;
//       } else {
//         print("Failed to create driver: ${response.statusCode}");
//       }
//     } catch (e) {
//       print("Error: $e");
//     }
//     return null;
//   }

//   @override
//   Future<DriverModel?> updateDriver(DriverModel driver) async {
//     try {
//       final response = await http.put(
//         Uri.parse('$apiUrl'),
//         headers: {
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode(driver.toJson()),
//       );

//       if (response.statusCode == 200) {
//         print("Driver updated successfully");
//         final json = jsonDecode(response.body);
//         return DriverModel.fromJson(json);
//       } else {
//         print("Failed to update driver: ${response.statusCode}");
//       }
//     } catch (e) {
//       print("Error: $e");
//     }
//     return null;
//   }
// }