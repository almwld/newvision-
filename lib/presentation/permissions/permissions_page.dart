import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/permission_provider.dart';
import '../widgets/permission_tile.dart';
import '../widgets/status_card.dart';

class PermissionsPage extends StatelessWidget {
  const PermissionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<PermissionProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('صلاحيات NewVision')),
      body: RefreshIndicator(
        onRefresh: p.refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            StatusCard(
              ready: p.ready,
              title: p.ready ? 'كل المتطلبات جاهزة' : 'أكمل متطلبات التحكم بالعين',
              subtitle: p.ready
                  ? 'يمكن تشغيل التتبع وإظهار المؤشر والتفاعل خارج التطبيق.'
                  : 'فعّل الصلاحيات التالية، ثم ارجع إلى هذه الشاشة لتحديث الحالة.',
            ),
            const SizedBox(height: 18),
            PermissionTile(
              icon: Icons.camera_alt_outlined,
              title: 'الكاميرا',
              subtitle: 'قراءة العين محلياً أثناء تشغيل التتبع.',
              granted: p.camera,
              onPressed: p.requestCamera,
            ),
            PermissionTile(
              icon: Icons.layers_outlined,
              title: 'الظهور فوق التطبيقات',
              subtitle: 'عرض مؤشر النظر وزر الإجراءات فوق التطبيقات الأخرى.',
              granted: p.overlay,
              onPressed: p.requestOverlay,
            ),
            PermissionTile(
              icon: Icons.accessibility_new_rounded,
              title: 'إمكانية الوصول',
              subtitle: 'تنفيذ النقر والتمرير داخل التطبيقات الأخرى.',
              granted: p.accessibility,
              onPressed: p.requestAccessibility,
            ),
            PermissionTile(
              icon: Icons.notifications_active_outlined,
              title: 'إشعارات خدمة التتبع',
              subtitle: 'إظهار إشعار الخدمة الأمامية أثناء التتبع بالخلفية.',
              granted: p.notifications,
              onPressed: p.requestNotifications,
            ),
            if (p.error != null) ...[
              const SizedBox(height: 12),
              Text(p.error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
            const SizedBox(height: 18),
            FilledButton(
              onPressed: p.ready ? () => context.go('/tracking') : null,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 13),
                child: Text('متابعة إلى تتبع النظر'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}