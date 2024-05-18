import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  UserModel.fromSnapshot(DocumentSnapshot snapshot)
      : assert(snapshot.data() != null) {
    final data = snapshot.data()!;
    _name = data[NAME];
    _email = data[EMAIL];
    _id = data[ID];
    _phone = data[PHONE];
    _token = data[TOKEN];
    _photo = data[TOKEN];
    _votes = data[VOTES];
    _trips = data[TRIPS];
    _rating = data[RATING];
  }
  static const ID = 'id';
  static const NAME = 'name';
  static const EMAIL = 'email';
  static const PHONE = 'phone';
  static const VOTES = 'votes';
  static const TRIPS = 'trips';
  static const RATING = 'rating';
  static const TOKEN = 'token';
  static const PHOTO = 'photo';

  late String _id;
  late String _name;
  late String? _email;
  late String? _phone;
  late String _token;
  late String _photo;

  late int _votes;
  late int _trips;
  late double _rating;

//  getters
  String get name => _name;
  String? get email => _email;
  String get id => _id;
  String? get phone => _phone;
  int get votes => _votes;
  int get trips => _trips;
  double get rating => _rating;
  String get token => _token;
  String get photo => _photo;
}
