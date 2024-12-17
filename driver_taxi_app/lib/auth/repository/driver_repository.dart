// import 'dart:convert';

// import 'package:driver_taxi_app/auth/repository/driver_repository_abstract.dart';
// import 'package:driver_taxi_app/models/driver.dart';
// import 'package:http/http.dart' as http;
// //import 'package:flutter/services.dart';

// class DriverRepository implements DriverAuthRepository {
//   final String apiUrl = "http://192.168.18.81:5112/api/driver";

//   @override
//   Future<DriverModel?> getDriver(String address) async {
//     try {
//       final response = await http.get(Uri.parse('$apiUrl/$address'));

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
//   Future<DriverModel> signIn() async {
//     //await platform.invokeMethod('connectToMetaMask');
//     return DriverModel(
//       walletId: "0x1234567890",
//     );
//   }

//   @override
//   Future<bool> isAuthenticated() async {
//     return true;
//   }
  
//   @override
//   Future<bool> signOut() async {
//     return true;
//   }

// }