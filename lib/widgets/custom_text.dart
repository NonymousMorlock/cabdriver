import 'package:cabdriver/helpers/style.dart';
import 'package:flutter/material.dart';

class CustomText extends StatelessWidget {
  // name constructor that has a positional parameters with the text required
  // and the other parameters optional
  const CustomText({
    super.key,
    required this.text,
    this.size,
    this.color,
    this.weight,
  });

  final String text;
  final double? size;
  final Color? color;
  final FontWeight? weight;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: size ?? 16,
        color: color ?? black,
        fontWeight: weight ?? FontWeight.normal,
      ),
    );
  }
}
