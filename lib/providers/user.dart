import 'dart:async';

import 'package:cabdriver/helpers/constants.dart';
import 'package:cabdriver/models/user.dart';
import 'package:cabdriver/services/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Status { Uninitialized, Authenticated, Authenticating, Unauthenticated }

class UserProvider with ChangeNotifier {
  UserProvider.initialize() {
    _fireSetUp();
  }

  User? _user;
  Status _status = Status.Uninitialized;
  final UserServices _userServices = UserServices();
  UserModel? _userModel;

//  getter
  UserModel? get userModel => _userModel;

  Status get status => _status;

  User? get user => _user;

  // public variables
  final formkey = GlobalKey<FormState>();

  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController phone = TextEditingController();

  _fireSetUp() async {
    await initialization.then((value) {
      auth.authStateChanges().listen(_onStateChanged);
    });
  }

  Future<bool> signIn() async {
    final prefs = await SharedPreferences.getInstance();
    bool result = false;

    try {
      _status = Status.Authenticating;
      notifyListeners();
      await auth
          .signInWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text.trim(),
      )
          .then(
        (value) async {
          if (value.user == null) {
            result = false;
          } else {
            result = true;
            await prefs.setString('id', value.user!.uid);
          }
        },
      );
      return result;
    } catch (e) {
      _status = Status.Unauthenticated;
      notifyListeners();
      print(e);
      return false;
    }
  }

  Future<bool> signUp(Position position) async {
    bool finalResult = false;
    try {
      _status = Status.Authenticating;
      notifyListeners();
      await auth
          .createUserWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text.trim(),
      )
          .then((result) async {
        if (result.user == null) {
          finalResult = false;
        } else {
          final prefs = await SharedPreferences.getInstance();
          final deviceToken = await fcm.getToken();
          if (deviceToken == null) return;
          await prefs.setString('id', result.user!.uid);
          _userServices.createUser(
            id: result.user!.uid,
            name: name.text.trim(),
            email: email.text.trim(),
            phone: phone.text.trim(),
            position: position.toJson(),
            token: deviceToken,
          );
          finalResult = true;
        }
      });
      return finalResult;
    } catch (e) {
      _status = Status.Unauthenticated;
      notifyListeners();
      print(e);
      return false;
    }
  }

  Future signOut() async {
    auth.signOut();
    _status = Status.Unauthenticated;
    notifyListeners();
    return Future.delayed(Duration.zero);
  }

  void clearController() {
    name.text = '';
    password.text = '';
    email.text = '';
    phone.text = '';
  }

  Future<void> reloadUserModel() async {
    if (user == null) return;
    _userModel = await _userServices.getUserById(user!.uid);
    notifyListeners();
  }

  updateUserData(Map<String, dynamic> data) async {
    _userServices.updateUserData(data);
  }

  saveDeviceToken() async {
    final deviceToken = await fcm.getToken();
    if (deviceToken == null || user == null) return;
    _userServices.addDeviceToken(userId: user!.uid, token: deviceToken);
  }

  _onStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) return;
    final prefs = await SharedPreferences.getInstance();
    _user = firebaseUser;
    await prefs.setString('id', firebaseUser.uid);

    _userModel = await _userServices.getUserById(_user!.uid).then((value) {
      _status = Status.Authenticated;
      return value;
    });
    notifyListeners();
  }
}
