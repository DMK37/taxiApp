import 'dart:convert';

import 'package:shared/models/client_model.dart';
import 'package:shared/repositories/client/client_repository_abstract.dart';
import 'package:http/http.dart' as http;

class ClientRepository implements ClientRepositoryAbstract {
  // mac: 192.168.18.81
  // change for your local ip
  final String apiUrl = "http://192.168.18.81:5112/api/client";

  @override
  Future<ClientModel?> createClient(ClientModel client) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
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
      final response = await http.get(Uri.parse('$apiUrl/$id'));

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
        Uri.parse('$apiUrl'),
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
}
