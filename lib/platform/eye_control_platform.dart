import 'dart:async';
import 'package:flutter/services.dart';
class EyeControlPlatform {
  EyeControlPlatform({MethodChannel? channel,EventChannel? gazeChannel}):_channel=channel??const MethodChannel('com.eyecontrol/platform'),_gazeChannel=gazeChannel??const EventChannel('com.eyecontrol/gaze_screen_point');
  final MethodChannel _channel; final EventChannel _gazeChannel;
  Stream<Map<String,dynamic>> get gazeStream=>_gazeChannel.receiveBroadcastStream().where((v)=>v is Map).map((v)=>Map<String,dynamic>.from(v as Map));
  Future<void> startCamera()=>_channel.invokeMethod<void>('camera.start');
  Future<void> stopCamera()=>_channel.invokeMethod<void>('camera.stop');
  Future<void> requestOverlayPermission()=>_channel.invokeMethod<void>('overlay.request');
  Future<bool> isOverlayGranted()async=>await _channel.invokeMethod<bool>('overlay.isGranted')??false;
  Future<void> requestAccessibilitySettings()=>_channel.invokeMethod<void>('accessibility.request');
  Future<bool> isAccessibilityEnabled()async=>await _channel.invokeMethod<bool>('accessibility.isEnabled')??false;
  Future<Map<String,dynamic>?> latestGaze()async{final v=await _channel.invokeMethod<dynamic>('gaze.latest');return v is Map?Map<String,dynamic>.from(v):null;}
  Future<bool> isCalibrationReady()async=>await _channel.invokeMethod<bool>('calibration.isReady')??false;
  Future<void> fitCalibration(List<Map<String,double>> samples)=>_channel.invokeMethod<void>('calibration.fit',<String,Object>{'samples':samples});
  Future<Map<String,dynamic>> predictCalibration(double x,double y)async{final v=await _channel.invokeMethod<dynamic>('calibration.predict',<String,Object>{'x':x,'y':y});return v is Map?Map<String,dynamic>.from(v):<String,dynamic>{};}
  Future<void> clearCalibration()=>_channel.invokeMethod<void>('calibration.clear');
  Future<void> executeTap(double x,double y)=>_channel.invokeMethod<void>('gesture.tap',<String,Object>{'x':x,'y':y});
  Future<({int width,int height})> screenSize() async {final v=await _channel.invokeMethod<dynamic>('screen.size');if(v is Map)return(width:(v['width'] as num?)?.toInt()??0,height:(v['height'] as num?)?.toInt()??0);return(width:0,height:0);}
  Future<void> setDwellConfig({required int durationMs,required double radiusPx})=>_channel.invokeMethod<void>('dwell.configure',<String,Object>{'durationMs':durationMs,'radiusPx':radiusPx});
}
