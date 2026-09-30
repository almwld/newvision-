import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../platform/eye_control_platform.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({EyeControlPlatform? platform})
      : _platform = platform ?? EyeControlPlatform();

  final EyeControlPlatform _platform;
  bool _cameraEnabled = false;
  String? _error;

  bool get cameraEnabled => _cameraEnabled;
  String? get error => _error;

  void setCameraEnabled(bool value) {
    if (_cameraEnabled == value) return;
    _cameraEnabled = value;
    notifyListeners();
  }

  Future<void> toggleCamera() async {
    _error = null;
    if (_cameraEnabled) {
      await _platform.stopCamera();
      _cameraEnabled = false;
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

    try {
      await _platform.startCamera();
      _cameraEnabled = true;
    } catch (error) {
      _error = error.toString();
    }
    notifyListeners();
  }
}
