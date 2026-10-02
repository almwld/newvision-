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

  testWidgets('tracking is gated until all permissions are ready',
      (tester) async {
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

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(provider.ready, isFalse);
    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pump();
    final trackingAction = find.byKey(const ValueKey('tracking-action'));
    expect(trackingAction, findsOneWidget);
    expect(
      tester.widget<FilledButton>(trackingAction).onPressed,
      isNull,
    );

    provider.dispose();
  });
}
