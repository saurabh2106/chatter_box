import 'package:flutter/material.dart';

class MyAppColors {
  // Primary Colors
  static const Color primaryBlue = Color(0xFF4A86F7);
  static const Color title = Color(0xFF35353D);
  static const Color body = Color(0xFF6A7185);
  static const Color stroke = Color(0xFFE9EDF1);
  static const Color background = Color(0xFFF5F7FA);
  static const Color white = Color(0xFFFFFFFF);

  // Accent Colors
  static const LinearGradient blueGradient = LinearGradient(
    colors: [Color(0xFF4A86F7), Color(0xFF2448B1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Color skyBlue = Color.fromARGB(255, 74, 176, 238);
  static const Color red = Color(0xFFD94841);
  static const Color orange = Color(0xFFF2A84C);
  static const Color green = Color(0xFF83BF6E);

  static const LinearGradient greenGradient = LinearGradient(
    colors: [Color(0xFF73BC78), Color(0xFF438A62)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
