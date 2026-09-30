import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../platform/eye_control_platform.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({EyeControlPlatform? platform})
      : _platform = platform ?? EyeControlPlatform();

  final EyeControlPlatform _platform;
  bool _cameraEnabled = false;
  bool _overlayReady = false;
  bool _accessibilityReady = false;
  bool _loading = false;
  String? _error;

  bool get cameraEnabled => _cameraEnabled;
  bool get overlayReady => _overlayReady;
  bool get accessibilityReady => _accessibilityReady;
  bool get loading => _loading;
  String? get error => _error;
  bool get ready => _cameraEnabled && _overlayReady && _accessibilityReady;

  Future<void> initialize() async {
    _loading = true;
    notifyListeners();
    await refreshReadiness();
    _loading = false;
    notifyListeners();
  }

  Future<void> refreshReadiness() async {
    try {
      _overlayReady = await _platform.isOverlayGranted();
      _accessibilityReady = await _platform.isAccessibilityEnabled();
    } catch (error) {
      _error = error.toString();
    }
    notifyListeners();
  }

  Future<void> requestOverlay() async {
    _error = null;
    await _platform.requestOverlayPermission();
    await Future<void>.delayed(const Duration(milliseconds: 300));
    await refreshReadiness();
  }

  Future<void> requestAccessibility() async {
    _error = null;
    await _platform.requestAccessibilitySettings();
    await Future<void>.delayed(const Duration(milliseconds: 300));
    await refreshReadiness();
  }

  Future<void> toggleCamera() async {
    _error = null;
    if (_cameraEnabled) {
      try {
        await _platform.stopCamera();
        _cameraEnabled = false;
      } catch (error) {
        _error = error.toString();
      }
      notifyListeners();
      return;
    }

    final status = await Permission.camera.request();
    if (!status.isGranted) {
      _error = status.isPermanentlyDenied
          ? 'Camera permission is permanently denied.'
          : 'Camera permission is required.';
      notifyListeners();
      return;
    }

    if (!_overlayReady || !_accessibilityReady) {
      _error = 'Enable overlay and accessibility access first.';
      notifyListeners();
      return;
    }

    _loading = true;
    notifyListeners();
    try {
      await _platform.startCamera();
      _cameraEnabled = true;
    } catch (error) {
      _error = error.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void setCameraEnabled(bool value) {
    if (_cameraEnabled == value) return;
    _cameraEnabled = value;
    notifyListeners();
  }
}
