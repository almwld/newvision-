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
    final scheme = Theme.of(context).colorScheme;
    final ready = permissions.ready && calibration.ready;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            pinned: true,
            title: const Text('NewVision'),
            actions: [
              IconButton(
                tooltip: 'الإعدادات',
                onPressed: () => context.push('/settings'),
                icon: const Icon(Icons.settings_outlined),
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _HeroCard(ready: ready),
                const SizedBox(height: 16),
                StatusCard(
                  ready: ready,
                  title: ready ? 'جاهز للتحكم بالنظر' : 'أكمل إعداد NewVision',
                  subtitle: ready
                      ? 'المعايرة والصلاحيات الأساسية جاهزة.'
                      : 'فعّل الصلاحيات وأكمل المعايرة للحصول على تجربة مستقرة.',
                ),
                const SizedBox(height: 24),
                Text(
                  'الأدوات',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
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
                const SizedBox(height: 18),
                Card(
                  color: scheme.primaryContainer.withOpacity(0.65),
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
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.ready});

  final bool ready;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return DecoratedBox(
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
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: scheme.onPrimary.withOpacity(0.14),
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
                    style: TextStyle(color: scheme.onPrimary.withOpacity(0.84)),
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
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
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
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
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
