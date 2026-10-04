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

    if (!permissions.camera) {
      return _buildPermissionScreen(context, permissions);
    }

    if (!permissions.ready) {
      return _buildSetupScreen(context, permissions);
    }

    if (tracking.starting) {
      return _buildStartingScreen(context);
    }

    if (!tracking.running) {
      return _buildStartScreen(context);
    }

    if (tracking.latest == null) {
      return _buildWaitingScreen(context, tracking);
    }

    return _buildRunningScreen(context, tracking);
  }

  Widget _buildPermissionScreen(
    BuildContext context,
    PermissionProvider permissions,
  ) {
    return Scaffold(
      appBar: AppBar(title: const Text('تتبع النظر')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.camera_alt_outlined, size: 72),
              const SizedBox(height: 20),
              const Text(
                'صلاحية الكاميرا مطلوبة',
                style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'امنح التطبيق صلاحية الكاميرا لبدء تتبع النظر.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 26),
              FilledButton.icon(
                onPressed: permissions.loading
                    ? null
                    : () => permissions.requestCamera(),
                icon: const Icon(Icons.camera_alt),
                label: const Text('منح صلاحية الكاميرا'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSetupScreen(
    BuildContext context,
    PermissionProvider permissions,
  ) {
    return Scaffold(
      appBar: AppBar(title: const Text('تتبع النظر')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.settings_suggest_outlined, size: 72),
              const SizedBox(height: 20),
              const Text(
                'أكمل إعداد التحكم بالعين',
                style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              if (!permissions.overlay)
                FilledButton.icon(
                  onPressed: permissions.requestOverlay,
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('السماح بالظهور فوق التطبيقات'),
                ),
              if (!permissions.overlay) const SizedBox(height: 10),
              if (!permissions.accessibility)
                OutlinedButton.icon(
                  onPressed: permissions.requestAccessibility,
                  icon: const Icon(Icons.accessibility_new),
                  label: const Text('تفعيل خدمة التحكم'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStartScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تتبع النظر')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.play_circle_fill,
                size: 96,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              const Text(
                'جاهز للبدء',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'اضغط الزر لبدء التحكم بالعين',
                textAlign: TextAlign.center,
              ),
              if (context.watch<TrackingProvider>().error != null) ...[
                const SizedBox(height: 14),
                Text(
                  context.watch<TrackingProvider>().error!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red),
                ),
              ],
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: () => context.read<TrackingProvider>().start(),
                icon: const Icon(Icons.play_arrow, size: 30),
                label: const Text('بدء التتبع', style: TextStyle(fontSize: 20)),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStartingScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تتبع النظر')),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: 42, height: 42, child: CircularProgressIndicator()),
            SizedBox(height: 20),
            Text('جارٍ التشغيل...', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }

  Widget _buildWaitingScreen(
    BuildContext context,
    TrackingProvider tracking,
  ) {
    return Scaffold(
      appBar: AppBar(title: const Text('تتبع النظر')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.visibility_outlined, size: 78),
              const SizedBox(height: 18),
              const Text(
                'التتبع يعمل',
                style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'في انتظار أول قراءة من الكاميرا...',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: tracking.stop,
                icon: const Icon(Icons.stop),
                label: const Text('إيقاف'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRunningScreen(
    BuildContext context,
    TrackingProvider tracking,
  ) {
    final gaze = tracking.latest!;
    final confidence = gaze.confidence.clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('تتبع النظر'),
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 18),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.circle, size: 10, color: Colors.green),
                  const SizedBox(width: 6),
                  Text(gaze.isBlinking ? 'رمشة' : 'نشط'),
                ],
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
        children: [
          Card(
            child: SizedBox(
              height: 260,
              child: Center(
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withOpacity(.22),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      gaze.isBlinking ? 'BLINK' : 'TRACKING',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _MetricCard(label: 'X', value: gaze.xPx.toStringAsFixed(0), unit: 'px')),
              const SizedBox(width: 10),
              Expanded(child: _MetricCard(label: 'Y', value: gaze.yPx.toStringAsFixed(0), unit: 'px')),
            ],
          ),
          const SizedBox(height: 10),
          _MetricCard(
            label: 'الثقة',
            value: (confidence * 100).toStringAsFixed(0),
            unit: '%',
          ),
          const SizedBox(height: 18),
          LinearProgressIndicator(
            value: confidence,
            minHeight: 8,
            borderRadius: BorderRadius.circular(8),
          ),
          const SizedBox(height: 8),
          Text('جودة الإشارة', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: tracking.stop,
            icon: const Icon(Icons.stop_circle_outlined),
            label: const Text('إيقاف التتبع'),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.unit,
  });

  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(label, style: Theme.of(context).textTheme.labelLarge),
              const Spacer(),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(width: 5),
              Text(unit, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      );
}
