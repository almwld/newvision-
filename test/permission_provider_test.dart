import 'package:flutter_test/flutter_test.dart';
import 'package:eye_control/platform/eye_control_platform.dart';
import 'package:eye_control/presentation/providers/permission_provider.dart';

class FakeEyeControlPlatform extends EyeControlPlatform {
  FakeEyeControlPlatform({this.overlay=true,this.accessibility=true});
  bool overlay; bool accessibility;
  @override Future<bool> isOverlayGranted() async=>overlay;
  @override Future<bool> isAccessibilityEnabled() async=>accessibility;
  @override Future<void> requestOverlayPermission() async{overlay=true;}
  @override Future<void> requestAccessibilitySettings() async{accessibility=true;}
}

void main(){TestWidgetsFlutterBinding.ensureInitialized();
  test('readiness requires all three permissions',()async{
    final p=PermissionProvider(platform:FakeEyeControlPlatform());
    p.camera=true; p.overlay=true; p.accessibility=false;
    expect(p.ready,isFalse); expect(p.grantedCount,2);
    p.accessibility=true; expect(p.ready,isTrue); p.dispose();
  });
  test('settings requests update overlay and accessibility',()async{
    final f=FakeEyeControlPlatform(overlay:false,accessibility:false);
    final p=PermissionProvider(platform:f);
    p.camera=true;
    await p.requestOverlay(); await p.requestAccessibility();
    expect(p.overlay,isTrue); expect(p.accessibility,isTrue); expect(p.ready,isTrue); p.dispose();
  });
}
