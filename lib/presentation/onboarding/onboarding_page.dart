import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});
  Future<void> _continue(BuildContext context) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool('onboarding.done', true);
    if (context.mounted) context.go('/permissions');
  }
  @override Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(body: SafeArea(child: Padding(padding: const EdgeInsets.fromLTRB(24, 20, 24, 24), child: Column(children: [
      Align(alignment: AlignmentDirectional.centerStart, child: Text('مرحباً بك', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700))),
      const Spacer(),
      Container(width: 128, height: 128, decoration: BoxDecoration(color: scheme.primaryContainer, shape: BoxShape.circle),
        child: Icon(Icons.visibility_rounded, size: 68, color: scheme.onPrimaryContainer)),
      const SizedBox(height: 30),
      Text('تحكم بالنظر، بخصوصية.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
      const SizedBox(height: 12),
      const Text('يعالج NewVision بيانات العين على الجهاز لمساعدة المؤشر على متابعة اتجاه نظرك دون رفع إطارات الكاميرا.', textAlign: TextAlign.center),
      const SizedBox(height: 22),
      const _Feature(icon: Icons.memory_rounded, title: 'معالجة محلية', subtitle: 'التحليل يتم على هاتفك.'),
      const _Feature(icon: Icons.lock_outline_rounded, title: 'خصوصية أولاً', subtitle: 'لا نحتاج إلى خادم للصور.'),
      const _Feature(icon: Icons.tune_rounded, title: 'معايرة شخصية', subtitle: 'اضبط التتبع حسب نظرك.'),
      const Spacer(),
      SizedBox(width: double.infinity, child: FilledButton(onPressed: () => _continue(context),
        child: const Padding(padding: EdgeInsets.symmetric(vertical: 14), child: Text('ابدأ الإعداد')))),
    ]))));
  }
}
class _Feature extends StatelessWidget {
  const _Feature({required this.icon, required this.title, required this.subtitle});
  final IconData icon; final String title; final String subtitle;
  @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(vertical: 7), child: Row(children: [
    Icon(icon, size: 22, color: Theme.of(context).colorScheme.primary), const SizedBox(width: 14),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontWeight: FontWeight.w700)), Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
    ])),
  ]));
}
