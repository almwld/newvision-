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
        title: const Text('NewVision'),
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: 'الإعدادات',
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: permissions.refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            Text(
              'تحكم بنظرك',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'تجربة تحكم محلية وآمنة باستخدام تتبع العين.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            StatusCard(
              ready: permissions.ready,
              title: permissions.ready ? 'النظام جاهز' : 'أكمل الإعداد',
              subtitle: permissions.ready
                  ? 'كل المتطلبات متاحة ويمكنك بدء تتبع النظر.'
                  : 'فعّل الكاميرا والعرض فوق التطبيقات وإمكانية الوصول.',
            ),
            if (permissions.error != null) ...[
              const SizedBox(height: 12),
              _ErrorBanner(message: permissions.error!),
            ],
            const SizedBox(height: 20),
            Text(
              'التحكم',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            _Action(
              icon: Icons.visibility_outlined,
              title: 'تتبع النظر',
              subtitle: permissions.ready
                  ? 'ابدأ جلسة التتبع ومراقبة الحالة.'
                  : 'أكمل المتطلبات أولًا.',
              enabled: permissions.ready,
              onTap: () => context.push('/tracking'),
            ),
            _Action(
              icon: Icons.center_focus_strong_outlined,
              title: 'المعايرة',
              subtitle: 'اضبط دقة المؤشر حسب الشاشة ونمط نظرك.',
              onTap: () => context.push('/calibration'),
            ),
            const SizedBox(height: 12),
            Text(
              'الإعداد',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            _Action(
              icon: Icons.shield_outlined,
              title: 'الصلاحيات',
              subtitle: permissions.ready
                  ? 'جميع الصلاحيات المطلوبة مفعّلة.'
                  : 'تحقق من الصلاحيات المطلوبة للتشغيل.',
              onTap: () => context.push('/permissions'),
            ),
            _Action(
              icon: Icons.info_outline,
              title: 'حول NewVision',
              subtitle: 'الخصوصية، الإصدار ومعلومات التطبيق.',
              onTap: () => context.push('/about'),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lock_outline, color: scheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'المعالجة تتم محليًا على الجهاز، ولا يتم حفظ إطارات الكاميرا.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.enabled = true,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: enabled ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  icon,
                  color: scheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
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

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: scheme.onErrorContainer),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: scheme.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }
}
