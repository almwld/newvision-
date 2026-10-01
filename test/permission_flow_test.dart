import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:eye_control/presentation/permissions/permissions_page.dart';
import 'package:eye_control/presentation/providers/permission_provider.dart';
import 'package:eye_control/platform/eye_control_platform.dart';

class FlowFakePlatform extends EyeControlPlatform {
  @override
  Future<bool> isOverlayGranted() async => false;

  @override
  Future<bool> isAccessibilityEnabled() async => false;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('tracking is gated until all permissions are ready', (tester) async {
    final provider = PermissionProvider(platform: FlowFakePlatform())
      ..camera = false
      ..overlay = false
      ..accessibility = false;

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider.value(
          value: provider,
          child: const PermissionsPage(),
        ),
      ),
    );

    // PermissionsPage refreshes after the first frame and shows a progress
    // indicator while checking system state. A settling animation is therefore
    // intentionally avoided here; one frame is enough to verify the gate.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    final button = find.widgetWithText(FilledButton, 'متابعة إلى التتبع');
    expect(button, findsOneWidget);
    expect(tester.widget<FilledButton>(button).onPressed, isNull);

    provider.dispose();
  });
}
