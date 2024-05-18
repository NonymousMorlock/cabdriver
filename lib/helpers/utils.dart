import 'package:flutter/material.dart';

abstract class Utils {
  static void showSnackBar(BuildContext context, {required String message}) {
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message)),
      );
  }
}
