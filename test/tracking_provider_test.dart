import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:eye_control/data/datasources/native_bridge.dart';
import 'package:eye_control/presentation/providers/tracking_provider.dart';
import 'package:eye_control/data/models/gaze_sample_model.dart';

class FakeBridge extends NativeBridge {
  final StreamController<Map<String, dynamic>> c = StreamController<Map<String, dynamic>>.broadcast();
  @override Stream<GazeSampleModel> get gazeStream => c.stream.map(GazeSampleModel.fromMap);
  @override Future<void> startTracking() async {}
  @override Future<void> stopTracking() async {}
  Future<void> close() async => c.close();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('publishes latest screen point', () async {
    final bridge = FakeBridge();
    final provider = TrackingProvider(bridge: bridge);
    provider.start();
    bridge.c.add({'xPx': 1, 'yPx': 2, 'confidence': .8, 'isBlinking': false, 'timestampNs': 7});
    await Future<void>.delayed(Duration.zero);
    expect(provider.latest?.xPx, 1);
    await provider.stop();
    provider.dispose();
    await bridge.close();
  });
}
