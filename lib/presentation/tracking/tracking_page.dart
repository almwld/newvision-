import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/tracking_provider.dart';
import '../providers/permission_provider.dart';

class TrackingPage extends StatelessWidget {
  const TrackingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tracking = context.watch<TrackingProvider>();
    final permissions = context.watch<PermissionProvider>();
    if (!permissions.camera) return _buildPermissionScreen(context, permissions);
    if (!permissions.ready) return _buildSetupScreen(context, permissions);
    if (tracking.starting) return _buildStartingScreen(context);
    if (!tracking.running) return _buildStartScreen(context, tracking);
    return _buildRunningScreen(context, tracking);
  }

  Widget _buildPermissionScreen(BuildContext context, PermissionProvider p) => Scaffold(
    appBar: AppBar(title: const Text('تتبع النظر')),
    body: Center(child: Padding(padding: const EdgeInsets.all(28), child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.camera_alt_outlined, size: 72),
      const SizedBox(height: 20),
      const Text('صلاحية الكاميرا مطلوبة', style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
      const SizedBox(height: 10),
      const Text('امنح NewVision صلاحية الكاميرا لبدء تتبع النظر.', textAlign: TextAlign.center),
      const SizedBox(height: 26),
      FilledButton.icon(onPressed: p.loading ? null : p.requestCamera, icon: const Icon(Icons.camera_alt), label: const Text('منح صلاحية الكاميرا')),
    ]))),
  );

  Widget _buildSetupScreen(BuildContext context, PermissionProvider p) => Scaffold(
    appBar: AppBar(title: const Text('إعداد التحكم خارج التطبيق')),
    body: ListView(padding: const EdgeInsets.all(24), children: [
      const Icon(Icons.settings_suggest_outlined, size: 64),
      const SizedBox(height: 14),
      Text('أكمل الأذونات حتى يعمل مؤشر النظر وزر الإجراءات فوق التطبيقات الأخرى.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 22),
      if (!p.overlay) ...[FilledButton.icon(onPressed: p.requestOverlay, icon: const Icon(Icons.layers_outlined), label: const Text('السماح بالظهور فوق التطبيقات')), const SizedBox(height: 10)],
      if (!p.accessibility) ...[FilledButton.icon(onPressed: p.requestAccessibility, icon: const Icon(Icons.accessibility_new_rounded), label: const Text('تفعيل خدمة إمكانية الوصول')), const SizedBox(height: 10)],
      if (!p.notifications) OutlinedButton.icon(onPressed: p.requestNotifications, icon: const Icon(Icons.notifications_active_outlined), label: const Text('السماح بإشعارات التتبع')),
      if (p.error != null) ...[const SizedBox(height: 12), Text(p.error!, textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).colorScheme.error))],
      const SizedBox(height: 16),
      OutlinedButton.icon(onPressed: p.refresh, icon: const Icon(Icons.refresh), label: const Text('إعادة التحقق من الأذونات')),
    ]),
  );

  Widget _buildStartScreen(BuildContext context, TrackingProvider tracking) => Scaffold(
    appBar: AppBar(title: const Text('تتبع النظر')),
    body: Center(child: Padding(padding: const EdgeInsets.all(28), child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 118, height: 118, decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0x1F0A8F83), border: Border.all(color: const Color(0xFF0A8F83), width: 2)), child: const Icon(Icons.visibility_rounded, size: 62, color: Color(0xFF0A8F83))),
      const SizedBox(height: 24),
      const Text('جاهز لتتبع النظر', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      const SizedBox(height: 10),
      Text(
        tracking.calibrated
            ? 'ابدأ التتبع هنا؛ سيظهر مؤشر النظر وزر الإجراءات العائم فوق التطبيقات عند الانتقال إلى تطبيق آخر.'
            : 'ابدأ بمعايرة النظر ذات النقاط التسع. بعد ذلك يمكنك التحكم بالنقر والتمرير خارج NewVision.',
        textAlign: TextAlign.center,
      ),
      if (tracking.error != null) ...[const SizedBox(height: 14), Text(tracking.error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red))],
      const SizedBox(height: 28),
      FilledButton.icon(
        onPressed: tracking.calibrated ? tracking.start : null,
        icon: const Icon(Icons.play_arrow_rounded, size: 28),
        label: const Text('بدء التتبع', style: TextStyle(fontSize: 19)),
        style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 42, vertical: 18)),
      ),
      const SizedBox(height: 10),
      OutlinedButton.icon(
        onPressed: () async {
          await context.push('/calibration');
          await tracking.refreshCalibrationState();
        },
        icon: const Icon(Icons.center_focus_strong_rounded),
        label: const Text('معايرة النظر (9 نقاط)'),
      ),
    ]))),
  );

  Widget _buildStartingScreen(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('تتبع النظر')),
    body: const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [SizedBox(width: 42, height: 42, child: CircularProgressIndicator()), SizedBox(height: 20), Text('جارٍ تشغيل الكاميرا وخدمة التتبع...', style: TextStyle(fontSize: 18))])),
  );

  Widget _buildRunningScreen(BuildContext context, TrackingProvider tracking) {
    final gaze = tracking.latest;
    final confidence = (gaze?.confidence ?? 0.0).clamp(0.0, 1.0);
    final media = MediaQuery.of(context);
    final dpr = media.devicePixelRatio;
    final screenWidthPx = tracking.screenWidthPx > 0
        ? tracking.screenWidthPx.toDouble()
        : media.size.width * dpr;
    final screenHeightPx = tracking.screenHeightPx > 0
        ? tracking.screenHeightPx.toDouble()
        : media.size.height * dpr;
    // Native gaze points are in physical display pixels. The tracking preview
    // lives below the status bar and AppBar, so convert to Flutter logical pixels
    // before drawing its local cursor.
    final screenX = gaze == null ? null : gaze.xPx / dpr;
    final screenY = gaze == null
        ? null
        : gaze.yPx / dpr - media.padding.top - kToolbarHeight;
    final direction = gaze == null
        ? 'لم يُكتشف النظر بعد'
        : _direction(gaze.xPx, gaze.yPx, screenWidthPx, screenHeightPx);

    return Scaffold(
      backgroundColor: const Color(0xFF0A1720),
      appBar: AppBar(
        title: const Text('GazeFusion — تتبع النظر'),
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 16),
            child: Center(
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(
                  Icons.circle,
                  size: 10,
                  color: gaze == null || gaze.isBlinking || confidence < 0.45
                      ? Colors.orange
                      : const Color(0xFF0A8F83),
                ),
                const SizedBox(width: 6),
                Text(
                  gaze == null
                      ? 'بانتظار العين'
                      : gaze.isBlinking
                          ? 'رمشة'
                          : confidence < 0.45
                              ? 'ثبّت النظر'
                              : 'نشط',
                ),
              ]),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        final cursorX = screenX == null
            ? 0.0
            : (screenX - 14).clamp(0.0, (constraints.maxWidth - 28).clamp(0.0, double.infinity)).toDouble();
        final cursorY = screenY == null
            ? 0.0
            : (screenY - 14).clamp(0.0, (constraints.maxHeight - 28).clamp(0.0, double.infinity)).toDouble();
        return Stack(fit: StackFit.expand, children: [
          const AndroidView(viewType: 'com.eyecontrol/camera_preview'),
          const ColoredBox(color: Color(0x330A1720)),
          Positioned(
            left: 12,
            right: 12,
            top: 12,
            child: Card(
              color: const Color(0xEE1E293B),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(direction, textDirection: TextDirection.rtl, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 4),
                    Text(
                      tracking.calibrated ? 'المعايرة: مكتملة' : 'المعايرة: افتراضية — نفّذ معايرة 9 نقاط',
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const Text(
                      'المعالجة محلية • لا تُحفظ الصور ولا تُرفع',
                      textDirection: TextDirection.rtl,
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    Text(
                      gaze == null
                          ? 'جودة التتبع: لا توجد قراءة موثوقة'
                          : 'جودة التتبع: ${(confidence * 100).round()}%',
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                    const SizedBox(height: 7),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: confidence,
                        minHeight: 5,
                        backgroundColor: Colors.white24,
                        color: Colors.amber,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (gaze != null && !gaze.isBlinking && confidence >= 0.45)
            Positioned(
              left: cursorX,
              top: cursorY,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.amber, width: 3),
                  color: Colors.amber.withOpacity(0.25),
                ),
              ),
            ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: Card(
              color: const Color(0xF21E293B),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(children: [
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await context.push('/calibration');
                        await tracking.refreshCalibrationState();
                      },
                      icon: const Icon(Icons.center_focus_strong_rounded),
                      label: const Text('معايرة النظر (9 نقاط)'),
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: tracking.stop,
                      icon: const Icon(Icons.pause_rounded),
                      label: const Text('إيقاف التتبع'),
                      style: FilledButton.styleFrom(backgroundColor: const Color(0xFF0A8F83), foregroundColor: Colors.white),
                    ),
                  ),
                ]),
              ),
            ),
          ),
        ]);
      }),
    );
  }

  String _direction(double x, double y, double width, double height) {
    final nx = width <= 0 ? .5 : x / width;
    final ny = height <= 0 ? .5 : y / height;
    if (nx < .35) return 'النظر إلى اليسار';
    if (nx > .65) return 'النظر إلى اليمين';
    if (ny < .35) return 'النظر إلى الأعلى';
    if (ny > .65) return 'النظر إلى الأسفل';
    return 'النظر إلى المركز';
  }
}
