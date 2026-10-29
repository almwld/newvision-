import 'package:flutter/material.dart';
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
    if (tracking.latest == null) return _buildWaitingScreen(context, tracking);
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
      const Text('ابدأ التتبع هنا؛ سيظهر مؤشر النظر وزر الإجراءات العائم فوق التطبيقات عند الانتقال إلى تطبيق آخر.', textAlign: TextAlign.center),
      if (tracking.error != null) ...[const SizedBox(height: 14), Text(tracking.error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red))],
      const SizedBox(height: 28),
      FilledButton.icon(onPressed: tracking.start, icon: const Icon(Icons.play_arrow_rounded, size: 28), label: const Text('بدء التتبع', style: TextStyle(fontSize: 19)), style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 42, vertical: 18))),
    ]))),
  );

  Widget _buildStartingScreen(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('تتبع النظر')),
    body: const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [SizedBox(width: 42, height: 42, child: CircularProgressIndicator()), SizedBox(height: 20), Text('جارٍ تشغيل الكاميرا وخدمة التتبع...', style: TextStyle(fontSize: 18))])),
  );

  Widget _buildWaitingScreen(BuildContext context, TrackingProvider tracking) => Scaffold(
    appBar: AppBar(title: const Text('تتبع النظر')),
    body: Stack(fit: StackFit.expand, children: [
      const AndroidView(viewType: 'com.eyecontrol/camera_preview'),
      const ColoredBox(color: Color(0x770A1720)),
      Center(child: Padding(padding: const EdgeInsets.all(28), child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.visibility_outlined, size: 78, color: Color(0xFF55D6C8)),
        const SizedBox(height: 18),
        const Text('التتبع يعمل', style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 8),
        const Text('في انتظار قراءة موثوقة من العين. أبقِ الوجه أمام الكاميرا وفي إضاءة جيدة.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white)),
        const SizedBox(height: 24),
        if (tracking.error != null) Text(tracking.error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.redAccent)),
        const SizedBox(height: 12),
        OutlinedButton.icon(onPressed: tracking.stop, icon: const Icon(Icons.stop), label: const Text('إيقاف التتبع')),
      ]))),
    ]),
  );

  Widget _buildRunningScreen(BuildContext context, TrackingProvider tracking) {
    final gaze = tracking.latest!;
    final confidence = gaze.confidence.clamp(0.0, 1.0);
    final media = MediaQuery.of(context);
    final dpr = media.devicePixelRatio;
    final screenX = gaze.xPx / dpr;
    final screenY = gaze.yPx / dpr - media.padding.top - kToolbarHeight;
    final direction = _direction(gaze.xPx, gaze.yPx, media.size.width * dpr, media.size.height * dpr);

    return Scaffold(
      appBar: AppBar(title: const Text('تتبع النظر'), actions: [
        Padding(padding: const EdgeInsetsDirectional.only(end: 16), child: Center(child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.circle, size: 10, color: gaze.isBlinking ? Colors.orange : const Color(0xFF0A8F83)),
          const SizedBox(width: 6), Text(gaze.isBlinking ? 'رمشة' : 'نشط'),
        ]))),
      ]),
      body: LayoutBuilder(builder: (context, constraints) {
        final cursorX = (screenX - 15).clamp(0.0, (constraints.maxWidth - 30).clamp(0.0, double.infinity)).toDouble();
        final cursorY = (screenY - 15).clamp(0.0, (constraints.maxHeight - 30).clamp(0.0, double.infinity)).toDouble();
        return Stack(fit: StackFit.expand, children: [
          const AndroidView(viewType: 'com.eyecontrol/camera_preview'),
          const ColoredBox(color: Color(0x330A1720)),
          Positioned.fill(child: CustomPaint(painter: _TrackingGridPainter())),
          Positioned(left: 14, right: 14, top: 14, child: Card(
            color: const Color(0xEE1E293B),
            child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(direction, textDirection: TextDirection.rtl, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Text(gaze.isBlinking ? 'تم رصد رمشة' : 'المؤشر يتبع اتجاه النظر', textDirection: TextDirection.rtl, style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 9),
              ClipRRect(borderRadius: BorderRadius.circular(6), child: LinearProgressIndicator(value: confidence, minHeight: 6, backgroundColor: Colors.white24, color: const Color(0xFF55D6C8))),
              const SizedBox(height: 5),
              Text('جودة الإشارة ${(confidence * 100).round()}%', textDirection: TextDirection.rtl, style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ])),
          )),
          Positioned(left: cursorX, top: cursorY, child: Container(width: 30, height: 30, decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0x330A8F83), border: Border.all(color: const Color(0xFF0A8F83), width: 3), boxShadow: const [BoxShadow(color: Color(0x330A8F83), blurRadius: 12, spreadRadius: 2)]), child: const Center(child: CircleAvatar(radius: 4, backgroundColor: Color(0xFF0A8F83))))),
          Positioned(left: 14, right: 14, bottom: 14, child: Card(
            color: const Color(0xF21E293B),
            child: Padding(padding: const EdgeInsets.all(12), child: Column(children: [
              Row(children: [
                Expanded(child: _Metric(label: 'X', value: gaze.xPx.toStringAsFixed(0), unit: 'px')),
                const SizedBox(width: 8),
                Expanded(child: _Metric(label: 'Y', value: gaze.yPx.toStringAsFixed(0), unit: 'px')),
              ]),
              const SizedBox(height: 10),
              const Text('زر الإجراءات العائم يبقى متاحاً عند مغادرة التطبيق.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 10),
              SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: tracking.stop, icon: const Icon(Icons.stop_circle_outlined), label: const Text('إيقاف التتبع'), style: FilledButton.styleFrom(backgroundColor: const Color(0xFF0A8F83), foregroundColor: Colors.white))),
            ])),
          )),
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

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value, required this.unit});
  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(11),
    decoration: BoxDecoration(color: const Color(0xFF334155), borderRadius: BorderRadius.circular(12)),
    child: Row(children: [
      Text(label, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
      const Spacer(),
      Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(width: 4),
      Text(unit, style: const TextStyle(color: Colors.white70, fontSize: 11)),
    ]),
  );
}

class _TrackingGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0x160A8F83)..strokeWidth = 1;
    for (var i = 1; i < 3; i++) {
      final x = size.width * i / 3;
      final y = size.height * i / 3;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    final center = Offset(size.width / 2, size.height / 2);
    paint.color = const Color(0x220A8F83);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1.5;
    canvas.drawCircle(center, 42, paint);
    canvas.drawLine(Offset(center.dx - 58, center.dy), Offset(center.dx + 58, center.dy), paint);
    canvas.drawLine(Offset(center.dx, center.dy - 58), Offset(center.dx, center.dy + 58), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}