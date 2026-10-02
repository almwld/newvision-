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
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 36),
          children: [
            _HeroCard(ready: ready),
            const SizedBox(height: 18),
            StatusCard(
              ready: ready,
              title: ready ? 'جاهز للتحكم بالنظر' : 'أكمل إعداد NewVision',
              subtitle: ready
                  ? 'الصلاحيات والمعايرة جاهزتان. يمكنك بدء جلسة التتبع.'
                  : 'فعّل الصلاحيات المطلوبة ثم نفّذ المعايرة للحصول على أفضل استقرار.',
            ),
            const SizedBox(height: 26),
            Text('الوصول السريع', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -.2)),
            const SizedBox(height: 12),
            _Action(icon: Icons.shield_outlined, title: 'الصلاحيات', subtitle: 'الكاميرا، العرض فوق التطبيقات وإمكانية الوصول', onTap: () => context.push('/permissions')),
            _Action(icon: Icons.center_focus_strong_rounded, title: 'المعايرة', subtitle: calibration.ready ? 'معايرة شخصية محفوظة محلياً' : 'أنشئ معايرة من 9 نقاط', onTap: () => context.push('/calibration')),
            _Action(icon: Icons.visibility_rounded, title: 'تتبع النظر', subtitle: 'مراقبة الإشارة والثقة لحظياً', onTap: () => context.push('/tracking')),
            _Action(icon: Icons.tune_rounded, title: 'الإعدادات', subtitle: 'المظهر، اللغة ومدة التثبيت', onTap: () => context.push('/settings')),
            const SizedBox(height: 10),
            _PrivacyCard(scheme: scheme),
          ],
        ),
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
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: scheme.primary,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: scheme.primary.withOpacity(.18), blurRadius: 28, offset: const Offset(0, 12))],
      ),
      child: Row(children: [
        Container(
          width: 62,
          height: 62,
          decoration: BoxDecoration(color: scheme.onPrimary.withOpacity(.14), borderRadius: BorderRadius.circular(20), border: Border.all(color: scheme.onPrimary.withOpacity(.16))),
          child: Icon(ready ? Icons.check_rounded : Icons.visibility_rounded, color: scheme.onPrimary, size: 34),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(ready ? 'النظام جاهز' : 'تحكم أسهل بنظرك', style: TextStyle(color: scheme.onPrimary, fontSize: 22, height: 1.15, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text(ready ? 'ابدأ التتبع واستعمل نظرك كمؤشر تفاعل.' : 'إعداد بسيط، معالجة محلية، وتجربة مصممة للاستخدام اليومي.', style: TextStyle(color: scheme.onPrimary.withOpacity(.86), height: 1.45)),
          ]),
        ),
      ]),
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
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(children: [
            Container(width: 48, height: 48, decoration: BoxDecoration(color: scheme.primaryContainer, borderRadius: BorderRadius.circular(15)), child: Icon(icon, color: scheme.onPrimaryContainer, size: 24)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.35)),
            ])),
            Icon(Directionality.of(context) == TextDirection.rtl ? Icons.arrow_back_ios_new_rounded : Icons.arrow_forward_ios_rounded, size: 16, color: scheme.outline),
          ]),
        ),
      ),
    );
  }
}

class _PrivacyCard extends StatelessWidget {
  const _PrivacyCard({required this.scheme});
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: scheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(Icons.lock_outline_rounded, color: scheme.primary),
          const SizedBox(width: 12),
          Expanded(child: Text('الخصوصية أولاً: مسار تحليل النظر مصمم ليعمل محلياً على الجهاز، ولا يرفع إطارات الكاميرا إلى خادم.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.45))),
        ]),
      ),
    );
  }
}
