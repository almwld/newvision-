import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/permission_provider.dart';
import '../widgets/permission_tile.dart';
import '../widgets/status_card.dart';

class PermissionsPage extends StatefulWidget {
  const PermissionsPage({super.key});
  @override State<PermissionsPage> createState() => _PermissionsPageState();
}
class _PermissionsPageState extends State<PermissionsPage> {
  @override void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<PermissionProvider>().refresh());
  }
  @override Widget build(BuildContext context) {
    final p = context.watch<PermissionProvider>();
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('جاهزية NewVision')),
      body: RefreshIndicator(
        onRefresh: p.refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            StatusCard(ready: p.ready, title: p.ready ? 'الجهاز جاهز' : 'أكمل متطلبات التشغيل', subtitle: p.ready ? 'يمكنك الانتقال مباشرة إلى المعايرة أو التتبع.' : 'نحتاج إلى 3 صلاحيات أساسية لتشغيل التحكم بالنظر.'),
            const SizedBox(height: 14),
            Card(child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text('التقدم', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                  const Spacer(),
                  Text('${p.completedCount}/3', style: Theme.of(context).textTheme.labelLarge),
                ]),
                const SizedBox(height: 10),
                LinearProgressIndicator(value: p.completedCount / 3, minHeight: 8, borderRadius: BorderRadius.circular(8)),
              ]),
            )),
            if (p.loading) ...[const SizedBox(height: 12), const LinearProgressIndicator(minHeight: 3)],
            const SizedBox(height: 14),
            PermissionTile(icon: Icons.camera_alt_outlined, title: 'الكاميرا', subtitle: 'تحليل العين محلياً على الجهاز.', granted: p.camera, onPressed: p.requestCamera),
            PermissionTile(icon: Icons.layers_outlined, title: 'العرض فوق التطبيقات', subtitle: 'إظهار المؤشر العائم فوق التطبيقات الأخرى.', granted: p.overlay, onPressed: p.requestOverlay),
            PermissionTile(icon: Icons.accessibility_new_rounded, title: 'إمكانية الوصول', subtitle: 'السماح بالتفاعل بالنقرات من خلال النظام.', granted: p.accessibility, onPressed: p.requestAccessibility),
            if (p.error != null) ...[
              const SizedBox(height: 12),
              Card(color: scheme.errorContainer, child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(children: [
                  Icon(Icons.error_outline_rounded, color: scheme.onErrorContainer),
                  const SizedBox(width: 10),
                  Expanded(child: Text(p.error!, style: TextStyle(color: scheme.onErrorContainer))),
                  IconButton(tooltip: 'إعدادات التطبيق', onPressed: p.openAppSettings, icon: Icon(Icons.settings_outlined, color: scheme.onErrorContainer)),
                ]),
              )),
            ],
            const SizedBox(height: 18),
            FilledButton.icon(
              key: const ValueKey('tracking-action'),
              onPressed: p.ready ? () => context.go('/tracking') : null,
              icon: const Icon(Icons.visibility_rounded),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 13),
                child: Text('متابعة إلى التتبع'),
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(onPressed: () => context.push('/calibration'), icon: const Icon(Icons.tune_rounded), label: const Text('الانتقال إلى المعايرة')),
            const SizedBox(height: 14),
            Text('لن يبدأ التتبع قبل اكتمال الصلاحيات المطلوبة.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
