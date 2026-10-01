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
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('NewVision'), actions: [IconButton(tooltip: 'الإعدادات', onPressed: () => context.push('/settings'), icon: const Icon(Icons.settings_outlined))]),
      body: RefreshIndicator(
        onRefresh: permissions.refresh,
        child: ListView(physics: const AlwaysScrollableScrollPhysics(), padding: const EdgeInsets.fromLTRB(20, 8, 20, 32), children: [
          Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(borderRadius: BorderRadius.circular(28), gradient: LinearGradient(colors: [scheme.primary, scheme.primaryContainer], begin: AlignmentDirectional.topStart, end: AlignmentDirectional.bottomEnd)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.visibility_rounded, size: 34, color: scheme.onPrimary), const SizedBox(height: 20),
            Text('تحكم أكثر سهولة بالنظر', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: scheme.onPrimary, fontWeight: FontWeight.w800)), const SizedBox(height: 8),
            Text('معالجة محلية، خصوصية أولاً، وتجربة مصممة للاستخدام اليومي.', style: TextStyle(color: scheme.onPrimary.withOpacity(.88))),
          ])),
          const SizedBox(height: 16),
          StatusCard(ready: permissions.ready, title: permissions.ready ? 'الجهاز جاهز' : 'أكمل متطلبات التشغيل', subtitle: permissions.ready ? 'يمكنك بدء تتبع النظر.' : 'الكاميرا والعرض فوق التطبيقات وإمكانية الوصول مطلوبة.'),
          const SizedBox(height: 14),
          _Action(icon: Icons.shield_outlined, title: 'الصلاحيات والجاهزية', subtitle: permissions.ready ? 'جميع المتطلبات مفعلة' : 'تحقق من المتطلبات', onTap: () => context.push('/permissions')),
          _Action(icon: Icons.tune_rounded, title: 'المعايرة', subtitle: 'اضبط النموذج لعينك وشاشتك', onTap: () => context.push('/calibration')),
          _Action(icon: Icons.visibility_rounded, title: 'تتبع النظر', subtitle: 'عرض الإشارة والموضع والثقة لحظياً', onTap: permissions.ready ? () => context.push('/tracking') : () => context.push('/permissions')),
          _Action(icon: Icons.info_outline_rounded, title: 'حول NewVision', subtitle: 'الخصوصية والإصدار ومعلومات التطبيق', onTap: () => context.push('/about')),
          const SizedBox(height: 16), Text('لا يتم حفظ إطارات الكاميرا؛ المعالجة تتم محلياً على الجهاز.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
        ]),
      ),
    );
  }
}
class _Action extends StatelessWidget {
  const _Action({required this.icon, required this.title, required this.subtitle, required this.onTap});
  final IconData icon; final String title; final String subtitle; final VoidCallback onTap;
  @override Widget build(BuildContext context) { final scheme = Theme.of(context).colorScheme; return Card(clipBehavior: Clip.antiAlias, child: InkWell(onTap: onTap, child: Padding(padding: const EdgeInsets.all(14), child: Row(children: [Container(width: 46, height: 46, decoration: BoxDecoration(color: scheme.primaryContainer, borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: scheme.onPrimaryContainer)), const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w800)), const SizedBox(height: 3), Text(subtitle, style: Theme.of(context).textTheme.bodySmall)])), const Icon(Icons.arrow_forward_ios_rounded, size: 16)])))); }
}
