import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../platform/eye_control_platform.dart';

class PermissionProvider extends ChangeNotifier with WidgetsBindingObserver {
  PermissionProvider({EyeControlPlatform? platform}) : _platform = platform ?? EyeControlPlatform() {
    WidgetsBinding.instance.addObserver(this);
  }
  final EyeControlPlatform _platform;
  bool camera = false, overlay = false, accessibility = false, loading = false;
  String? error;
  bool get ready => camera && overlay && accessibility;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) refresh();
  }

  Future<void> refresh() async {
    loading = true; notifyListeners();
    try {
      camera = await Permission.camera.isGranted;
      overlay = await _platform.isOverlayGranted();
      accessibility = await _platform.isAccessibilityEnabled();
      error = null;
    } catch (e) { error = e.toString(); }
    loading = false; notifyListeners();
  }
  Future<void> requestCamera() async { await Permission.camera.request(); await refresh(); }
  Future<void> requestOverlay() async { await _platform.requestOverlayPermission(); await refresh(); }
  Future<void> requestAccessibility() async { await _platform.requestAccessibilitySettings(); await refresh(); }

  @override
  void dispose() { WidgetsBinding.instance.removeObserver(this); super.dispose(); }
}