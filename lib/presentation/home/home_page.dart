import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/permission_provider.dart';
import '../widgets/status_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final permissions = context.watch<PermissionProvider>();
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('NewVision', style: TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: false,
      ),
      body: RefreshIndicator(
        onRefresh: permissions.refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [scheme.primaryContainer, scheme.surfaceContainerHighest],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Row(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(Icons.visibility_rounded, color: scheme.onPrimary, size: 30),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('تحكم بعينيك', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
                        const SizedBox(height: 5),
                        Text('معالجة محلية وسريعة دون حفظ إطارات الكاميرا.', style: theme.textTheme.bodyMedium),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            StatusCard(
              ready: permissions.ready,
              title: permissions.ready ? 'النظام جاهز' : 'أكمل المتطلبات',
              subtitle: permissions.ready
                  ? 'يمكنك بدء تتبع النظر الآن.'
                  : 'فعّل الكاميرا والعرض فوق التطبيقات وإمكانية الوصول.',
            ),
            if (permissions.error != null) ...[
              const SizedBox(height: 12),
              Card(
                color: scheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Text(permissions.error!, style: TextStyle(color: scheme.onErrorContainer)),
                ),
              ),
            ],
            const SizedBox(height: 18),
            Text('التحكم', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            _Action(icon: Icons.shield_outlined, title: 'الصلاحيات', subtitle: 'الكاميرا والعرض فوق التطبيقات وإمكانية الوصول', onTap: () => context.push('/permissions')),
            _Action(icon: Icons.center_focus_strong_rounded, title: 'المعايرة', subtitle: 'اضبط دقة النظر قبل الاستخدام', onTap: () => context.push('/calibration')),
            _Action(icon: Icons.visibility_outlined, title: 'تتبع النظر', subtitle: 'شاهد الإحداثيات والحالة لحظياً', onTap: () => context.push('/tracking')),
            _Action(icon: Icons.settings_outlined, title: 'الإعدادات', subtitle: 'اللغة والوضع الداكن وزمن التثبيت', onTap: () => context.push('/settings')),
            _Action(icon: Icons.info_outline_rounded, title: 'حول NewVision', subtitle: 'الخصوصية والإصدار ومعلومات المشروع', onTap: () => context.push('/about')),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline_rounded, size: 16, color: scheme.outline),
                const SizedBox(width: 7),
                Text('المعالجة محلية على الجهاز', style: theme.textTheme.bodySmall?.copyWith(color: scheme.outline)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({required this.icon, required this.title, required this.subtitle, required this.onTap});

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(color: scheme.primaryContainer, borderRadius: BorderRadius.circular(14)),
                child: Icon(icon, color: scheme.onPrimaryContainer),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 3),
                    Text(subtitle, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
