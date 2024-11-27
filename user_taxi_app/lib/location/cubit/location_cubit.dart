import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:taxiapp/firebase/data_providers/client_location_dp.dart';
import 'package:taxiapp/location/cubit/location_state.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class LocationCubit extends Cubit<LocationState> {
  LocationCubit() : super(LocationLoadingState());
  PolylinePoints polylinePoints = PolylinePoints();
  static const String placesApiKey = "AIzaSyAJI-buaRrNN3x2RASJk6yv_UltK2fePzM";
  Timer? _locationTimer;
  ClientLocationDataProvider provider = ClientLocationDataProvider();

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
      if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) {
        emit(NoPermissionState());
        return;
      }
    }

    await getLocation();
  }

  Future<(LatLng, String)> getLocation() async {
    final currentPosition = await Geolocator.getCurrentPosition();

    final data = await placemarkFromCoordinates(currentPosition.latitude, currentPosition.longitude);

    final street = "${data[0].street}, ${data[0].locality}";
    emit(LocationSuccessState(location: LatLng(currentPosition.latitude, currentPosition.longitude), address: street));

    return (LatLng(currentPosition.latitude, currentPosition.longitude), street);
  }

  Future<List<dynamic>> getAutoCompleteSuggestions(String input) async {
    final location = await getLocation();

    List<dynamic> placeList = [];
    String baseURL = 'https://maps.googleapis.com/maps/api/place/autocomplete/json';

    String request =
        '$baseURL?input=$input&key=$placesApiKey&location=${location.$1.latitude}%2C${location.$1.longitude}&radius=50000&strictbounds=true';
    try {
      var response = await http.get(Uri.parse(request));

      if (response.statusCode == 200) {
        placeList = json.decode(response.body)['predictions'];
        placeList = placeList.map((e) => {'description': e['description'], 'place_id': e['place_id']}).toList();
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

    String request = '$baseURL?place_id=$placeId&key=$placesApiKey';

    try {
      var response = await http.get(Uri.parse(request));

      if (response.statusCode == 200) {
        var data = json.decode(response.body)['result']['geometry']['location'];
        final location = LatLng(data['lat'], data['lng']);
        final address = json.decode(response.body)['result']['formatted_address'];
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

  Future<(Polyline, int)> getPolyline(LatLng origin, LatLng destination) async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: placesApiKey,
      request: PolylineRequest(
        origin: PointLatLng(origin.latitude, origin.longitude),
        destination: PointLatLng(destination.latitude, destination.longitude),
        mode: TravelMode.driving,
      ),
    );
    List<LatLng> polylineCoordinates = [];

    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
    }

    PolylineId id = const PolylineId("route");
    return (
      Polyline(polylineId: id, color: Colors.black, points: polylineCoordinates, width: 5),
      result.totalDistanceValue!
    );
  }

  startLocationUpdate(String clientId) async {
    final clientLocation = await getLocation();

    provider.setClientCurrenLocation(clientLocation.$1, clientId);
    _locationTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      provider.setClientCurrenLocation(clientLocation.$1, clientId);
    });
  }

  stopLocationUpdate(String clientId) async {
    _locationTimer?.cancel();
    provider.removeActiveClient(clientId);
  }
}
