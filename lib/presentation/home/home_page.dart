import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/calibration_provider.dart';
import '../providers/permission_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/status_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    final permissions = context.watch<PermissionProvider>();
    final calibration = context.watch<CalibrationProvider>();
    final settings = context.watch<SettingsProvider>();
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('NewVision'), actions: [
        IconButton(tooltip: 'الإعدادات', onPressed: () => context.push('/settings'), icon: const Icon(Icons.settings_outlined)),
      ]),
      body: RefreshIndicator(
        onRefresh: permissions.refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: LinearGradient(begin: AlignmentDirectional.topStart, end: AlignmentDirectional.bottomEnd, colors: [scheme.primaryContainer, scheme.surface]),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: scheme.outlineVariant),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(width: 54, height: 54, decoration: BoxDecoration(color: scheme.primary, borderRadius: BorderRadius.circular(17)),
                  child: Icon(Icons.visibility_rounded, color: scheme.onPrimary, size: 30)),
                const SizedBox(height: 20),
                Text('تحكم بالنظر، على جهازك.', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, height: 1.15)),
                const SizedBox(height: 8),
                Text('NewVision يحوّل اتجاه النظر إلى مؤشر تفاعل مع معالجة محلية للبيانات.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.45)),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: permissions.ready ? () => context.push('/tracking') : () => context.push('/permissions'),
                  icon: Icon(permissions.ready ? Icons.play_arrow_rounded : Icons.shield_outlined),
                  label: Text(permissions.ready ? 'بدء التتبع' : 'إكمال الجاهزية'),
                ),
              ]),
            ),
            const SizedBox(height: 14),
            StatusCard(
              ready: permissions.ready,
              title: permissions.ready ? 'جاهز للتشغيل' : 'هناك متطلبات متبقية',
              subtitle: permissions.ready ? 'الكاميرا والعرض فوق التطبيقات وإمكانية الوصول مفعّلة.' : 'أكمل الصلاحيات الأساسية قبل بدء التحكم بالنظر.',
            ),
            const SizedBox(height: 14),
            const _SectionHeader(title: 'الوصول السريع'),
            const SizedBox(height: 8),
            _ActionTile(icon: Icons.shield_outlined, title: 'الصلاحيات',
              subtitle: 'المكتمل: ' + permissions.completedCount.toString() + ' من 3', onTap: () => context.push('/permissions')),
            const SizedBox(height: 10),
            _ActionTile(icon: Icons.tune_rounded, title: 'المعايرة',
              subtitle: calibration.ready ? 'المعايرة محفوظة وجاهزة' : 'أنشئ معايرة شخصية لتحسين الدقة',
              trailing: calibration.ready ? Icon(Icons.check_circle_rounded, color: scheme.primary) : null,
              onTap: () => context.push('/calibration')),
            const SizedBox(height: 10),
            _ActionTile(icon: Icons.visibility_rounded, title: 'تتبع النظر',
              subtitle: permissions.ready ? 'عرض البيانات الحية وجودة الإشارة' : 'يتطلب اكتمال الصلاحيات',
              onTap: permissions.ready ? () => context.push('/tracking') : () => context.push('/permissions')),
            const SizedBox(height: 18),
            const _SectionHeader(title: 'حالة التجربة'),
            const SizedBox(height: 8),
            Card(child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [
              Icon(settings.darkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded, color: scheme.primary),
              const SizedBox(width: 12),
              Expanded(child: Text(settings.darkMode ? 'الوضع الداكن مفعّل' : 'الوضع الفاتح مفعّل',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700))),
              TextButton(onPressed: () => context.push('/settings'), child: const Text('تعديل')),
            ]))),
            const SizedBox(height: 18),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.lock_outline_rounded, size: 16, color: scheme.primary),
              const SizedBox(width: 7),
              Flexible(child: Text('المعالجة محلية ولا يتم حفظ إطارات الكاميرا.', textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall)),
            ]),
          ],
        ),
      ),
    );
  }
}
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;
  @override Widget build(BuildContext context) => Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800));
}
class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.icon, required this.title, required this.subtitle, required this.onTap, this.trailing});
  final IconData icon; final String title; final String subtitle; final VoidCallback onTap; final Widget? trailing;
  @override Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(child: InkWell(onTap: onTap, child: Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 10, 12),
      child: Row(children: [
        Container(width: 46, height: 46, decoration: BoxDecoration(color: scheme.primaryContainer, borderRadius: BorderRadius.circular(14)),
          child: Icon(icon, color: scheme.onPrimaryContainer)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 3), Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
        ])),
        trailing ?? const Icon(Icons.chevron_right_rounded),
      ]),
    )));
  }
}
