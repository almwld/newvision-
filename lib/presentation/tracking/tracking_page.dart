import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/permission_provider.dart';
import '../providers/tracking_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/floating_control_button.dart';
import '../widgets/gaze_cursor.dart';
import '../widgets/status_indicator.dart';

class TrackingPage extends StatefulWidget{const TrackingPage({super.key});@override State<TrackingPage> createState()=>_TrackingPageState();}
class _TrackingPageState extends State<TrackingPage>{
 @override void initState(){super.initState();WidgetsBinding.instance.addPostFrameCallback((_)=>context.read<TrackingProvider>().start());}
 @override void dispose(){context.read<TrackingProvider>().stop();super.dispose();}
 @override Widget build(BuildContext context){
  final tracking=context.watch<TrackingProvider>(),permissions=context.watch<PermissionProvider>();
  if(!permissions.ready)return const Scaffold(body:EmptyState(icon:Icons.lock_outline_rounded,title:'أكمل الصلاحيات',subtitle:'فعّل الكاميرا والتراكب وإمكانية الوصول قبل بدء التحكم.'));
  final gaze=tracking.latest,confidence=gaze?.confidence.clamp(0.0,1.0)??0.0;
  return Scaffold(appBar:AppBar(title:const Text('تتبع النظر'),actions:[Padding(padding:const EdgeInsetsDirectional.only(end:16),child:Center(child:StatusIndicator(active:tracking.running&&gaze!=null&&!gaze.isBlinking,label:tracking.starting?'جاري البدء':gaze?.isBlinking==true?'رمشة':tracking.running?'نشط':'متوقف')))]),
   floatingActionButton:FloatingControlButton(active:tracking.running,onPressed:tracking.running?tracking.stop:tracking.start),
   body:LayoutBuilder(builder:(context,constraints){
    final x=(gaze?.xPx??constraints.maxWidth/2).clamp(0.0,constraints.maxWidth),y=(gaze?.yPx??165.0).clamp(0.0,330.0);
    return ListView(padding:const EdgeInsets.fromLTRB(20,8,20,110),children:[
     Card(child:SizedBox(height:330,child:ClipRRect(borderRadius:BorderRadius.circular(22),child:Stack(children:[
      Positioned.fill(child:CustomPaint(painter:_TrackingGridPainter())),
      Center(child:Column(mainAxisSize:MainAxisSize.min,children:[
       Icon(Icons.visibility_rounded,size:64,color:Theme.of(context).colorScheme.primary.withOpacity(.22)),const SizedBox(height:8),
       Text(gaze==null?(tracking.starting?'جارٍ تشغيل الكاميرا':'في انتظار بيانات النظر'):gaze.isBlinking?'تم اكتشاف رمشة':'النظر متصل',style:Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight:FontWeight.w800)),
       const SizedBox(height:5),Text(tracking.error??'المعالجة تتم محلياً على الجهاز',style:Theme.of(context).textTheme.bodySmall),
      ])),if(gaze!=null)GazeCursor(x:x,y:y,blinking:gaze.isBlinking)]))),
     if(tracking.error!=null)...[const SizedBox(height:12),Card(color:Theme.of(context).colorScheme.errorContainer,child:Padding(padding:const EdgeInsets.all(14),child:Text(tracking.error!,style:TextStyle(color:Theme.of(context).colorScheme.onErrorContainer))))],
     const SizedBox(height:14),Row(children:[Expanded(child:_MetricCard(label:'X',value:gaze?.xPx.toStringAsFixed(0)??'—',unit:'px')),const SizedBox(width:10),Expanded(child:_MetricCard(label:'Y',value:gaze?.yPx.toStringAsFixed(0)??'—',unit:'px'))]),
     const SizedBox(height:10),_MetricCard(label:'الثقة',value:'${(confidence*100).round()}',unit:'%'),const SizedBox(height:18),
     Text('جودة الإشارة',style:Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight:FontWeight.w800)),const SizedBox(height:8),LinearProgressIndicator(value:confidence,minHeight:8,borderRadius:BorderRadius.circular(8))
    ]);}));
 }
}
class _MetricCard extends StatelessWidget{const _MetricCard({required this.label,required this.value,required this.unit});final String label,value,unit;@override Widget build(BuildContext context)=>Card(child:Padding(padding:const EdgeInsets.all(16),child:Row(children:[Text(label,style:Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight:FontWeight.w800)),const Spacer(),Text(value,style:Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight:FontWeight.w900)),const SizedBox(width:5),Text(unit,style:Theme.of(context).textTheme.bodySmall)])));}
class _TrackingGridPainter extends CustomPainter{@override void paint(Canvas canvas,Size size){final paint=Paint()..color=Colors.black.withOpacity(.06)..strokeWidth=1;for(var i=1;i<4;i++){final x=size.width*i/4,y=size.height*i/4;canvas.drawLine(Offset(x,0),Offset(x,size.height),paint);canvas.drawLine(Offset(0,y),Offset(size.width,y),paint);}}@override bool shouldRepaint(covariant CustomPainter oldDelegate)=>false;}
