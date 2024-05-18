import 'dart:convert';

import 'package:cabdriver/helpers/constants.dart';
import 'package:cabdriver/models/route.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class GoogleMapsServices {
  Future<RouteModel> getRouteByCoordinates(LatLng l1, LatLng l2) async {
    final url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${l1.latitude},${l1.longitude}&destination=${l2.latitude},${l2.longitude}&key=$GOOGLE_MAPS_API_KEY';
    final response = await http.get(url);
    final Map values = jsonDecode(response.body);
    final Map routes = values['routes'][0];
    final Map legs = values['routes'][0]['legs'][0];
    var route = RouteModel(
        points: routes['overview_polyline']['points'],
        distance: Distance.fromMap(legs['distance']),
        timeNeeded: TimeNeeded.fromMap(legs['duration']),
        endAddress: legs['end_address'],
        startAddress: legs['end_address'],);
    return route;
  }
}
