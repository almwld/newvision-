import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:eye_control/presentation/permissions/permissions_page.dart';
import 'package:eye_control/presentation/providers/permission_provider.dart';
import 'package:eye_control/platform/eye_control_platform.dart';

class FlowFakePlatform extends EyeControlPlatform {
  @override Future<bool> isOverlayGranted() async=>false;
  @override Future<bool> isAccessibilityEnabled() async=>false;
}

void main(){TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('tracking is gated until all permissions are ready',(tester)async{
    final p=PermissionProvider(platform:FlowFakePlatform());
    p.camera=false;p.overlay=false;p.accessibility=false;
    await tester.pumpWidget(MaterialApp(home:ChangeNotifierProvider.value(value:p,child:const PermissionsPage())));
    await tester.pump();
    final button=find.ancestor(of:find.text('متابعة إلى التتبع'),matching:find.byType(FilledButton));
    expect(button,findsOneWidget);
    expect(tester.widget<FilledButton>(button).onPressed,isNull);
    p.dispose();
  });
}
