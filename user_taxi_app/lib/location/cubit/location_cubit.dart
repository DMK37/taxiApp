import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared/utils/config.dart';
import 'package:taxiapp/firebase/data_providers/client_location_dp.dart';
import 'package:taxiapp/location/cubit/location_state.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class LocationCubit extends Cubit<LocationState> {
  LocationCubit() : super(LocationLoadingState());
  PolylinePoints polylinePoints = PolylinePoints();
  Timer? _locationTimer;

  Future<void> checkPermissionsAndGetLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      emit(NoPermissionState());
      return;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      emit(NoPermissionState());
      return;
    }
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        emit(NoPermissionState());
        return;
      }
    }

    await getLocation();
  }

  Future<(LatLng, String)> getLocation() async {
    final currentPosition = await Geolocator.getCurrentPosition();

    final data = await placemarkFromCoordinates(
        currentPosition.latitude, currentPosition.longitude);

    final street = "${data[0].street}, ${data[0].locality}";
    emit(LocationSuccessState(
        location: LatLng(currentPosition.latitude, currentPosition.longitude),
        address: street));

    return (
      LatLng(currentPosition.latitude, currentPosition.longitude),
      street
    );
  }

  Future<List<dynamic>> getAutoCompleteSuggestions(String input) async {
    final location = await getLocation();

    List<dynamic> placeList = [];
    String baseURL =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json';

    String request =
        '$baseURL?input=$input&key=$mapsApiKey&location=${location.$1.latitude}%2C${location.$1.longitude}&radius=50000&strictbounds=true';
    try {
      var response = await http.get(Uri.parse(request));

      if (response.statusCode == 200) {
        placeList = json.decode(response.body)['predictions'];
        placeList = placeList
            .map((e) =>
                {'description': e['description'], 'place_id': e['place_id']})
            .toList();
        return placeList;
      } else {
        throw Exception('Failed to load predictions');
      }
    } catch (e) {
      print(e);
    }
    return [];
  }

  Future<LatLng?> getPlaceCoordinates(String placeId) async {
    String baseURL = 'https://maps.googleapis.com/maps/api/place/details/json';

    String request = '$baseURL?place_id=$placeId&key=$mapsApiKey';

    try {
      var response = await http.get(Uri.parse(request));

      if (response.statusCode == 200) {
        var data = json.decode(response.body)['result']['geometry']['location'];
        final location = LatLng(data['lat'], data['lng']);
        final address =
            json.decode(response.body)['result']['formatted_address'];
        emit(LocationSuccessState(location: location, address: address));
        return location;
      } else {
        throw Exception('Failed to load predictions');
      }
    } catch (e) {
      print(e);
    }

    return null;
  }

  startLocationUpdate(String clientId, String ref) async {
    final clientLocation = await getLocation();
    ClientLocationDataProvider provider =
        ClientLocationDataProvider(db: FirebaseDatabase.instance.ref(ref));

    provider.setClientCurrenLocation(clientLocation.$1, clientId);
    _locationTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      provider.setClientCurrenLocation(clientLocation.$1, clientId);
    });
  }

  stopLocationUpdate(String clientId, String ref) async {
    ClientLocationDataProvider provider =
        ClientLocationDataProvider(db: FirebaseDatabase.instance.ref(ref));

    _locationTimer?.cancel();
    provider.removeActiveClient(clientId);
  }
}
