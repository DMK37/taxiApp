import 'package:flutter/material.dart';

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  colorScheme: const ColorScheme.dark(
    primary: Colors.white,
    secondary: Color.fromARGB(255, 50, 50, 50),
    tertiary: Color.fromRGBO(0, 125, 185, 0.698),
    surface: Color.fromARGB(255, 18, 18, 18),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color.fromARGB(255, 28, 28, 28),
    elevation: 0.0,
    scrolledUnderElevation: 0.0,
    centerTitle: true,
  ),
  bottomAppBarTheme: BottomAppBarTheme(
    shadowColor: Colors.grey[900],
  ),
  inputDecorationTheme: InputDecorationTheme(
    enabledBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Color.fromRGBO(255, 255, 255, 0.4)),
      borderRadius: BorderRadius.circular(10.0),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Color.fromRGBO(255, 255, 255, 0.6)),
      borderRadius: BorderRadius.circular(10.0),
    ),
    filled: true,
    fillColor: const Color.fromARGB(255, 30, 30, 30),
    hintStyle: const TextStyle(color: Color.fromRGBO(255, 255, 255, 0.4)),
  ),
  textTheme: const TextTheme(
    headlineMedium: TextStyle(
      fontSize: 17.0,
      color: Colors.white,
      fontWeight: FontWeight.bold,
    ),
    titleLarge: TextStyle(
      fontSize: 27.0,
      color: Colors.white,
      fontWeight: FontWeight.bold,
    ),
    titleMedium: TextStyle(
      fontSize: 20.0,
      color: Colors.white,
      fontWeight: FontWeight.bold,
    ),
    titleSmall: TextStyle(
      fontSize: 18.0,
      color: Colors.white,
      fontWeight: FontWeight.bold,
    ),
    bodyMedium: TextStyle(
      fontSize: 15.0,
      color: Colors.white,
    ),
    bodyLarge: TextStyle(
      fontSize: 18.0,
      color: Colors.white,
    ),
    labelLarge: TextStyle(
      fontSize: 18.0,
      color: Color.fromRGBO(158, 158, 158, 1),
    ),
    displayMedium: TextStyle(
      fontSize: 16.0,
      color: Colors.white,
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      backgroundColor: const Color.fromRGBO(0, 125, 66, 0.7),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50.0),
      ),
    ),
  ),
);
