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
  test('readiness requires all three permissions',()async{final p=PermissionProvider(platform:FakeEyeControlPlatform());await p.refresh();expect(p.ready,isFalse);expect(p.grantedCount,lessThan(3));p.dispose();});
  test('settings permissions become ready after requests',()async{final f=FakeEyeControlPlatform(overlay:false,accessibility:false);final p=PermissionProvider(platform:f);await p.refresh();await p.requestOverlay();await p.requestAccessibility();expect(p.overlay,isTrue);expect(p.accessibility,isTrue);p.dispose();});
}
