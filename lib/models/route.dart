import 'package:flutter/cupertino.dart';

class RouteModel {
  RouteModel({
    @required this.points,
    @required this.distance,
    @required this.timeNeeded,
    @required this.startAddress,
    @required this.endAddress,
  });
  final String points;
  final Distance distance;
  final TimeNeeded timeNeeded;
  final String startAddress;
  final String endAddress;
}

class Distance {
  Distance.fromMap(Map data) {
    text = data['text'];
    value = data['value'];
  }
  String text;
  int value;
}

class TimeNeeded {
  TimeNeeded.fromMap(Map data) {
    text = data['text'];
    value = data['value'];
  }
  String text;
  int value;
}
