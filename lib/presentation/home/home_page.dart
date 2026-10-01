import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/calibration_provider.dart';
import '../providers/permission_provider.dart';
import '../providers/tracking_provider.dart';
import '../widgets/status_card.dart';
import '../widgets/status_indicator.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    final permissions = context.watch<PermissionProvider>();
    final calibration = context.watch<CalibrationProvider>();
    final tracking = context.watch<TrackingProvider>();
    final scheme = Theme.of(context).colorScheme;
    final ready = permissions.ready && calibration.ready;
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: permissions.refresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
            children: [
              Row(children: [
                Container(width: 52,height: 52,decoration: BoxDecoration(color: scheme.primaryContainer,borderRadius: BorderRadius.circular(16)),child: Icon(Icons.visibility_rounded,color: scheme.onPrimaryContainer,size: 28)),
                const SizedBox(width: 14),
                const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,children: [
                  Text('NewVision',style: TextStyle(fontSize: 24,fontWeight: FontWeight.w800)),
                  SizedBox(height: 3),Text('تحكم بالنظر على الجهاز'),
                ])),
                IconButton(tooltip: 'الإعدادات',onPressed: () => context.push('/settings'),icon: const Icon(Icons.settings_outlined)),
              ]),
              const SizedBox(height: 22),
              StatusCard(
                ready: ready,
                title: ready ? 'جاهز للاستخدام' : 'أكمل الإعداد',
                subtitle: ready ? 'الصلاحيات والمعايرة جاهزتان لبدء التتبع.' : 'تحتاج إلى الصلاحيات والمعايرة قبل الاستخدام الدقيق.',
                actionLabel: ready ? 'بدء التتبع' : 'مراجعة المتطلبات',
                onAction: () => context.push(ready ? '/tracking' : '/permissions'),
              ),
              const SizedBox(height: 14),
              Card(child: Padding(padding: const EdgeInsets.all(18),child: Column(crossAxisAlignment: CrossAxisAlignment.start,children: [
                Text('حالة النظام',style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 16),
                Wrap(spacing: 16,runSpacing: 12,children: [
                  StatusIndicator(active: permissions.ready,label: permissions.ready ? 'الصلاحيات جاهزة' : 'الصلاحيات ناقصة'),
                  StatusIndicator(active: calibration.ready,label: calibration.ready ? 'المعايرة جاهزة' : 'غير معاير'),
                  StatusIndicator(active: tracking.latest != null,label: tracking.latest != null ? 'التتبع متصل' : 'التتبع متوقف'),
                ]),
              ]))),
              const SizedBox(height: 14),
              _ActionCard(icon: Icons.tune_rounded,title: calibration.ready ? 'إعادة المعايرة' : 'معايرة النظر',subtitle: 'اضبط النموذج حسب وضعية نظرك الحالية.',onTap: () => context.push('/calibration')),
              _ActionCard(icon: Icons.visibility_rounded,title: 'تتبع النظر',subtitle: 'راقب الإحداثيات والثقة وحالة الرمش لحظياً.',enabled: permissions.ready,onTap: () => context.push('/tracking')),
              _ActionCard(icon: Icons.shield_outlined,title: 'الصلاحيات',subtitle: 'راجع حالة الكاميرا والعرض فوق التطبيقات وإمكانية الوصول.',onTap: () => context.push('/permissions')),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: scheme.secondaryContainer.withOpacity(0.55),borderRadius: BorderRadius.circular(18)),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start,children: [
                  Icon(Icons.lock_outline_rounded,color: scheme.onSecondaryContainer),
                  const SizedBox(width: 12),
                  Expanded(child: Text('الخصوصية أولاً: معالجة العين تتم محلياً على الجهاز ولا تحتاج إطارات الكاميرا إلى الرفع إلى خادم.',style: TextStyle(color: scheme.onSecondaryContainer))),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.icon,required this.title,required this.subtitle,required this.onTap,this.enabled = true});
  final IconData icon; final String title; final String subtitle; final VoidCallback onTap; final bool enabled;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(child: InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(20),
      child: Padding(padding: const EdgeInsets.all(14),child: Row(children: [
        Container(width: 46,height: 46,decoration: BoxDecoration(color: enabled ? scheme.primaryContainer : scheme.surfaceContainerHighest,borderRadius: BorderRadius.circular(14)),child: Icon(icon,color: enabled ? scheme.onPrimaryContainer : scheme.onSurfaceVariant)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,children: [
          Text(title,style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 3),Text(subtitle,style: Theme.of(context).textTheme.bodySmall),
        ])),
        const SizedBox(width: 8),
        Icon(Icons.arrow_forward_ios_rounded,size: 16,color: enabled ? null : scheme.onSurfaceVariant),
      ])),
    ));
  }
}
