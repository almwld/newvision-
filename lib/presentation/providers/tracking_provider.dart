import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../data/datasources/native_bridge.dart';
import '../../data/models/gaze_sample_model.dart';

class TrackingProvider extends ChangeNotifier {
  TrackingProvider({NativeBridge? bridge}):_bridge=bridge??NativeBridge();
  final NativeBridge _bridge; StreamSubscription<GazeSampleModel>? _subscription;
  GazeSampleModel? _latest; bool _running=false,_starting=false; String? _error;
  GazeSampleModel? get latest=>_latest; bool get running=>_running; bool get starting=>_starting; String? get error=>_error;
  Future<void> start()async{
    if(_running||_starting)return; _starting=true;_error=null;notifyListeners();
    await _subscription?.cancel();
    _subscription=_bridge.gazeStream.listen((sample){_latest=sample;_running=true;_error=null;notifyListeners();},onError:(Object error,StackTrace stack){
      _running=false;_error='تعذر استقبال بيانات النظر من النظام.';debugPrint('NewVision gaze stream error: $error\n$stack');notifyListeners();
    });
    try{await _bridge.startTracking();_running=true;}catch(error,stack){
      _running=false;_error='تعذر بدء الكاميرا والتتبع.';debugPrint('NewVision startTracking failed: $error\n$stack');await _subscription?.cancel();_subscription=null;
    }finally{_starting=false;notifyListeners();}
  }
  Future<void> stop()async{
    _running=false;_starting=false;await _subscription?.cancel();_subscription=null;
    try{await _bridge.stopTracking();}catch(error,stack){debugPrint('NewVision stopTracking failed: $error\n$stack');}
    _latest=null;notifyListeners();
  }
  @override void dispose(){_subscription?.cancel();_bridge.stopTracking();super.dispose();}
}
