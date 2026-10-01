import 'package:flutter/widgets.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../platform/eye_control_platform.dart';

enum PermissionType { camera, overlay, accessibility }

class PermissionProvider extends ChangeNotifier with WidgetsBindingObserver {
  PermissionProvider({EyeControlPlatform? platform})
      : _platform = platform ?? EyeControlPlatform() {
    WidgetsBinding.instance.addObserver(this);
  }

  final EyeControlPlatform _platform;

  bool camera = false;
  bool overlay = false;
  bool accessibility = false;
  bool loading = false;
  String? error;

  bool get ready => camera && overlay && accessibility;

  Map<PermissionType, bool> get statuses => {
        PermissionType.camera: camera,
        PermissionType.overlay: overlay,
        PermissionType.accessibility: accessibility,
      };

  bool isGranted(PermissionType type) => statuses[type] ?? false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      refresh();
    }
  }

  Future<Map<PermissionType, bool>> checkAll() async {
    await refresh();
    return statuses;
  }

  Future<void> refresh() async {
    if (loading) return;
    loading = true;
    notifyListeners();
    try {
      camera = await Permission.camera.isGranted;
      overlay = await _platform.isOverlayGranted();
      accessibility = await _platform.isAccessibilityEnabled();
      error = null;
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> request(PermissionType type) async {
    switch (type) {
      case PermissionType.camera:
        await requestCamera();
      case PermissionType.overlay:
        await requestOverlay();
      case PermissionType.accessibility:
        await requestAccessibility();
    }
  }

  Future<void> openSettings(PermissionType type) async {
    switch (type) {
      case PermissionType.camera:
        await Permission.camera.request();
      case PermissionType.overlay:
        await requestOverlay();
      case PermissionType.accessibility:
        await requestAccessibility();
    }
    await refresh();
  }

  Future<void> requestCamera() async {
    await Permission.camera.request();
    await refresh();
  }

  Future<void> requestOverlay() async {
    await _platform.requestOverlayPermission();
    await refresh();
  }

  Future<void> requestAccessibility() async {
    await _platform.requestAccessibilitySettings();
    await refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
