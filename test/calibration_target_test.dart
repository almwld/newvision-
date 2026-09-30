import 'package:eye_control/presentation/widgets/calibration_target.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders active calibration target', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: CalibrationTarget(size: 40, active: true)),
    );
    expect(find.byType(CalibrationTarget), findsOneWidget);
    final target = tester.widget<CalibrationTarget>(
      find.byType(CalibrationTarget),
    );
    expect(target.size, 40);
  });

  testWidgets('renders inactive calibration target', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: CalibrationTarget(active: false)),
    );
    expect(find.byType(CalibrationTarget), findsOneWidget);
  });
}
