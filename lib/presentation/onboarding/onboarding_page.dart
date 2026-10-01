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
  static const _slides = [
    ('تحكم بالنظر، بخصوصية.', 'يعالج NewVision بيانات العين على الجهاز لمتابعة اتجاه نظرك دون رفع إطارات الكاميرا.', Icons.visibility_rounded),
    ('معايرة تناسبك.', 'تساعد المعايرة متعددة النقاط على تحويل خصائص العين إلى موضع دقيق على الشاشة.', Icons.tune_rounded),
    ('جاهز للتفاعل.', 'بعد منح الصلاحيات المطلوبة، يمكنك استخدام النظر كمؤشر للتفاعل.', Icons.touch_app_rounded),
  ];
  Future<void> _finish() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(OnboardingPage.completedKey, true);
    if (mounted) context.go('/permissions');
  }
  @override void dispose() { _controller.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(body: SafeArea(child: Column(children: [
      Padding(padding: const EdgeInsets.fromLTRB(24,18,24,8), child: Row(children: [
        Text('NewVision', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
        const Spacer(), TextButton(onPressed: _finish, child: const Text('تخطي')),
      ])),
      Expanded(child: PageView.builder(controller: _controller, itemCount: _slides.length, onPageChanged: (v)=>setState(()=>_page=v),
        itemBuilder: (_,i) { final s=_slides[i]; return Padding(padding: const EdgeInsets.symmetric(horizontal:28), child: Column(mainAxisAlignment: MainAxisAlignment.center, children:[
          Container(width:156,height:156,decoration:BoxDecoration(shape:BoxShape.circle,color:theme.colorScheme.primaryContainer),child:Icon(s.$3,size:78,color:theme.colorScheme.onPrimaryContainer)),
          const SizedBox(height:36), Text(s.$1,textAlign:TextAlign.center,style:theme.textTheme.headlineSmall?.copyWith(fontWeight:FontWeight.w800)),
          const SizedBox(height:14), Text(s.$2,textAlign:TextAlign.center,style:theme.textTheme.bodyLarge),
        ])); })),
      Padding(padding: const EdgeInsets.fromLTRB(28,8,28,28), child: Row(children:[
        Row(children:List.generate(_slides.length,(i)=>AnimatedContainer(duration:const Duration(milliseconds:180),margin:const EdgeInsetsDirectional.only(end:6),width:i==_page?24:8,height:8,decoration:BoxDecoration(color:i==_page?theme.colorScheme.primary:theme.colorScheme.outlineVariant,borderRadius:BorderRadius.circular(8))))),
        const Spacer(), FilledButton(onPressed:()=>_page==_slides.length-1?_finish():_controller.nextPage(duration:const Duration(milliseconds:260),curve:Curves.easeOutCubic),child:Text(_page==_slides.length-1?'ابدأ الإعداد':'التالي')),
      ])),
    ])));
  }
}
