import 'package:eye_control/data/datasources/native_bridge.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('test.native_bridge');
  late NativeBridge bridge;

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'gaze.latest') {
        return {'x': 1.0, 'y': 2.0, 'confidence': 0.9};
      }
      return null;
    });
    bridge = NativeBridge(methodChannel: channel);
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('reads latest gaze payload', () async {
    final value = await bridge.latestGaze();
    expect(value?['x'], 1.0);
    expect(value?['confidence'], 0.9);
  });

  test('camera controls complete successfully', () async {
    await bridge.startCamera();
    await bridge.stopCamera();
  });
}
