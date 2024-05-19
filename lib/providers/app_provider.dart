import 'dart:async';
import 'dart:typed_data';

import 'package:cabdriver/helpers/constants.dart';
import 'package:cabdriver/locators/service_locator.dart';
import 'package:cabdriver/models/ride_Request.dart';
import 'package:cabdriver/models/rider.dart';
import 'package:cabdriver/models/route.dart';
import 'package:cabdriver/services/map_requests.dart';
import 'package:cabdriver/services/ride_request.dart';
import 'package:cabdriver/services/rider.dart';
import 'package:cabdriver/services/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

enum Show { RIDER, TRIP }

typedef GeoLocation = geocoding.Location;
typedef GeoPlaceMark = geocoding.Placemark;

class AppStateProvider with ChangeNotifier {
  AppStateProvider() {
//    _subscribeUser();
    _saveDeviceToken();
    FirebaseMessaging.onMessage.listen(handleOnMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handleOnLaunch);
    FirebaseMessaging.onBackgroundMessage(handleOnResume);
//     fcm.configure(
// //      this callback is used when the app runs on the foreground
//       onMessage: handleOnMessage,
// //        used when the app is closed completely and is launched using the notification
//       onLaunch: handleOnLaunch,
// //        when its on the background and opened using the notification drawer
//       onResume: handleOnResume,
//     );
    _getUserLocation();
    Geolocator.getPositionStream().listen(_userCurrentLocationUpdate);
  }

  static const ACCEPTED = 'accepted';
  static const CANCELLED = 'cancelled';
  static const PENDING = 'pending';
  static const EXPIRED = 'expired';

  // ANCHOR: VARIABLES DEFINITION

  GoogleMapController? _mapController;
  Position? position;
  RouteModel? routeModel;
  RideRequestModel? rideRequestModel;
  RequestModelFirebase? requestModelFirebase;
  SharedPreferences prefs = locator<SharedPreferences>();
  Timer? periodicTimer;
  Show show = Show.RIDER;
  RiderModel? riderModel;
  StreamSubscription<QuerySnapshot>? requestStream;
  static LatLng? _center;
  LatLng? _lastPosition = _center;
  Set<Marker> _markers = {};
  Set<Polyline> _poly = {};
  final TextEditingController _locationController = TextEditingController();
  TextEditingController destinationController = TextEditingController();
  final GoogleMapsServices _googleMapsServices = GoogleMapsServices();

  LatLng? get center => _center;

  LatLng? get lastPosition => _lastPosition;

  TextEditingController get locationController => _locationController;

  Set<Marker> get markers => _markers;

  Set<Polyline> get poly => _poly;

  GoogleMapController? get mapController => _mapController;

  Location location = Location();
  bool hasNewRideRequest = false;
  final UserServices _userServices = UserServices();

  final RiderServices _riderServices = RiderServices();
  double distanceFromRider = 0;
  double totalRideDistance = 0;
  int timeCounter = 0;
  double percentage = 0;

  final RideRequestServices _requestServices = RideRequestServices();

  // ANCHOR LOCATION METHODS
  _userCurrentLocationUpdate(Position updatedPosition) async {
    final lat = prefs.getDouble('lat');
    final lng = prefs.getDouble('lng');
    if (lat == null || lng == null) return;
    final distance = Geolocator.distanceBetween(
      lat,
      lng,
      updatedPosition.latitude,
      updatedPosition.longitude,
    );
    var values = <String, dynamic>{
      'id': prefs.getString('id'),
      'position': updatedPosition.toJson(),
    };
    if (distance >= 50) {
      if (show == Show.RIDER && requestModelFirebase != null) {
        sendRequest(coordinates: requestModelFirebase!.getCoordinates());
      }
      _userServices.updateUserData(values);
      await prefs.setDouble('lat', updatedPosition.latitude);
      await prefs.setDouble('lng', updatedPosition.longitude);
    }
  }

  _getUserLocation() async {
    prefs = await SharedPreferences.getInstance();
    position = await Geolocator.getCurrentPosition();
    final List<GeoPlaceMark> placemark =
        await geocoding.placemarkFromCoordinates(
      position!.latitude,
      position!.longitude,
    );
    _center = LatLng(position!.latitude, position!.longitude);
    await prefs.setDouble('lat', position!.latitude);
    await prefs.setDouble('lng', position!.longitude);
    if (placemark.first.name != null) {
      _locationController.text = placemark.first.name!;
    }
    notifyListeners();
  }

  // ANCHOR MAPS METHODS

  onCreate(GoogleMapController controller) {
    _mapController = controller;
    notifyListeners();
  }

  setLastPosition(LatLng position) {
    _lastPosition = position;
    notifyListeners();
  }

  onCameraMove(CameraPosition position) {
    _lastPosition = position.target;
    notifyListeners();
  }

  Future<void> sendRequest({
    String? intendedLocation,
    required LatLng coordinates,
  }) async {
    if (position == null) return;
    final origin = LatLng(position!.latitude, position!.longitude);

    final destination = coordinates;
    final route =
        await _googleMapsServices.getRouteByCoordinates(origin, destination);
    routeModel = route;
    addLocationMarker(
      destination,
      routeModel!.endAddress,
      routeModel!.distance.text,
    );
    _center = destination;
    destinationController.text = routeModel!.endAddress;

    _createRoute(route.points);
    notifyListeners();
  }

  void _createRoute(String decodeRoute) {
    _poly = {};
    const uuid = Uuid();
    final polyId = uuid.v1();
    poly.add(
      Polyline(
        polylineId: PolylineId(polyId),
        width: 8,
        onTap: () {},
        points: _convertToLatLong(_decodePoly(decodeRoute)),
      ),
    );
    notifyListeners();
  }

  List<LatLng> _convertToLatLong(List points) {
    final result = <LatLng>[];
    for (var i = 0; i < points.length; i++) {
      if (i % 2 != 0) {
        result.add(LatLng(points[i - 1], points[i]));
      }
    }
    return result;
  }

  List _decodePoly(String poly) {
    final list = poly.codeUnits;
    final lList = [];
    var index = 0;
    var len = poly.length;
    var c = 0;
// repeating until all attributes are decoded
    do {
      var shift = 0;
      var result = 0;

      // for decoding value of one attribute
      do {
        c = list[index] - 63;
        result |= (c & 0x1F) << (shift * 5);
        index++;
        shift++;
      } while (c >= 32);
      /* if value is negetive then bitwise not the value */
      if (result & 1 == 1) {
        result = ~result;
      }
      final result1 = (result >> 1) * 0.00001;
      lList.add(result1);
    } while (index < len);

/*adding to previous value as done in encoding */
    for (var i = 2; i < lList.length; i++) {
      lList[i] += lList[i - 2];
    }

    print(lList);

    return lList;
  }

  // ANCHOR MARKERS
  addLocationMarker(LatLng position, String destination, String distance) {
    _markers = {};
    const uuid = Uuid();
    var markerId = uuid.v1();
    _markers.add(
      Marker(
        markerId: MarkerId(markerId),
        position: position,
        infoWindow: InfoWindow(title: destination, snippet: distance),
      ),
    );
    notifyListeners();
  }

  Future<Uint8List> getMarker(BuildContext context) async {
    final byteData =
        await DefaultAssetBundle.of(context).load('images/car.png');
    return byteData.buffer.asUint8List();
  }

  clearMarkers() {
    _markers.clear();
    notifyListeners();
  }

  _saveDeviceToken() async {
    prefs = await SharedPreferences.getInstance();
    if (prefs.getString('token') == null) {
      final deviceToken = await fcm.getToken();
      if (deviceToken != null) await prefs.setString('token', deviceToken);
    }
  }

// ANCHOR PUSH NOTIFICATION METHODS
  Future handleOnMessage(RemoteMessage message) async {
    _handleNotificationData(message.data);
  }

  Future handleOnLaunch(RemoteMessage message) async {
    _handleNotificationData(message.data);
  }

  Future handleOnResume(RemoteMessage message) async {
    _handleNotificationData(message.data);
  }

  _handleNotificationData(Map<String, dynamic> data) async {
    hasNewRideRequest = true;
    rideRequestModel = RideRequestModel.fromMap(data['data']);
    riderModel = await _riderServices.getRiderById(rideRequestModel!.userId);
    notifyListeners();
  }

// ANCHOR RIDE REQUEST METHODS
  changeRideRequestStatus() {
    hasNewRideRequest = false;
    notifyListeners();
  }

  listenToRequest({required String id, required BuildContext context}) async {
//    requestModelFirebase = await _requestServices.getRequestById(id);
    print('======= LISTENING =======');
    requestStream = _requestServices.requestStream().listen((querySnapshot) {
      for (final doc in querySnapshot.docChanges) {
        final data = doc.doc.data() as Map<String, dynamic>?;
        if (data?['id'] == id) {
          requestModelFirebase = RequestModelFirebase.fromSnapshot(doc.doc);
          notifyListeners();
          switch (data?['status']) {
            case CANCELLED:
              print('====== CANCELELD');
            case ACCEPTED:
              print('====== ACCEPTED');
            case EXPIRED:
              print('====== EXPIRED');
            default:
              print('==== PEDING');
              break;
          }
        }
      }
    });
  }

  //  Timer counter for driver request
  percentageCounter(
      {required String requestId, required BuildContext context}) {
    notifyListeners();
    periodicTimer = Timer.periodic(const Duration(seconds: 1), (time) {
      timeCounter = timeCounter + 1;
      percentage = timeCounter / 100;
      print('====== GOOOO $timeCounter');
      if (timeCounter == 100) {
        timeCounter = 0;
        percentage = 0;
        time.cancel();
        hasNewRideRequest = false;
        requestStream?.cancel();
      }
      notifyListeners();
    });
  }

  acceptRequest({required String requestId, required String driverId}) {
    hasNewRideRequest = false;
    _requestServices.updateRequest(
      {'id': requestId, 'status': 'accepted', 'driverId': driverId},
    );
    notifyListeners();
  }

  cancelRequest({required String requestId}) {
    hasNewRideRequest = false;
    _requestServices.updateRequest({'id': requestId, 'status': 'cancelled'});
    notifyListeners();
  }

  //  ANCHOR UI METHODS
  changeWidgetShowed({required Show showWidget}) {
    show = showWidget;
    notifyListeners();
  }
}
