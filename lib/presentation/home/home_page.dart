import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/calibration_provider.dart';
import '../providers/permission_provider.dart';
import '../widgets/status_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final permissions = context.watch<PermissionProvider>();
    final calibration = context.watch<CalibrationProvider>();
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final ready = permissions.ready && calibration.ready;

    return Scaffold(
      appBar: AppBar(
        title: const Text('NewVision'),
        actions: [
          IconButton(
            tooltip: 'الإعدادات',
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await permissions.refresh();
          await calibration.refresh();
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    scheme.primary,
                    Color.alphaBlend(scheme.primaryContainer, scheme.primary),
                  ],
                  begin: AlignmentDirectional.topStart,
                  end: AlignmentDirectional.bottomEnd,
                ),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: scheme.onPrimary.withOpacity(.14),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      ready ? Icons.check_rounded : Icons.visibility_rounded,
                      color: scheme.onPrimary,
                      size: 34,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ready ? 'كل شيء جاهز' : 'تحكم أكثر سهولة',
                          style: TextStyle(
                            color: scheme.onPrimary,
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          ready
                              ? 'يمكنك بدء جلسة التتبع الآن.'
                              : 'وجّه نظرك واترك NewVision يتولى الباقي.',
                          style: TextStyle(
                            color: scheme.onPrimary.withOpacity(.84),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            StatusCard(
              ready: ready,
              title: ready ? 'جاهز للتحكم بالنظر' : 'أكمل إعداد NewVision',
              subtitle: ready
                  ? 'المعايرة والصلاحيات الأساسية جاهزة.'
                  : 'فعّل الصلاحيات وأكمل المعايرة للحصول على تجربة مستقرة.',
            ),
            const SizedBox(height: 18),
            Text(
              'الأدوات',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            _Action(
              icon: Icons.shield_outlined,
              title: 'الصلاحيات',
              subtitle: 'الكاميرا، العرض وإمكانية الوصول',
              onTap: () => context.push('/permissions'),
            ),
            _Action(
              icon: Icons.center_focus_strong_rounded,
              title: 'المعايرة',
              subtitle: calibration.ready
                  ? 'المعايرة محفوظة محلياً'
                  : 'أنشئ معايرة شخصية جديدة',
              onTap: () => context.push('/calibration'),
            ),
            _Action(
              icon: Icons.visibility_rounded,
              title: 'تتبع النظر',
              subtitle: 'عرض الإشارة والثقة لحظياً',
              onTap: () => context.push('/tracking'),
            ),
            _Action(
              icon: Icons.settings_outlined,
              title: 'الإعدادات',
              subtitle: 'المظهر واللغة وزمن التثبيت',
              onTap: () => context.push('/settings'),
            ),
            _Action(
              icon: Icons.info_outline_rounded,
              title: 'حول NewVision',
              subtitle: 'الخصوصية والإصدار',
              onTap: () => context.push('/about'),
            ),
            const SizedBox(height: 18),
            Card(
              color: scheme.primaryContainer.withOpacity(.65),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.lock_outline_rounded,
                      color: scheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'المعالجة محلية على الجهاز. لا يتم رفع إطارات الكاميرا إلى خادم.',
                        style: TextStyle(color: scheme.onPrimaryContainer),
                      ),
                    ),
                  ],
                ),
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
  });

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
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: scheme.onPrimaryContainer),
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
                    Text(subtitle, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: scheme.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
