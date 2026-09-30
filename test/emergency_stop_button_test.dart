import 'package:eye_control/presentation/widgets/emergency_stop_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('fires emergency stop callback', (tester) async {
    var fired = false;
    await tester.pumpWidget(
      MaterialApp(
        home: EmergencyStopButton(onPressed: () => fired = true),
      ),
    );
    expect(find.text('إيقاف فوري'), findsOneWidget);
    await tester.tap(find.byType(EmergencyStopButton));
    expect(fired, isTrue);
  });
}
