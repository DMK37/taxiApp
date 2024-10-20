
import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  colorScheme: const ColorScheme.light(
    primary: Colors.black,
    secondary: Color.fromARGB(255, 203, 203, 203),
    tertiary: Color.fromRGBO(0, 87, 125, 0.698),
    surface: Colors.white,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    elevation: 0.0,
    scrolledUnderElevation: 0.0,
    centerTitle: true,
  ),
  bottomAppBarTheme:  BottomAppBarTheme(
    shadowColor: Colors.grey[100],
  ),
  inputDecorationTheme: InputDecorationTheme(
    enabledBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Color.fromRGBO(0, 0, 0, 0.4)),
      borderRadius: BorderRadius.circular(10.0),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Color.fromRGBO(0,0,0, 0.6)),
      borderRadius: BorderRadius.circular(10.0),
    ),
    filled: true,
    fillColor:  const Color.fromARGB(255, 250, 250, 250),
    hintStyle: const TextStyle(color: Color.fromRGBO(0, 0, 0, 0.4)),
  ),
  textTheme: const TextTheme(
    headlineMedium: TextStyle(
      fontSize: 17.0,
      color: Colors.black,
      fontWeight: FontWeight.bold,
    ),
    titleLarge: TextStyle(
      fontSize: 27.0,
      color: Colors.black,
      fontWeight: FontWeight.bold,
    ),
    titleMedium: TextStyle(
      fontSize: 20.0,
      color: Colors.black,
      fontWeight: FontWeight.bold,
    ),
    titleSmall: TextStyle(
      fontSize: 15.0,
      color: Colors.black,
      fontWeight: FontWeight.bold,
    ),
    bodyMedium: TextStyle(
      fontSize: 15.0,
      color: Colors.black,
    ),
    bodyLarge: TextStyle(
      fontSize: 18.0,
      color: Colors.black,
    ),
    labelLarge: TextStyle(
      fontSize: 18.0,
      color: Color.fromRGBO(158, 158, 158, 1),
    ),
    displayMedium: TextStyle(
      fontSize: 16.0,
      color: Colors.black,
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      backgroundColor:  const Color.fromRGBO(0, 125, 66, 0.7),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(50.0),
    ),
    ), 
    
  ),

);