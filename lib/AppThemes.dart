import 'package:flutter/material.dart';

class AppThemes
{
  static final lightTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
    useMaterial3: true,
  );
  static final darkTheme = ThemeData(
    scaffoldBackgroundColor: Colors.grey.shade900,
    focusColor: Colors.white,
    textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.white), bodySmall: TextStyle(color: Colors.black), displayMedium: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w400, height: 1.6, ), displaySmall: TextStyle(color: Colors.white, fontSize: 16), displayLarge: TextStyle(color: Colors.white, fontSize: 24)),
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.green,),
    useMaterial3: true,
  );

}