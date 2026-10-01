import 'package:flutter/material.dart';
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});
  @override Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(appBar: AppBar(title: const Text('حول التطبيق')), body: ListView(padding: const EdgeInsets.fromLTRB(24, 20, 24, 32), children: [
      Center(child: Container(width: 96, height: 96, decoration: BoxDecoration(color: scheme.primaryContainer, borderRadius: BorderRadius.circular(28)),
        child: Icon(Icons.visibility_rounded, size: 52, color: scheme.onPrimaryContainer))),
      const SizedBox(height: 18),
      Center(child: Text('NewVision', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800))),
      const SizedBox(height: 6), const Center(child: Text('إصدار 1.0.0')),
      const SizedBox(height: 26),
      Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('عن NewVision', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        const Text('نظام تحكم بالنظر يعمل على الجهاز باستخدام CameraX وMediaPipe، مع تصميم يركز على الخصوصية وتقليل الاعتماد على الخدمات السحابية.'),
      ]))),
      const SizedBox(height: 12),
      const _InfoTile(icon: Icons.memory_rounded, title: 'المعالجة', subtitle: 'محلية على الجهاز'),
      const _InfoTile(icon: Icons.lock_outline_rounded, title: 'الخصوصية', subtitle: 'لا يتم إرسال صور الكاميرا إلى خادم'),
      const _InfoTile(icon: Icons.tune_rounded, title: 'المعايرة', subtitle: 'نموذج شخصي محفوظ محلياً'),
      const SizedBox(height: 24),
      Text('ملاحظة', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
      const SizedBox(height: 6), const Text('تحتاج ميزات التحكم بالنظام إلى منح الصلاحيات المطلوبة من إعدادات Android.'),
    ]));
  }
}
class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.icon, required this.title, required this.subtitle});
  final IconData icon; final String title; final String subtitle;
  @override Widget build(BuildContext context) => Card(child: ListTile(leading: Icon(icon, color: Theme.of(context).colorScheme.primary), title: Text(title), subtitle: Text(subtitle)));
}
