// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class AppTheme {
  // Colors
  static const Color primaryColor = Color(0xFF00B4DB); // Cyan
  static const Color secondaryColor = Color.fromARGB(255, 1, 36, 97); // Biru muda
  static const Color darkPurple = Color.fromARGB(255, 10, 1, 20); // Ungu tua
  
  // Basic Colors
  static const Color white = Colors.white;
  static const Color white70 = Color.fromRGBO(255, 255, 255, 0.7);
  static const Color white80 = Color.fromRGBO(255, 255, 255, 0.8);
  static const Color white60 = Color.fromRGBO(255, 255, 255, 0.6);
  static const Color white40 = Color.fromRGBO(255, 255, 255, 0.4);
  static const Color white30 = Color.fromRGBO(255, 255, 255, 0.3);
  static const Color white20 = Color.fromRGBO(255, 255, 255, 0.2);
  static const Color white15 = Color.fromRGBO(255, 255, 255, 0.15);
  static const Color white10 = Color.fromRGBO(255, 255, 255, 0.1);
  static const Color white05 = Color.fromRGBO(255, 255, 255, 0.05);

  // Status Colors
  static const Color red = Color(0xFFEF5350);
  static const Color green = Color(0xFF4CAF50);
  static const Color blue = Color(0xFF2196F3);
  static const Color yellow = Color(0xFFFFEB3B);
  static const Color orange = Color(0xFFFF9800);
  static const Color purple = Color(0xFF9C27B0);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color dark = Color(0xFF212121);

  // Gradients
  static Gradient backgroundGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [darkPurple, secondaryColor, primaryColor],
    stops: [0.0, 0.5, 1.0],
    tileMode: TileMode.clamp,
  );

  static Gradient headerGradient = LinearGradient(
    colors: [Colors.black.withOpacity(0.3), Colors.transparent],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static Gradient circleGradient = const LinearGradient(
    colors: [white20, white10],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static Gradient glassGradient = const LinearGradient(
    colors: [white15, white05],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Decorations
  static BoxDecoration glassDecoration({
    double borderRadius = 24,
    double borderWidth = 1,
    double shadowBlur = 20,
    double shadowSpread = 2,
  }) {
    return BoxDecoration(
      color: white15,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: white20,
        width: borderWidth,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: shadowBlur,
          spreadRadius: shadowSpread,
        ),
      ],
    );
  }

  static BoxDecoration circleDecoration = BoxDecoration(
    shape: BoxShape.circle,
    gradient: circleGradient,
    border: Border.all(
      color: white30,
      width: 2,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.2),
        blurRadius: 15,
        spreadRadius: 2,
      ),
    ],
  );

  // Text Styles
  static TextStyle headlineStyle = const TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: white,
    letterSpacing: 0.5,
  );

  static TextStyle subtitleStyle = const TextStyle(
    fontSize: 14,
    color: white80,
  );

  static TextStyle bodyStyle = const TextStyle(
    fontSize: 12,
    color: white60,
  );

  static TextStyle buttonTextStyle = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  static TextStyle linkTextStyle = const TextStyle(
    color: white,
    fontWeight: FontWeight.w600,
    decoration: TextDecoration.underline,
  );

  // Input Decoration
  static InputDecoration textFieldDecoration({
    required String labelText,
    required IconData prefixIcon,
    Widget? suffixIcon,
    bool isPassword = false,
    double borderRadius = 12,
  }) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: const TextStyle(color: white80),
      prefixIcon: Icon(prefixIcon, color: white80),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: white30),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: white30),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: white, width: 1.5),
      ),
      filled: true,
      fillColor: white10,
    );
  }

  // Button Styles
  static ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: white,
    foregroundColor: blue,
    minimumSize: const Size(double.infinity, 52),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    elevation: 5,
    shadowColor: white70.withOpacity(0.5),
  );

  // SnackBar Style
  static SnackBar snackBar({
    required String content,
    required Color backgroundColor,
    Duration? duration,
  }) {
    return SnackBar(
      content: Text(content),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      duration: duration ?? const Duration(seconds: 3),
    );
  }

  // Divider Style
  static Widget divider = Container(
    width: 40,
    height: 1,
    color: white40,
  );

  // Icon Style
  static Icon decorativeIcon(IconData icon) {
    return Icon(
      icon,
      color: white40,
      size: 20,
    );
  }
}