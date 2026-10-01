import 'package:flutter/material.dart';
class AboutPage extends StatelessWidget{
  const AboutPage({super.key});
  @override Widget build(BuildContext context){
    final s=Theme.of(context).colorScheme,t=Theme.of(context);
    return Scaffold(appBar:AppBar(title:const Text('حول التطبيق')),body:ListView(padding:const EdgeInsets.fromLTRB(20,12,20,32),children:[
      Container(padding:const EdgeInsets.all(24),decoration:BoxDecoration(color:s.primaryContainer,borderRadius:BorderRadius.circular(28),border:Border.all(color:s.outlineVariant)),child:Column(children:[
        Container(width:88,height:88,decoration:BoxDecoration(color:s.primary,borderRadius:BorderRadius.circular(26)),child:Icon(Icons.visibility_rounded,size:48,color:s.onPrimary)),
        const SizedBox(height:16),Text('NewVision',style:t.textTheme.headlineSmall?.copyWith(fontWeight:FontWeight.w900)),const SizedBox(height:5),const Text('إصدار 1.0.0'),
      ])),
      const SizedBox(height:16),
      _InfoTile(icon:Icons.memory_rounded,title:'المعالجة',subtitle:'تحليل النظر محلياً على الجهاز باستخدام CameraX وMediaPipe.'),
      _InfoTile(icon:Icons.lock_outline_rounded,title:'الخصوصية',subtitle:'لا يتم إرسال صور الكاميرا إلى خادم ضمن مسار المعالجة المحلي.'),
      _InfoTile(icon:Icons.tune_rounded,title:'المعايرة',subtitle:'نموذج شخصي محفوظ محلياً لتحسين موضع المؤشر.'),
      const SizedBox(height:18),
      Card(color:s.surfaceContainerLow,child:Padding(padding:const EdgeInsets.all(16),child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[Icon(Icons.info_outline_rounded,color:s.primary),const SizedBox(width:12),Expanded(child:Text('تحتاج ميزات التحكم بالنظام إلى منح الصلاحيات المطلوبة من إعدادات Android. يمكنك مراجعة الجاهزية من شاشة الصلاحيات.',style:t.textTheme.bodyMedium?.copyWith(height:1.45)))]))),
    ]));
  }
}
class _InfoTile extends StatelessWidget{
  const _InfoTile({required this.icon,required this.title,required this.subtitle});
  final IconData icon;final String title,subtitle;
  @override Widget build(BuildContext c){final s=Theme.of(c).colorScheme;return Card(margin:const EdgeInsets.only(bottom:10),child:ListTile(contentPadding:const EdgeInsets.symmetric(horizontal:16,vertical:7),leading:Container(width:44,height:44,decoration:BoxDecoration(color:s.primaryContainer,borderRadius:BorderRadius.circular(14)),child:Icon(icon,color:s.onPrimaryContainer)),title:Text(title,style:Theme.of(c).textTheme.titleSmall?.copyWith(fontWeight:FontWeight.w800)),subtitle:Padding(padding:const EdgeInsets.only(top:3),child:Text(subtitle)));}
}