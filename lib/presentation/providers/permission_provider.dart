import 'package:flutter/widgets.dart';
import 'package:permission_handler/permission_handler.dart' as permissions;
import '../../platform/eye_control_platform.dart';

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
  int get completedCount => [camera, overlay, accessibility].where((v) => v).length;
  bool get canRequestOverlay => camera;
  bool get canRequestAccessibility => camera && overlay;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) refresh();
  }

  Future<void> refresh() async {
    if (loading) return;
    loading = true;
    error = null;
    notifyListeners();
    try {
      camera = await permissions.Permission.camera.isGranted;
      overlay = await _platform.isOverlayGranted();
      accessibility = await _platform.isAccessibilityEnabled();
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> requestCamera() async {
    if (loading) return;
    loading = true;
    error = null;
    notifyListeners();
    try {
      await permissions.Permission.camera.request();
    } catch (e) {
      error = e.toString();
    }
    loading = false;
    await refresh();
  }

  Future<void> requestOverlay() async {
    if (loading || !camera) return;
    loading = true;
    error = null;
    notifyListeners();
    try {
      await _platform.requestOverlayPermission();
    } catch (e) {
      error = e.toString();
    }
    loading = false;
    await refresh();
  }

  Future<void> requestAccessibility() async {
    if (loading || !camera || !overlay) return;
    loading = true;
    error = null;
    notifyListeners();
    try {
      await _platform.requestAccessibilitySettings();
    } catch (e) {
      error = e.toString();
    }
    loading = false;
    await refresh();
  }

  Future<void> openAppSettings() async {
    final opened = await permissions.openAppSettings();
    if (!opened) {
      error = 'تعذر فتح إعدادات التطبيق.';
      notifyListeners();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
