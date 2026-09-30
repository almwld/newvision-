import 'package:eye_control/presentation/widgets/status_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('uses supplied active label', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: StatusIndicator(active: true, label: 'جاهز'),
      ),
    );
    expect(find.text('جاهز'), findsOneWidget);
  });

  testWidgets('uses default inactive label', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: StatusIndicator(active: false)),
    );
    expect(find.text('غير نشط'), findsOneWidget);
  });
}
