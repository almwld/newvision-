import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/native_bridge.dart';

class SettingsProvider extends ChangeNotifier {
  SettingsProvider({NativeBridge? bridge}) : _bridge = bridge ?? NativeBridge();

  static const _darkKey = 'settings.dark';
  static const _langKey = 'settings.language';
  static const _dwellKey = 'settings.dwellMs';

  final NativeBridge _bridge;

  bool darkMode = false;
  Locale locale = const Locale('ar');
  int dwellMs = 900;

  bool gazeZonesEnabled = false;
  bool scrollUpEnabled = false;
  bool scrollDownEnabled = false;
  bool scrollLeftEnabled = false;
  bool scrollRightEnabled = false;
  bool fastClickEnabled = false;
  double edgeThreshold = 0.15;
  int activationMs = 300;
  int cooldownMs = 250;
  int fastClickMs = 250;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    darkMode = prefs.getBool(_darkKey) ?? false;
    locale = Locale(prefs.getString(_langKey) ?? 'ar');
    dwellMs = prefs.getInt(_dwellKey) ?? 900;
    try {
      _applyGazeZones(await _bridge.getGazeZonesSettings());
    } catch (_) {
      // Keep safe local defaults if the native channel is temporarily unavailable.
    }
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    darkMode = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkKey, value);
  }

  Future<void> setLanguage(String value) async {
    locale = Locale(value);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_langKey, value);
  }

  Future<void> setDwellMs(int value) async {
    dwellMs = value.clamp(500, 2000);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_dwellKey, dwellMs);
  }

  Future<void> saveGazeZones() async {
    final data = await _bridge.setGazeZonesSettings(_gazeZonesMap());
    _applyGazeZones(data);
    notifyListeners();
  }

  Future<void> resetGazeZones() async {
    final data = await _bridge.resetGazeZonesSettings();
    _applyGazeZones(data);
    notifyListeners();
  }

  void toggleGazeZones(bool value) {
    gazeZonesEnabled = value;
    notifyListeners();
  }

  void toggleScrollUp(bool value) { scrollUpEnabled = value; notifyListeners(); }
  void toggleScrollDown(bool value) { scrollDownEnabled = value; notifyListeners(); }
  void toggleScrollLeft(bool value) { scrollLeftEnabled = value; notifyListeners(); }
  void toggleScrollRight(bool value) { scrollRightEnabled = value; notifyListeners(); }
  void toggleFastClick(bool value) { fastClickEnabled = value; notifyListeners(); }

  void setFastClickMs(double value) {
    fastClickMs = value.round().clamp(150, 500);
    notifyListeners();
  }

  Map<String, dynamic> _gazeZonesMap() => {
        'enabled': gazeZonesEnabled,
        'scrollUpEnabled': scrollUpEnabled,
        'scrollDownEnabled': scrollDownEnabled,
        'scrollLeftEnabled': scrollLeftEnabled,
        'scrollRightEnabled': scrollRightEnabled,
        'fastClickEnabled': fastClickEnabled,
        'edgeThreshold': edgeThreshold,
        'activationMs': activationMs,
        'cooldownMs': cooldownMs,
        'fastClickMs': fastClickMs,
      };

  void _applyGazeZones(Map<String, dynamic> data) {
    gazeZonesEnabled = data['enabled'] as bool? ?? false;
    scrollUpEnabled = data['scrollUpEnabled'] as bool? ?? false;
    scrollDownEnabled = data['scrollDownEnabled'] as bool? ?? false;
    scrollLeftEnabled = data['scrollLeftEnabled'] as bool? ?? false;
    scrollRightEnabled = data['scrollRightEnabled'] as bool? ?? false;
    fastClickEnabled = data['fastClickEnabled'] as bool? ?? false;
    edgeThreshold = (data['edgeThreshold'] as num?)?.toDouble() ?? 0.15;
    activationMs = (data['activationMs'] as num?)?.toInt() ?? 300;
    cooldownMs = (data['cooldownMs'] as num?)?.toInt() ?? 250;
    fastClickMs = (data['fastClickMs'] as num?)?.toInt() ?? 250;
  }
}
