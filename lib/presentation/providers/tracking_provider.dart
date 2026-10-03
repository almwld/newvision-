import 'dart:async';

import 'package:flutter/foundation.dart';
import '../../data/datasources/native_bridge.dart';
import '../../data/models/gaze_sample_model.dart';

class TrackingProvider extends ChangeNotifier {
  TrackingProvider({NativeBridge? bridge}) : _bridge = bridge ?? NativeBridge();

  final NativeBridge _bridge;
  StreamSubscription<Map<String, dynamic>>? _subscription;
  GazeSampleModel? _latest;
  bool _running = false;
  bool _starting = false;
  String? _error;

  GazeSampleModel? get latest => _latest;
  bool get running => _running;
  bool get starting => _starting;
  String? get error => _error;

  Future<void> start() async {
    if (_running || _starting) return;
    _starting = true;
    _error = null;
    notifyListeners();

    try {
      await _subscription?.cancel();
      _subscription = _bridge.screenPoints.listen((map) {
        _latest = GazeSampleModel.fromMap(map);
        notifyListeners();
      });
      await _bridge.startCamera();
      _running = true;
    } catch (error) {
      await _subscription?.cancel();
      _subscription = null;
      _error = error.toString();
      _running = false;
    } finally {
      _starting = false;
      notifyListeners();
    }
  }

  Future<void> stop() async {
    if (!_running && !_starting) return;
    _starting = false;
    try {
      await _bridge.stopCamera();
    } catch (error) {
      _error = error.toString();
    }
    await _subscription?.cancel();
    _subscription = null;
    _running = false;
    _latest = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
