import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/permission_provider.dart';
import '../widgets/permission_tile.dart';
import '../widgets/status_card.dart';
class PermissionsPage extends StatelessWidget {
  const PermissionsPage({super.key});
  @override Widget build(BuildContext context) {
    final p = context.watch<PermissionProvider>();
    return Scaffold(appBar: AppBar(title: const Text('الصلاحيات')),
      body: RefreshIndicator(onRefresh: p.refresh, child: ListView(physics: const AlwaysScrollableScrollPhysics(), padding: const EdgeInsets.fromLTRB(20, 8, 20, 28), children: [
        StatusCard(ready: p.ready, title: p.ready ? 'كل المتطلبات جاهزة' : 'نحتاج إلى ثلاثة متطلبات',
          subtitle: p.ready ? 'يمكنك الانتقال إلى التتبع.' : 'امنح الصلاحيات التالية ثم أعد التحقق.'),
        const SizedBox(height: 18),
        PermissionTile(icon: Icons.camera_alt_outlined, title: 'الكاميرا', subtitle: 'تحليل العين محلياً.', granted: p.camera, onPressed: p.requestCamera),
        PermissionTile(icon: Icons.layers_outlined, title: 'العرض فوق التطبيقات', subtitle: 'إظهار مؤشر النظر خارج التطبيق.', granted: p.overlay, onPressed: p.requestOverlay),
        PermissionTile(icon: Icons.accessibility_new_rounded, title: 'إمكانية الوصول', subtitle: 'تنفيذ النقرات والتفاعل بالنظر.', granted: p.accessibility, onPressed: p.requestAccessibility),
        if (p.error != null) ...[const SizedBox(height: 12), Text(p.error!, style: TextStyle(color: Theme.of(context).colorScheme.error))],
        const SizedBox(height: 18),
        FilledButton(onPressed: p.ready ? () => context.go('/tracking') : null,
          child: const Padding(padding: EdgeInsets.symmetric(vertical: 13), child: Text('متابعة إلى التتبع'))),
      ])));
  }
}
