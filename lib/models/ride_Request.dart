import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RideRequestModel {
  RideRequestModel.fromMap(Map data) : assert(data[DESTINATION] != null) {
    final String d = data[DESTINATION];
    _id = data[ID];
    _username = data[USERNAME];
    _userId = data[USER_ID];
    _destination = d.substring(0, d.indexOf(','));
    _dLatitude = double.parse(data[DESTINATION_LAT]);
    _dLongitude = double.parse(data[DESTINATION_LNG]);
    _uLatitude = double.parse(data[USER_LAT]);
    _uLongitude = double.parse(data[USER_LAT]);
    _distance = Distance.fromMap({
      'text': data[DISTANCE_TEXT],
      'value': int.parse(data[DISTANCE_VALUE]),
    });
  }

  static const ID = 'id';
  static const USERNAME = 'username';
  static const USER_ID = 'userId';
  static const DESTINATION = 'destination';
  static const DESTINATION_LAT = 'destination_latitude';
  static const DESTINATION_LNG = 'destination_longitude';
  static const USER_LAT = 'user_latitude';
  static const USER_LNG = 'user_longitude';
  static const DISTANCE_TEXT = 'distance_text';
  static const DISTANCE_VALUE = 'distance_value';

  late String _id;
  late String _username;
  late String _userId;
  late String? _destination;
  late double _dLatitude;
  late double _dLongitude;
  late double _uLatitude;
  late double _uLongitude;
  late Distance _distance;

  String get id => _id;

  String get username => _username;

  String get userId => _userId;

  String? get destination => _destination;

  double get dLatitude => _dLatitude;

  double get dLongitude => _dLongitude;

  double get uLatitude => _uLatitude;

  double get uLongitude => _uLongitude;

  Distance get distance => _distance;
}

class Distance {
  Distance.fromMap(Map data) {
    text = data['text'];
    value = data['value'];
  }

  late String text;
  late int value;

  Map toJson() => {'text': text, 'value': value};
}

class RequestModelFirebase {
  RequestModelFirebase.fromSnapshot(DocumentSnapshot snapshot)
      : assert(snapshot.data() != null) {
    final data = snapshot.data()!;
    _id = data[ID];
    _username = data[USERNAME];
    _userId = data[USER_ID];
    _driverId = data[DRIVER_ID];
    _status = data[STATUS];
    _position = data[POSITION];
    _destination = data[DESTINATION];
  }

  static const ID = 'id';
  static const USERNAME = 'username';
  static const USER_ID = 'userId';
  static const DRIVER_ID = 'driverId';
  static const STATUS = 'status';
  static const POSITION = 'position';
  static const DESTINATION = 'destination';

  late String _id;
  late String _username;
  late String _userId;
  late String _driverId;
  late String _status;
  late Map _position;
  late Map _destination;

  String get id => _id;

  String get username => _username;

  String get userId => _userId;

  String get driverId => _driverId;

  String get status => _status;

  Map get position => _position;

  Map get destination => _destination;

  LatLng getCoordinates() =>
      LatLng(_position['latitude'], _position['longitude']);
}
