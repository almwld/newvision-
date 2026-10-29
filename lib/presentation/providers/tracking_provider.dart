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
      final previousSubscription = _subscription;
      _subscription = _bridge.screenPoints.listen((map) {
        _latest = GazeSampleModel.fromMap(map);
        notifyListeners();
      });
      await previousSubscription?.cancel();
      await _bridge.startCamera();
      _running = true;

      // Launch the system-level control button while the app is visible. It
      // remains available above other apps and owns the external action menu.
      try {
        final shown = await _bridge.showFloatingButton();
        if (!shown) {
          _error = 'التتبع يعمل، لكن الزر العائم لم يبدأ. امنح إذن الظهور فوق التطبيقات.';
        }
      } catch (error) {
        _error = 'التتبع يعمل داخل التطبيق، وتعذر تشغيل الزر العائم: $error';
      }
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

  Future<void> hideFloatingButton() async {
    try {
      await _bridge.hideFloatingButton();
    } catch (error) {
      _error = error.toString();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}