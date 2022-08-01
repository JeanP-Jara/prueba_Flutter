import 'package:flutter/material.dart';

class ThemeState with ChangeNotifier{
  
  bool _isDrakModeEnabled = false;  
  Brightness  get currentTheme => _isDrakModeEnabled ? Brightness.dark  : Brightness.light;
  MaterialColor get currentcolor => _isDrakModeEnabled ?  Colors.purple: Colors.blue;
  FloatingActionButtonThemeData get currentButton => _isDrakModeEnabled ?  
    const FloatingActionButtonThemeData(
      foregroundColor: Colors.white,
      backgroundColor: Colors.purple
    ) : const FloatingActionButtonThemeData(
      foregroundColor: Colors.white,
      backgroundColor: Colors.blue
    );
  bool get isDrakModeEnabled => _isDrakModeEnabled;

  void setDarkMode(bool b){
    _isDrakModeEnabled = b;
    notifyListeners();
  }
}