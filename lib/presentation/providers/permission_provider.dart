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
  int get grantedCount => [camera, overlay, accessibility].where((v) => v).length;
  @override void didChangeAppLifecycleState(AppLifecycleState state) { if (state == AppLifecycleState.resumed) refresh(); }
  Future<void> refresh() async {
    if (loading) return; loading = true; error = null; notifyListeners();
    try { camera = await Permission.camera.isGranted; overlay = await _platform.isOverlayGranted(); accessibility = await _platform.isAccessibilityEnabled(); }
    catch (e) { error = 'تعذر التحقق من جاهزية النظام. حاول مرة أخرى.'; debugPrint('Permission refresh failed: $e'); }
    finally { loading = false; notifyListeners(); }
  }
  Future<void> requestCamera() async => _runRequest(() async {
    final status = await Permission.camera.request();
    if (status.isPermanentlyDenied) error = 'تم رفض الكاميرا نهائياً. افتح إعدادات التطبيق للسماح بها.';
    else if (status.isDenied) error = 'يلزم السماح بالكاميرا لتشغيل تتبع النظر.';
  });
  Future<void> requestOverlay() async => _runRequest(() async {
    await _platform.requestOverlayPermission();
    error = 'بعد العودة من الإعدادات سيتم التحقق تلقائياً.';
  });
  Future<void> requestAccessibility() async => _runRequest(() async {
    await _platform.requestAccessibilitySettings();
    error = 'بعد العودة من الإعدادات سيتم التحقق تلقائياً.';
  });
  Future<void> openAppSettings() async {
    final opened = await openAppSettings();
    if (!opened) error = 'تعذر فتح إعدادات التطبيق.';
    await refresh();
  }
  Future<void> _runRequest(Future<void> Function() action) async {
    if (loading) return; loading = true; error = null; notifyListeners();
    try { await action(); } catch (e) { error = 'تعذر تنفيذ الطلب. تحقق من إعدادات النظام وحاول مرة أخرى.'; debugPrint('Permission request failed: $e'); }
    finally { loading = false; notifyListeners(); }
    await refresh();
  }
  @override void dispose() { WidgetsBinding.instance.removeObserver(this); super.dispose(); }
}
