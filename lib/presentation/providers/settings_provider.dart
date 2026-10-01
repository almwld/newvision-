import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  static const _darkKey = 'settings.dark';
  static const _langKey = 'settings.language';
  static const _dwellKey = 'settings.dwellMs';

  bool darkMode = false;
  Locale locale = const Locale('ar');
  int dwellMs = 900;

  Future<void> load() async {
    final preferences = await SharedPreferences.getInstance();
    darkMode = preferences.getBool(_darkKey) ?? false;
    final language = preferences.getString(_langKey) ?? 'ar';
    locale = language == 'en' ? const Locale('en') : const Locale('ar');
    dwellMs = (preferences.getInt(_dwellKey) ?? 900).clamp(500, 2000);
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    darkMode = value;
    notifyListeners();
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_darkKey, value);
  }

  Future<void> setLanguage(String value) async {
    locale = value == 'en' ? const Locale('en') : const Locale('ar');
    notifyListeners();
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_langKey, locale.languageCode);
  }

  Future<void> setDwellMs(int value) async {
    dwellMs = value.clamp(500, 2000);
    notifyListeners();
    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt(_dwellKey, dwellMs);
  }
}
