import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:eye_control/presentation/permissions/permissions_page.dart';
import 'package:eye_control/presentation/providers/permission_provider.dart';
import 'package:eye_control/platform/eye_control_platform.dart';
class FlowFakePlatform extends EyeControlPlatform {
  @override Future<bool> isOverlayGranted() async=>true;
  @override Future<bool> isAccessibilityEnabled() async=>true;
}
void main(){TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('tracking is gated until all permissions are ready',(tester)async{
    final p=PermissionProvider(platform:FlowFakePlatform());
    await tester.pumpWidget(MaterialApp(home:ChangeNotifierProvider.value(value:p,child:const PermissionsPage())));
    await tester.pump();
    expect(find.text('متابعة إلى التتبع'),findsOneWidget);
    expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,isNull);
    p.dispose();
  });
}
