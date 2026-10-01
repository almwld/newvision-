import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/permission_provider.dart';
import '../providers/calibration_provider.dart';
import '../providers/tracking_provider.dart';
import '../widgets/status_card.dart';
import '../widgets/status_indicator.dart';
class HomePage extends StatelessWidget {
 const HomePage({super.key});
 @override Widget build(BuildContext context){
  final p=context.watch<PermissionProvider>(); final c=context.watch<CalibrationProvider>(); final t=context.watch<TrackingProvider>(); final s=Theme.of(context).colorScheme;
  return Scaffold(body:SafeArea(child:RefreshIndicator(onRefresh:p.refresh,child:ListView(physics:const AlwaysScrollableScrollPhysics(),padding:const EdgeInsets.fromLTRB(20,18,20,28),children:[
   Row(children:[Container(width:48,height:48,decoration:BoxDecoration(color:s.primaryContainer,borderRadius:BorderRadius.circular(16)),child:Icon(Icons.visibility_rounded,color:s.onPrimaryContainer)),const SizedBox(width:14),const Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('NewVision',style:TextStyle(fontSize:24,fontWeight:FontWeight.w800)),SizedBox(height:2),Text('تحكم بالنظر على الجهاز',style:TextStyle(fontSize:13))])),IconButton(tooltip:'الإعدادات',onPressed:()=>context.push('/settings'),icon:const Icon(Icons.settings_outlined))]),
   const SizedBox(height:22),StatusCard(ready:p.ready,title:p.ready?'النظام جاهز':'أكمل المتطلبات',subtitle:p.ready?'يمكنك تشغيل تتبع النظر الآن.':'الكاميرا والعرض فوق التطبيقات وإمكانية الوصول مطلوبة.'),
   const SizedBox(height:18),Card(child:Padding(padding:const EdgeInsets.all(18),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    Text('حالة النظام',style:Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight:FontWeight.w700)),const SizedBox(height:16),
    Wrap(spacing:12,runSpacing:10,children:[StatusIndicator(active:p.ready,label:p.ready?'الصلاحيات جاهزة':'الصلاحيات ناقصة'),StatusIndicator(active:c.ready,label:c.ready?'المعايرة جاهزة':'غير معاير'),StatusIndicator(active:t.latest!=null,label:t.latest!=null?'التتبع متصل':'التتبع متوقف')]),
   ]))),
   const SizedBox(height:18),_ActionCard(icon:Icons.visibility_rounded,title:'بدء تتبع النظر',subtitle:p.ready?'عرض بيانات النظر لحظياً.':'فعّل المتطلبات أولاً.',enabled:p.ready,onTap:()=>context.push('/tracking'),primary:true),
   const SizedBox(height:10),Row(children:[Expanded(child:_ActionCard(icon:Icons.tune_rounded,title:'المعايرة',subtitle:c.ready?'مضبوطة':'مطلوبة',onTap:()=>context.push('/calibration'))),const SizedBox(width:10),Expanded(child:_ActionCard(icon:Icons.shield_outlined,title:'الصلاحيات',subtitle:p.ready?'جاهزة':'مراجعة',onTap:()=>context.push('/permissions')))]),
   const SizedBox(height:10),_ActionCard(icon:Icons.info_outline_rounded,title:'خصوصية الجهاز',subtitle:'المعالجة محلية ولا يتم رفع إطارات الكاميرا.',onTap:()=>context.push('/about')),
  ]))));
 }
}
class _ActionCard extends StatelessWidget{
 const _ActionCard({required this.icon,required this.title,required this.subtitle,required this.onTap,this.enabled=true,this.primary=false});
 final IconData icon; final String title,subtitle; final VoidCallback onTap; final bool enabled,primary;
 @override Widget build(BuildContext context){final s=Theme.of(context).colorScheme;final bg=primary?s.primary:s.surfaceContainerHighest;final fg=primary?s.onPrimary:s.onSurface;return Card(color:enabled?bg:s.surfaceContainerHighest.withOpacity(.55),child:InkWell(onTap:enabled?onTap:null,borderRadius:BorderRadius.circular(12),child:Padding(padding:const EdgeInsets.all(16),child:Row(children:[Icon(icon,color:enabled?fg:s.outline),const SizedBox(width:14),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:TextStyle(fontWeight:FontWeight.w700,color:enabled?fg:s.outline)),const SizedBox(height:3),Text(subtitle,style:TextStyle(fontSize:12,color:enabled?fg.withOpacity(.78):s.outline))])),Icon(Icons.arrow_forward_ios_rounded,size:16,color:enabled?fg:s.outline)]))));}
}
