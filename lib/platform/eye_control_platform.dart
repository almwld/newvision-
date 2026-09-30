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
