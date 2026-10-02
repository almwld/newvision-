import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});
  static const completedKey = 'onboarding.done';
  @override State<OnboardingPage> createState() => _OnboardingPageState();
}
class _OnboardingPageState extends State<OnboardingPage> {
  final _controller = PageController();
  int _page = 0;
  bool _busy = false;
  static const _slides = [
    ('تحكم بالنظر، بخصوصية.', 'يعالج NewVision بيانات العين على الجهاز لمتابعة اتجاه نظرك دون رفع إطارات الكاميرا.', Icons.visibility_rounded),
    ('معايرة تناسبك.', 'تساعد المعايرة متعددة النقاط على تحويل خصائص العين إلى موضع دقيق على الشاشة.', Icons.tune_rounded),
    ('جاهز للتفاعل.', 'بعد منح الصلاحيات المطلوبة، يمكنك استخدام النظر كمؤشر للتفاعل والنقر.', Icons.touch_app_rounded),
  ];
  Future<void> _finish() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(OnboardingPage.completedKey, true);
      if (mounted) context.go('/permissions');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
  @override void dispose() { _controller.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 8),
            child: Row(children: [
              Container(width: 42, height: 42, decoration: BoxDecoration(color: scheme.primaryContainer, borderRadius: BorderRadius.circular(13)), child: Icon(Icons.visibility_rounded, color: scheme.onPrimaryContainer)),
              const SizedBox(width: 12),
              Text('NewVision', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
              const Spacer(),
              TextButton(onPressed: _busy ? null : _finish, child: const Text('تخطي')),
            ]),
          ),
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: _slides.length,
              onPageChanged: (value) => setState(() => _page = value),
              itemBuilder: (_, index) {
                final item = _slides[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Container(
                      width: 190, height: 190,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: scheme.primaryContainer, boxShadow: [BoxShadow(color: scheme.primary.withOpacity(.12), blurRadius: 32, spreadRadius: 6)]),
                      child: Icon(item.$3, size: 86, color: scheme.onPrimaryContainer),
                    ),
                    const SizedBox(height: 40),
                    Text(item.$1, textAlign: TextAlign.center, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 14),
                    Text(item.$2, textAlign: TextAlign.center, style: theme.textTheme.bodyLarge?.copyWith(height: 1.55)),
                  ]),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 8, 28, 28),
            child: Column(children: [
              Row(children: [
                Row(children: List.generate(_slides.length, (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsetsDirectional.only(end: 6),
                  width: index == _page ? 26 : 8,
                  height: 8,
                  decoration: BoxDecoration(color: index == _page ? scheme.primary : scheme.outlineVariant, borderRadius: BorderRadius.circular(8)),
                ))),
                const Spacer(),
                Text('${_page + 1}/${_slides.length}', style: theme.textTheme.labelMedium),
              ]),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _busy ? null : () {
                    if (_page == _slides.length - 1) {
                      _finish();
                    } else {
                      _controller.nextPage(duration: const Duration(milliseconds: 260), curve: Curves.easeOutCubic);
                    }
                  },
                  child: Padding(padding: const EdgeInsets.symmetric(vertical: 13), child: Text(_page == _slides.length - 1 ? 'ابدأ الإعداد' : 'التالي')),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}
