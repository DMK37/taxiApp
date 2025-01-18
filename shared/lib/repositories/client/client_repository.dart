import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared/models/client_model.dart';
import 'package:shared/models/ride_price_model.dart';
import 'package:shared/repositories/client/client_repository_abstract.dart';
import 'package:http/http.dart' as http;
import 'package:shared/utils/config.dart';

class ClientRepository implements ClientRepositoryAbstract {
  @override
  Future<ClientModel?> createClient(ClientModel client) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrlClient),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(client.toJson()),
      );

      if (response.statusCode == 201) {
        print("Client created successfully");
        return client;
      } else {
        print("Failed to create client: ${response.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
    }
    return null;
  }

  @override
  Future<ClientModel?> getClient(String id) async {
    try {
      final response = await http.get(Uri.parse('$apiUrlClient/$id'));

      if (response.statusCode == 200) {
        print("Client fetched successfully");
        final json = jsonDecode(response.body);
        return ClientModel.fromJson(json);
      } else {
        print("Failed to fetch client: ${response.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
    }
    return null;
  }

  @override
  Future<ClientModel?> updateClient(ClientModel client) async {
    try {
      final response = await http.put(
        Uri.parse('$apiUrlClient'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(client.toJson()),
      );

      if (response.statusCode == 200) {
        print("Client updated successfully");
        final json = jsonDecode(response.body);
        return ClientModel.fromJson(json);
      } else {
        print("Failed to update client: ${response.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
    }
    return null;
  }

  Future<List<RidePriceModel>?> getPrices(
      LatLng source, LatLng destination, int distance) async {
    try {
      final response = await http.get(Uri.parse(
          '$apiUrlClient/prices?source=${source.latitude},${source.longitude}&destination=${destination.latitude},${destination.longitude}&distance=$distance'));

      if (response.statusCode == 200) {
        print("Ride prices fetched successfully");
        final json = jsonDecode(response.body);
        return json
            .map<RidePriceModel>((price) => RidePriceModel.fromJson(price))
            .toList();
      } else {
        print("Failed to fetch client: ${response.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
    }
    return null;
  }
}
