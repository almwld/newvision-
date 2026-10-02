import 'package:flutter/services.dart';
import '../models/gaze_sample_model.dart';
class NativeBridge {
  NativeBridge({MethodChannel? methodChannel,EventChannel? gazeChannel}):_method=methodChannel??const MethodChannel('com.eyecontrol/platform'),_events=gazeChannel??const EventChannel('com.eyecontrol/gaze_screen_point');
  final MethodChannel _method; final EventChannel _events;
  Stream<GazeSampleModel> get gazeStream=>_events.receiveBroadcastStream().where((e)=>e is Map).map((e)=>GazeSampleModel.fromMap(Map<String,dynamic>.from(e as Map)));
  Stream<Map<String,dynamic>> get screenPoints=>_events.receiveBroadcastStream().where((e)=>e is Map).map((e)=>Map<String,dynamic>.from(e as Map));
  Future<void> startTracking()=>_method.invokeMethod<void>('camera.start');
  Future<void> stopTracking()=>_method.invokeMethod<void>('camera.stop');
  Future<void> startCamera()=>startTracking();
  Future<void> stopCamera()=>stopTracking();
  Future<Map<String,dynamic>?> latestGaze()async{final v=await _method.invokeMethod<dynamic>('gaze.latest');return v is Map?Map<String,dynamic>.from(v):null;}
}
