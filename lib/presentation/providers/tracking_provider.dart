import 'dart:async';

import 'package:flutter/widgets.dart';
import '../../data/datasources/native_bridge.dart';
import '../../data/models/gaze_sample_model.dart';

class TrackingProvider extends ChangeNotifier with WidgetsBindingObserver {
  TrackingProvider({NativeBridge? bridge}) : _bridge = bridge ?? NativeBridge() {
    WidgetsBinding.instance.addObserver(this);
    unawaited(refreshCalibrationState());
  }

  final NativeBridge _bridge;
  StreamSubscription<Map<String, dynamic>>? _subscription;
  GazeSampleModel? _latest;
  bool _running = false;
  bool _starting = false;
  bool _calibrated = false;
  int _screenWidthPx = 0;
  int _screenHeightPx = 0;
  String? _error;
  Timer? _staleTimer;
  DateTime? _lastSampleAt;

  GazeSampleModel? get latest => _latest;
  bool get running => _running;
  bool get starting => _starting;
  bool get calibrated => _calibrated;
  int get screenWidthPx => _screenWidthPx;
  int get screenHeightPx => _screenHeightPx;
  String? get error => _error;

  Future<void> refreshCalibrationState() async {
    try {
      _calibrated = await _bridge.isCalibrationReady();
    } catch (_) {
      _calibrated = false;
    }
    try {
      final size = await _bridge.screenSize();
      _screenWidthPx = size.width;
      _screenHeightPx = size.height;
    } catch (_) {
      // Keep the last known physical display size if the platform is busy.
    }
    notifyListeners();
  }

  Future<void> start() async {
    if (_running || _starting) return;
    _starting = true;
    _error = null;
    notifyListeners();

    try {
      _calibrated = await _bridge.isCalibrationReady();
      if (!_calibrated) {
        _error = 'أكمل معايرة النظر ذات النقاط التسع قبل بدء التحكم خارج التطبيق.';
        return;
      }
      final previousSubscription = _subscription;
      _subscription = _bridge.screenPoints.listen((map) {
        _lastSampleAt = DateTime.now();
        _latest = GazeSampleModel.fromMap(map);
        notifyListeners();
      });
      await previousSubscription?.cancel();
      await _bridge.startCamera();
      _running = true;
      _lastSampleAt = DateTime.now();
      _staleTimer?.cancel();
      var statusTicks = 0;
      _staleTimer = Timer.periodic(const Duration(milliseconds: 250), (_) {
        if (!_running) return;
        statusTicks++;
        // The floating control can stop the native service without interacting
        // with this screen, so reconcile native state while tracking is active.
        if (statusTicks % 4 == 0) unawaited(_syncNativeTrackingState());
        final last = _lastSampleAt;
        if (last != null &&
            DateTime.now().difference(last) > const Duration(milliseconds: 750) &&
            _latest != null) {
          _latest = null;
          notifyListeners();
        }
      });

      // Launch the system-level control button while the app is visible. It
      // remains available above other apps and owns the external action menu.
      try {
        final requested = await _bridge.showFloatingButton();
        var floatingReady = false;
        var cursorReady = false;
        // The platform call acknowledges the request before Android finishes
        // attaching either overlay. Verify both system windows actually exist.
        await Future<void>.delayed(const Duration(milliseconds: 400));
        for (var attempt = 0; attempt < 5; attempt++) {
          floatingReady = await _bridge.isFloatingButtonRunning();
          cursorReady = await _bridge.isCursorRunning();
          if (floatingReady && cursorReady) break;
          if (attempt < 4) {
            await Future<void>.delayed(const Duration(milliseconds: 200));
          }
        }
        if (!requested || !floatingReady || !cursorReady) {
          _error = 'التتبع يعمل، لكن الزر العائم أو مؤشر النظر لم يبدأ. تحقق من إذن الظهور فوق التطبيقات ثم أعد المحاولة.';
        }
      } catch (error) {
        _error = 'التتبع يعمل داخل التطبيق، وتعذر تشغيل الزر العائم: $error';
      }
    } catch (error) {
      _staleTimer?.cancel();
      _staleTimer = null;
      _lastSampleAt = null;
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
    _staleTimer?.cancel();
    _staleTimer = null;
    _lastSampleAt = null;
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
  void didChangeMetrics() {
    unawaited(refreshCalibrationState());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(refreshCalibrationState());
      if (_running) unawaited(_syncNativeTrackingState());
    }
  }

  Future<void> _syncNativeTrackingState() async {
    if (!_running) return;
    try {
      if (await _bridge.isTrackingRunning()) return;
      _running = false;
      _starting = false;
      _latest = null;
      _lastSampleAt = null;
      _staleTimer?.cancel();
      _staleTimer = null;
      await _subscription?.cancel();
      _subscription = null;
      notifyListeners();
    } catch (_) {
      // Keep the current UI state if the platform cannot be queried temporarily.
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _staleTimer?.cancel();
    _subscription?.cancel();
    super.dispose();
  }
}