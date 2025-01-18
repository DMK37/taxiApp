import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:shared/utils/config.dart';

class MapUtils {
  Future<void> goToTheLocation(LatLng location,
      Completer<GoogleMapController> googleMapController) async {
    final GoogleMapController controller = await googleMapController.future;
    await controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: location, zoom: 17)));
  }

  LatLngBounds calculateBounds(List<LatLng> polylineCoordinates) {
    double southWestLat = polylineCoordinates.first.latitude;
    double southWestLng = polylineCoordinates.first.longitude;
    double northEastLat = polylineCoordinates.first.latitude;
    double northEastLng = polylineCoordinates.first.longitude;

    for (LatLng point in polylineCoordinates) {
      if (point.latitude < southWestLat) southWestLat = point.latitude;
      if (point.longitude < southWestLng) southWestLng = point.longitude;
      if (point.latitude > northEastLat) northEastLat = point.latitude;
      if (point.longitude > northEastLng) northEastLng = point.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(southWestLat, southWestLng),
      northeast: LatLng(northEastLat, northEastLng),
    );
  }

  Future<(Polyline, int)> getPolyline(LatLng origin, LatLng destination) async {
    PolylinePoints polylinePoints = PolylinePoints();

    final result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: mapsApiKey,
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

    final id = const PolylineId("route");
    return (
      Polyline(
          polylineId: id,
          color: Colors.black,
          points: polylineCoordinates,
          width: 5),
      result.totalDistanceValue!
    );
  }
}
