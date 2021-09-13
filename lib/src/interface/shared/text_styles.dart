import 'package:flutter/material.dart';

class TextStyles {
  TextStyle regular({Color color, double fontSize, double letterSpacing}) {
    return TextStyle(
      color: color ?? Colors.black,
      fontSize: fontSize ?? 14,
      letterSpacing: letterSpacing ?? 0,
    );
  }

  TextStyle light({Color color, double fontSize, double letterSpacing}) {
    return TextStyle(
      color: color ?? Colors.black,
      fontSize: fontSize ?? 14,
      fontWeight: FontWeight.w300,
      letterSpacing: letterSpacing ?? 0,
    );
  }

  TextStyle medium({Color color, double fontSize, double letterSpacing}) {
    return TextStyle(
      color: color ?? Colors.black,
      fontSize: fontSize ?? 14,
      fontWeight: FontWeight.w500,
      letterSpacing: letterSpacing ?? 0,
    );
  }

  TextStyle bold({Color color, double fontSize, double letterSpacing}) {
    return TextStyle(
      color: color ?? Colors.black,
      fontSize: fontSize ?? 14,
      fontWeight: FontWeight.bold,
      letterSpacing: letterSpacing ?? 0,
    );
  }
}
