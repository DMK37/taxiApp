import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared/models/client_model.dart';
import 'package:shared/models/ride_price_model.dart';

abstract class ClientRepositoryAbstract {
  Future<ClientModel?> getClient(String id);
  Future<ClientModel?> updateClient(ClientModel client);
  Future<ClientModel?> createClient(ClientModel client);

  Future<List<RidePriceModel>?> getPrices(LatLng source, LatLng destination, int distance);
}