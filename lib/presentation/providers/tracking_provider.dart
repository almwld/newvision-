import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../data/datasources/native_bridge.dart';
import '../../data/models/gaze_sample_model.dart';
class TrackingProvider extends ChangeNotifier { TrackingProvider({NativeBridge? bridge}) : _bridge = bridge ?? NativeBridge(); final NativeBridge _bridge; StreamSubscription<Map<String,dynamic>>? _subscription; GazeSampleModel? _latest; bool _running = false; GazeSampleModel? get latest => _latest; bool get running => _running; void start() { _subscription ??= _bridge.screenPoints.listen((map) { _latest = GazeSampleModel.fromMap(map); _running = true; notifyListeners(); }); } Future<void> stop() async { await _bridge.stopCamera(); await _subscription?.cancel(); _subscription = null; _running = false; notifyListeners(); } @override void dispose() { _subscription?.cancel(); super.dispose(); } }
