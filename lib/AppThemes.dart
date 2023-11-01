import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppThemes
{
  static final lightTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
    textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.black), bodySmall: TextStyle(color: Colors.black), displayMedium: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w400, height: 1.6, ), displaySmall: TextStyle(color: Colors.black, fontSize: 16), displayLarge: TextStyle(color: Colors.black, fontSize: 24)),
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

class ThemeProvider extends ChangeNotifier
{
  late ThemeMode themeMode;
  late SharedPreferences prefs;
  static const THEME_KEY = 'theme_key';

  bool get isDarkMode => themeMode == ThemeMode.dark;

  ThemeProvider(SharedPreferences pref)
  {
    prefs = pref;

    bool hasKey = prefs.containsKey(THEME_KEY);

    if (hasKey)
    {
      switch (pref.getBool(THEME_KEY)) {
        case true:
          themeMode = ThemeMode.dark;
          break;
        case false:
          themeMode = ThemeMode.light;
          break;
        default:
          break;
      }
    }
    else
    {
      prefs.setBool(THEME_KEY, true);
      themeMode = ThemeMode.dark;
    }
  }

  void toggleTheme(bool val) async
  {
    themeMode = val ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    prefs.setBool(THEME_KEY, val);
  }
}