import 'package:flutter/material.dart';

Color primaryColor = const Color.fromARGB(255, 16, 56, 91);
Color primaryColorDark = const Color.fromARGB(255, 184, 215, 237);

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  primaryColor: primaryColor,
  canvasColor: Colors.white,
  //backgroundColor: const Color.fromARGB(255, 216, 229, 253),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.all(primaryColor),
      padding: WidgetStateProperty.all(
        const EdgeInsets.symmetric(
          horizontal: 24.0,
          vertical: 12.0,
        ),
      ),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.0),
        ),
      ),
    ),
  ),
  textTheme: TextTheme(
    titleMedium: const TextStyle(
      fontSize: 16.0,
      fontWeight: FontWeight.bold,
    ),
    titleLarge: TextStyle(
      fontSize: 24.0,
      fontWeight: FontWeight.bold,
      color: primaryColor,
    ),
    labelMedium: const TextStyle(
      fontSize: 18.0,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    labelSmall: const TextStyle(
      fontSize: 14.0,
      letterSpacing: 0.6,
    ),
    bodyLarge: const TextStyle(
      fontSize: 32.0,
      fontWeight: FontWeight.bold,
      // color: Colors.white,
    ),
    bodySmall: TextStyle(
      fontSize: 20.0,
      fontWeight: FontWeight.bold,
      color: primaryColor,
    ),
    headlineLarge: TextStyle(
      fontSize: 24.0,
      fontWeight: FontWeight.bold,
      color: primaryColor,
    ),
    displaySmall: TextStyle(
      fontSize: 16.0,
      fontWeight: FontWeight.bold,
      color: primaryColor.withOpacity(0.8),
    ),
  ),
);

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  primaryColor: primaryColorDark,
  //backgroundColor: const Color.fromARGB(255, 21, 25, 44),
  canvasColor: const Color.fromARGB(255, 13, 10, 24),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      padding: WidgetStateProperty.all(
        const EdgeInsets.symmetric(
          horizontal: 24.0,
          vertical: 12.0,
        ),
      ),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.0),
        ),
      ),
      backgroundColor: WidgetStateProperty.all(primaryColorDark),
      foregroundColor: WidgetStateProperty.all(Colors.black),
      overlayColor: WidgetStateProperty.all(Colors.black26),
    ),
  ),
  textTheme: const TextTheme(
    titleMedium: TextStyle(
      fontSize: 16.0,
      fontWeight: FontWeight.bold,
    ),
    titleLarge: TextStyle(
      fontSize: 24.0,
      fontWeight: FontWeight.bold,
    ),
    labelMedium: TextStyle(
      fontSize: 18.0,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
    labelSmall: TextStyle(
      fontSize: 14.0,
      letterSpacing: 0.6,
    ),
    bodyLarge: TextStyle(
      fontSize: 32.0,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    bodySmall: TextStyle(
      fontSize: 20.0,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    headlineLarge: TextStyle(
      fontSize: 24.0,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    displaySmall: TextStyle(
      fontSize: 16.0,
      fontWeight: FontWeight.bold,
      color: Colors.white70,
    ),
  ),
);
