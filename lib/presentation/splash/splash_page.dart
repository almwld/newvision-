import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});
  @override State<SplashPage> createState() => _SplashPageState();
}
class _SplashPageState extends State<SplashPage> {
  Timer? _timer;
  @override void initState() { super.initState(); _timer=Timer(const Duration(milliseconds:1400),_route); }
  Future<void> _route() async {
    final p=await SharedPreferences.getInstance();
    if(mounted) context.go((p.getBool('onboarding.done')??false)?'/':'/onboarding');
  }
  @override void dispose(){_timer?.cancel();super.dispose();}
  @override Widget build(BuildContext context){
    final s=Theme.of(context).colorScheme;
    return Scaffold(body:SafeArea(child:Center(child:Column(mainAxisSize:MainAxisSize.min,children:[
      Container(width:104,height:104,decoration:BoxDecoration(color:s.primaryContainer,borderRadius:BorderRadius.circular(30),border:Border.all(color:s.outlineVariant)),child:Icon(Icons.visibility_rounded,size:56,color:s.onPrimaryContainer)),
      const SizedBox(height:24),
      Text('NewVision',style:Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight:FontWeight.w900)),
      const SizedBox(height:7),
      Text('On-device eye control',style:Theme.of(context).textTheme.bodyMedium),
      const SizedBox(height:34),
      SizedBox(width:32,height:32,child:CircularProgressIndicator(strokeWidth:3,color:s.primary)),
    ]))));
  }
}