import 'package:shared/models/client_model.dart';

abstract class ClientRepositoryAbstract {
  Future<ClientModel?> getClient(String id);
  Future<ClientModel?> updateClient(ClientModel client);
  Future<ClientModel?> createClient(ClientModel client);
}