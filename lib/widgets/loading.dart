import 'package:cabdriver/helpers/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatelessWidget {
  const Loading({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: white,
      child: const SpinKitFadingCircle(
        color: black,
        size: 30,
      ),
    );
  }
}
