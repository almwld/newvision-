import 'dart:async';
import 'package:flutter/material.dart';
import '../../platform/eye_control_platform.dart';

class CalibrationPage extends StatefulWidget {
  const CalibrationPage({super.key, this.platform});
  final EyeControlPlatform? platform;
  @override State<CalibrationPage> createState() => _CalibrationPageState();
}
class _CalibrationPageState extends State<CalibrationPage> {
  static const targets = <Offset>[
    Offset(.1,.1),Offset(.5,.1),Offset(.9,.1),Offset(.1,.5),Offset(.5,.5),
    Offset(.9,.5),Offset(.1,.9),Offset(.5,.9),Offset(.9,.9),
  ];
  late final EyeControlPlatform _platform = widget.platform ?? EyeControlPlatform();
  int _index=-1; bool _running=false,_saving=false,_reading=false; String? _error;
  Timer? _timer; StreamSubscription<Map<String,dynamic>>? _gazeSub; Offset? _liveGaze;
  final _samples=<Map<String,double>>[]; final _current=<Map<String,double>>[];

  Future<void> _start() async {
    if (_running || _saving) return;
    setState(() { _error=null; _samples.clear(); _index=0; _running=true; });
    try {
      await _platform.startCamera();
      _gazeSub ??= _platform.gazeStream.listen((map) {
        if (!mounted) return;
        final x=map['xPx'], y=map['yPx'];
        if (x is num && y is num) setState(() => _liveGaze=Offset(x.toDouble(),y.toDouble()));
      },onError: (_) { if(mounted) setState(()=>_error='تعذر استقبال بيانات النظر أثناء المعايرة.'); });
      await _capture();
    } catch(error) {
      if(mounted) setState(() { _running=false; _error='تعذر بدء الكاميرا: $error'; });
    }
  }

  Future<void> _capture() async {
    if(!_running || _index<0 || _index>=targets.length) return;
    _current.clear(); var ticks=0; _timer?.cancel();
    _timer=Timer.periodic(const Duration(milliseconds:50),(timer) async {
      if (_reading || !_running) {\n        return;\n      }
      _reading=true; ticks++;
      try {
        final gaze=await _platform.latestGaze(); final confidence=gaze?['confidence'];
        final valid=confidence is num && confidence.toDouble()>=.35 &&
          gaze?['blinking']!=true && gaze?['leftIrisX'] is num && gaze?['leftIrisY'] is num &&
          gaze?['rightIrisX'] is num && gaze?['rightIrisY'] is num;
        if(valid) _current.add({
          'leftIrisX':(gaze!['leftIrisX'] as num).toDouble(),
          'leftIrisY':(gaze['leftIrisY'] as num).toDouble(),
          'rightIrisX':(gaze['rightIrisX'] as num).toDouble(),
          'rightIrisY':(gaze['rightIrisY'] as num).toDouble(),
        });
      } finally { _reading=false; }
      if(ticks<40) return; timer.cancel();
      if(!mounted || !_running) return;
      if(_current.length<8) {
        setState(() { _error='لم يتم التقاط نظر ثابت. أعد المحاولة مع تثبيت الرأس.'; _running=false; });
        return;
      }
      double average(String key)=>_current.map((s)=>s[key]!).reduce((a,b)=>a+b)/_current.length;
      final target=targets[_index];
      _samples.add({
        'leftIrisX':average('leftIrisX'),'leftIrisY':average('leftIrisY'),
        'rightIrisX':average('rightIrisX'),'rightIrisY':average('rightIrisY'),
        'targetX':target.dx,'targetY':target.dy,
      });
      if(_samples.length==targets.length) {
        setState(()=>_saving=true);
        try {
          await _platform.fitCalibration(_samples);
          if(!mounted) return;
          setState(() { _saving=false; _running=false; _index=-1; });
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('تم حفظ المعايرة بنجاح.')));
        } catch(error) {
          if(mounted) setState(() { _saving=false; _running=false; _error='فشل حفظ نموذج المعايرة: $error'; });
        }
        return;
      }
      if(mounted) { setState(()=>_index++); await _capture(); }
    });
  }

  Future<void> _cancel() async {
    _timer?.cancel(); setState(() { _running=false; _index=-1; }); await _platform.stopCamera();
  }
  @override void dispose(){ _timer?.cancel(); _gazeSub?.cancel(); _platform.stopCamera(); super.dispose(); }

  @override Widget build(BuildContext context) {
    final active=_index>=0 && _index<targets.length; final scheme=Theme.of(context).colorScheme;
    return Scaffold(
      appBar:AppBar(title:const Text('معايرة التحكم بالعين'),actions:[
        if(_running) IconButton(tooltip:'إيقاف',onPressed:_cancel,icon:const Icon(Icons.close_rounded)),
      ]),
      body:Stack(children:[
        Positioned.fill(child:Padding(
          padding:const EdgeInsets.fromLTRB(20,8,20,28),
          child:Column(children:[
            Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(children:[
              Row(children:[
                Icon(Icons.center_focus_strong_rounded,color:scheme.primary),const SizedBox(width:10),
                Expanded(child:Text(active?'ثبّت نظرك على النقطة':'معايرة شخصية للجهاز',
                  style:Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight:FontWeight.w800))),
                if(active) Text((_index+1).toString()+' / '+targets.length.toString(),
                  style:Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight:FontWeight.w800)),
              ]),
              const SizedBox(height:12),
              LinearProgressIndicator(value:active?(_index+1)/targets.length:0,minHeight:7,borderRadius:BorderRadius.circular(7)),
              const SizedBox(height:10),
              Text('تُعالج بيانات العين محلياً، ويُستخدم متوسط عينات مستقرة لكل نقطة.',
                style:Theme.of(context).textTheme.bodySmall,textAlign:TextAlign.center),
            ]))),
            const Spacer(),
            if(!_running) FilledButton.icon(onPressed:_saving?null:_start,
              icon:const Icon(Icons.play_arrow_rounded),label:Text(_saving?'جارٍ الحفظ…':'بدء المعايرة')),
            if(_error!=null)...[const SizedBox(height:12),Text(_error!,textAlign:TextAlign.center,style:TextStyle(color:scheme.error))],
          ]),
        )),
        if(active) Align(
          alignment:Alignment(targets[_index].dx*2-1,targets[_index].dy*2-1),
          child:const _CalibrationDot(),
        ),
        if(_liveGaze!=null && active) Positioned(left:_liveGaze!.dx-11,top:_liveGaze!.dy-11,
          child:IgnorePointer(child:Container(width:22,height:22,decoration:BoxDecoration(
            shape:BoxShape.circle,color:scheme.tertiary,border:Border.all(color:scheme.onTertiary,width:2))))),
        if(_saving) const ColoredBox(color:Color(0x66000000),child:Center(child:CircularProgressIndicator())),
      ]),
    );
  }
}
class _CalibrationDot extends StatelessWidget {
  const _CalibrationDot();
  @override Widget build(BuildContext context) {
    final color=Theme.of(context).colorScheme.primary;
    return Container(width:46,height:46,decoration:BoxDecoration(shape:BoxShape.circle,color:color,
      boxShadow:[BoxShadow(blurRadius:20,spreadRadius:5,color:color.withOpacity(.32))]),
      child:const Center(child:CircleAvatar(radius:6,backgroundColor:Colors.white)));
  }
}
