import 'package:eye_control/platform/eye_control_platform.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('test.eye_control_platform');
  late EyeControlPlatform platform;
  final calls = <MethodCall>[];

  setUp(() {
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      switch (call.method) {
        case 'overlay.isGranted':
        case 'accessibility.isEnabled':
        case 'calibration.isReady':
          return true;
        case 'screen.size':
          return {'width': 1080, 'height': 1920};
        case 'calibration.predict':
          return {'x': 0.4, 'y': 0.6};
        default:
          return null;
      }
    });
    platform = EyeControlPlatform(channel: channel);
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('reads platform state and screen size', () async {
    expect(await platform.isOverlayGranted(), isTrue);
    expect(await platform.isAccessibilityEnabled(), isTrue);
    expect(await platform.isCalibrationReady(), isTrue);
    expect(await platform.screenSize(), (width: 1080, height: 1920));
  });

  test('invokes camera and permission operations', () async {
    await platform.startCamera();
    await platform.stopCamera();
    await platform.requestOverlayPermission();
    await platform.requestAccessibilitySettings();
    expect(calls.map((call) => call.method), containsAll([
      'camera.start',
      'camera.stop',
      'overlay.request',
      'accessibility.request',
    ]));
  });

  test('round trips calibration and gesture operations', () async {
    await platform.fitCalibration([
      {'x': 0.1, 'y': 0.2, 'targetX': 0.2, 'targetY': 0.3},
    ]);
    final point = await platform.predictCalibration(0.1, 0.2);
    expect(point['x'], 0.4);
    expect(point['y'], 0.6);
    await platform.clearCalibration();
    await platform.executeTap(4, 5);
    await platform.setDwellConfig(durationMs: 900, radiusPx: 50);
    expect(calls.map((call) => call.method), containsAll([
      'calibration.fit',
      'calibration.predict',
      'calibration.clear',
      'gesture.tap',
      'dwell.configure',
    ]));
  });
}
