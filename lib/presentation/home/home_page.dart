import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/calibration_provider.dart';
import '../providers/permission_provider.dart';
import '../widgets/status_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override Widget build(BuildContext context) {
    final p=context.watch<PermissionProvider>();
    final c=context.watch<CalibrationProvider>();
    final t=Theme.of(context),s=t.colorScheme;
    final ready=p.ready;
    return Scaffold(
      appBar:AppBar(title:const Text('NewVision'),actions:[IconButton(tooltip:'الإعدادات',onPressed:()=>context.push('/settings'),icon:const Icon(Icons.settings_outlined))]),
      body:RefreshIndicator(
        onRefresh:() async {await p.refresh();await c.refresh();},
        child:ListView(physics:const AlwaysScrollableScrollPhysics(),padding:const EdgeInsets.fromLTRB(20,8,20,32),children:[
          Container(padding:const EdgeInsets.all(22),decoration:BoxDecoration(
            gradient:LinearGradient(colors:[s.primaryContainer,s.surfaceContainerHighest],begin:AlignmentDirectional.topStart,end:AlignmentDirectional.bottomEnd),
            borderRadius:BorderRadius.circular(28),border:Border.all(color:s.outlineVariant)),
            child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
              Container(width:58,height:58,decoration:BoxDecoration(color:s.primary,borderRadius:BorderRadius.circular(18)),child:Icon(Icons.visibility_rounded,color:s.onPrimary,size:30)),
              const SizedBox(height:20),
              Text('تحكم بعينيك',style:t.textTheme.headlineSmall?.copyWith(fontWeight:FontWeight.w900)),
              const SizedBox(height:6),
              Text('تحكم بالنظر يعمل محلياً على جهازك مع تركيز على الخصوصية والاستجابة.',style:t.textTheme.bodyMedium?.copyWith(height:1.45)),
              const SizedBox(height:18),
              FilledButton.icon(onPressed:ready?()=>context.push('/tracking'):()=>context.push('/permissions'),icon:Icon(ready?Icons.play_arrow_rounded:Icons.shield_outlined),label:Text(ready?'بدء التتبع':'إكمال الإعداد')),
            ])),
          const SizedBox(height:16),
          StatusCard(ready:ready,title:ready?'النظام جاهز':'الإعداد غير مكتمل',subtitle:ready?'الصلاحيات الأساسية متاحة ويمكنك بدء التتبع.':'فعّل الكاميرا والعرض فوق التطبيقات وإمكانية الوصول.'),
          const SizedBox(height:14),
          Card(color:s.surfaceContainerLow,child:Padding(padding:const EdgeInsets.all(16),child:Row(children:[
            Icon(Icons.tune_rounded,color:s.primary),const SizedBox(width:12),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
              Text('حالة المعايرة',style:t.textTheme.titleSmall?.copyWith(fontWeight:FontWeight.w800)),
              const SizedBox(height:3),Text(c.ready?'معايرة محفوظة وجاهزة.':'لم يتم حفظ معايرة شخصية بعد.',style:t.textTheme.bodySmall),
            ])),
            TextButton(onPressed:()=>context.push('/calibration'),child:Text(c.ready?'إعادة':'معايرة')),
          ]))),
          const SizedBox(height:22),
          Text('التحكم',style:t.textTheme.titleLarge?.copyWith(fontWeight:FontWeight.w900)),
          const SizedBox(height:10),
          _Action(icon:Icons.shield_outlined,title:'الصلاحيات',subtitle:'إدارة متطلبات التشغيل',onTap:()=>context.push('/permissions')),
          _Action(icon:Icons.center_focus_strong_rounded,title:'المعايرة',subtitle:'تحسين دقة موضع النظر',onTap:()=>context.push('/calibration')),
          _Action(icon:Icons.visibility_outlined,title:'تتبع النظر',subtitle:'الحالة والإحداثيات وجودة الإشارة',onTap:()=>context.push('/tracking')),
          _Action(icon:Icons.settings_outlined,title:'الإعدادات',subtitle:'المظهر واللغة وزمن التثبيت',onTap:()=>context.push('/settings')),
          _Action(icon:Icons.info_outline_rounded,title:'حول NewVision',subtitle:'الخصوصية والإصدار',onTap:()=>context.push('/about')),
          const SizedBox(height:18),
          Row(mainAxisAlignment:MainAxisAlignment.center,children:[Icon(Icons.lock_outline_rounded,size:16,color:s.outline),const SizedBox(width:7),Text('المعالجة محلية على الجهاز',style:t.textTheme.bodySmall?.copyWith(color:s.outline))]),
        ]),
      ),
    );
  }
}
class _Action extends StatelessWidget {
  const _Action({required this.icon,required this.title,required this.subtitle,required this.onTap});
  final IconData icon;final String title,subtitle;final VoidCallback onTap;
  @override Widget build(BuildContext context){final t=Theme.of(context),s=t.colorScheme;return Card(margin:const EdgeInsets.only(bottom:10),child:InkWell(borderRadius:BorderRadius.circular(20),onTap:onTap,child:Padding(padding:const EdgeInsets.all(14),child:Row(children:[
    Container(width:46,height:46,decoration:BoxDecoration(color:s.primaryContainer,borderRadius:BorderRadius.circular(14)),child:Icon(icon,color:s.onPrimaryContainer)),
    const SizedBox(width:14),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:t.textTheme.titleMedium?.copyWith(fontWeight:FontWeight.w800)),const SizedBox(height:3),Text(subtitle,style:t.textTheme.bodySmall)])),
    Icon(Icons.arrow_forward_ios_rounded,size:16,color:s.outline),
  ]))));}
}