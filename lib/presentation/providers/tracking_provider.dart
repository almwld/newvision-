import 'dart:async';

import 'package:flutter/foundation.dart';
import '../../data/datasources/native_bridge.dart';
import '../../data/models/gaze_sample_model.dart';

class TrackingProvider extends ChangeNotifier {
  TrackingProvider({NativeBridge? bridge}) : _bridge = bridge ?? NativeBridge();

  final NativeBridge _bridge;
  StreamSubscription<Map<String, dynamic>>? _subscription;
  GazeSampleModel? _latest;

  GazeSampleModel? get latest => _latest;

  void start() {
    _subscription ??= _bridge.screenPoints.listen((map) {
      _latest = GazeSampleModel.fromMap(map);
      notifyListeners();
    });
  }

  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
