import 'package:flutter/foundation.dart';

class HomeViewModel extends ChangeNotifier {
  bool _cameraEnabled = false;
  bool get cameraEnabled => _cameraEnabled;

  void setCameraEnabled(bool value) {
    if (_cameraEnabled == value) return;
    _cameraEnabled = value;
    notifyListeners();
  }
}
