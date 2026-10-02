import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/calibration_provider.dart';
import '../providers/permission_provider.dart';
import '../widgets/status_card.dart';

class HomePage extends StatelessWidget {
 const HomePage({super.key});
 @override Widget build(BuildContext context){
  final permissions=context.watch<PermissionProvider>(); final calibration=context.watch<CalibrationProvider>(); final s=Theme.of(context).colorScheme; final ready=permissions.ready&&calibration.ready;
  return Scaffold(appBar:AppBar(title:const Text('NewVision'),actions:[IconButton(tooltip:'الإعدادات',onPressed:()=>context.push('/settings'),icon:const Icon(Icons.settings_outlined))]),
   body:SafeArea(child:RefreshIndicator(onRefresh:()async{await permissions.refresh();await calibration.refresh();},child:ListView(physics:const AlwaysScrollableScrollPhysics(),padding:const EdgeInsets.fromLTRB(20,8,20,28),children:[
    Container(padding:const EdgeInsets.all(22),decoration:BoxDecoration(borderRadius:BorderRadius.circular(26),gradient:LinearGradient(colors:[s.primary,s.primaryContainer],begin:Alignment.topRight,end:Alignment.bottomLeft)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
     Icon(Icons.visibility_rounded,size:34,color:s.onPrimary),const SizedBox(height:18),Text(ready?'جاهز للتحكم بالنظر':'أكمل إعداد NewVision',style:Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight:FontWeight.w900,color:s.onPrimary)),const SizedBox(height:8),Text(ready?'المعايرة والصلاحيات جاهزة. يمكنك بدء التتبع.':'نجهّز الكاميرا والصلاحيات والمعايرة لتجربة مستقرة.',style:TextStyle(color:s.onPrimary.withOpacity(.88)))
    ])),const SizedBox(height:18),
    StatusCard(ready:ready,title:ready?'النظام جاهز':'الإعداد غير مكتمل',subtitle:ready?'كل المتطلبات الأساسية متوفرة.':'تحقق من الصلاحيات ثم أكمل المعايرة.'),const SizedBox(height:8),
    _ActionCard(icon:Icons.shield_outlined,title:'الصلاحيات',subtitle:'الكاميرا، العرض فوق التطبيقات وإمكانية الوصول',onTap:()=>context.push('/permissions')),
    _ActionCard(icon:Icons.center_focus_strong_rounded,title:'المعايرة',subtitle:calibration.ready?'المعايرة محفوظة':'اضبط نقاط النظر التسع',onTap:()=>context.push('/calibration')),
    _ActionCard(icon:Icons.visibility_outlined,title:'تتبع النظر',subtitle:'راقب الإحداثيات والثقة وحالة الرمش',onTap:ready?()=>context.push('/tracking'):()=>context.push('/permissions')),
    const SizedBox(height:8),Text('المعالجة تتم محلياً على الجهاز ولا يتم حفظ إطارات الكاميرا.',textAlign:TextAlign.center,style:Theme.of(context).textTheme.bodySmall?.copyWith(color:s.onSurfaceVariant))
   ]))));
 }
}
class _ActionCard extends StatelessWidget{
 const _ActionCard({required this.icon,required this.title,required this.subtitle,required this.onTap});
 final IconData icon; final String title; final String subtitle; final VoidCallback onTap;
 @override Widget build(BuildContext context){final s=Theme.of(context).colorScheme;return Card(child:InkWell(borderRadius:BorderRadius.circular(20),onTap:onTap,child:Padding(padding:const EdgeInsets.all(16),child:Row(children:[
  Container(width:48,height:48,decoration:BoxDecoration(color:s.primaryContainer,borderRadius:BorderRadius.circular(15)),child:Icon(icon,color:s.onPrimaryContainer)),const SizedBox(width:14),
  Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:const TextStyle(fontWeight:FontWeight.w800)),const SizedBox(height:4),Text(subtitle,style:TextStyle(color:s.onSurfaceVariant,fontSize:13))])),
  const Icon(Icons.chevron_right_rounded)
 ])));}}
