import 'package:eye_control/presentation/widgets/dwell_progress_ring.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders a progress indicator with semantics', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: DwellProgressRing(progress: 0.5)),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.bySemanticsLabel('Dwell progress'), findsOneWidget);
  });

  testWidgets('clamps progress to valid range', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: DwellProgressRing(progress: 2.0)),
    );
    final indicator =
        tester.widget<CircularProgressIndicator>(
          find.byType(CircularProgressIndicator),
        );
    expect(indicator.value, 1.0);
  });
}
