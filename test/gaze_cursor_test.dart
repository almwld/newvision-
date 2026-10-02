import 'package:eye_control/presentation/widgets/gaze_cursor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders cursor at the requested position', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Stack(children: [GazeCursor(x: 100, y: 120)]),
      ),
    );
    expect(find.byType(GazeCursor), findsOneWidget);
    expect(find.byType(AnimatedOpacity), findsOneWidget);
  });

  testWidgets('blinking cursor uses reduced opacity', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Stack(children: [GazeCursor(x: 20, y: 20, blinking: true)]),
      ),
    );
    final opacity = tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity));
    expect(opacity.opacity, closeTo(0.35, 0.001));
  });
}
