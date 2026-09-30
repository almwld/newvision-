import 'package:flutter/services.dart';

class EyeControlPlatform {
  EyeControlPlatform({MethodChannel? channel})
      : _channel = channel ?? const MethodChannel('com.eyecontrol/platform');

  final MethodChannel _channel;

  Future<void> startCamera() => _channel.invokeMethod<void>('camera.start');
  Future<void> stopCamera() => _channel.invokeMethod<void>('camera.stop');

  Future<void> requestOverlayPermission() =>
      _channel.invokeMethod<void>('overlay.request');

  Future<bool> isOverlayGranted() async =>
      await _channel.invokeMethod<bool>('overlay.isGranted') ?? false;

  Future<void> requestAccessibilitySettings() =>
      _channel.invokeMethod<void>('accessibility.request');

  Future<bool> isAccessibilityEnabled() async =>
      await _channel.invokeMethod<bool>('accessibility.isEnabled') ?? false;

  Future<Map<String, dynamic>?> latestGaze() async {
    final value = await _channel.invokeMethod<dynamic>('gaze.latest');
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return null;
  }

  Future<({int width, int height})> screenSize() async {
    final value = await _channel.invokeMethod<dynamic>('screen.size');
    if (value is! Map) {
      throw StateError('Native screen size is unavailable.');
    }
    return (
      width: (value['width'] as num).toInt(),
      height: (value['height'] as num).toInt(),
    );
  }

  Future<bool> isCalibrationReady() async =>
      await _channel.invokeMethod<bool>('calibration.isReady') ?? false;

  Future<void> fitCalibration(
    List<Map<String, double>> samples,
  ) =>
      _channel.invokeMethod<void>(
        'calibration.fit',
        <String, Object>{'samples': samples},
      );

  Future<Map<String, double>> predictCalibration(
    double x,
    double y,
  ) async {
    final value = await _channel.invokeMethod<dynamic>(
      'calibration.predict',
      <String, double>{'x': x, 'y': y},
    );
    if (value is! Map) {
      throw StateError('Native calibration result is unavailable.');
    }
    return <String, double>{
      'x': (value['x'] as num).toDouble(),
      'y': (value['y'] as num).toDouble(),
    };
  }

  Future<void> clearCalibration() =>
      _channel.invokeMethod<void>('calibration.clear');

  Future<void> executeTap(double x, double y) => _channel.invokeMethod<void>(
        'gesture.tap',
        <String, double>{'x': x, 'y': y},
      );

  Future<void> setDwellConfig({
    required int durationMs,
    required double radiusPx,
  }) =>
      _channel.invokeMethod<void>(
        'dwell.configure',
        <String, Object>{'durationMs': durationMs, 'radiusPx': radiusPx},
      );
}
