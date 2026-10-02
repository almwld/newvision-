import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eye_control/presentation/widgets/empty_state.dart';
import 'package:eye_control/presentation/widgets/gaze_cursor.dart';
import 'package:eye_control/presentation/widgets/permission_tile.dart';
import 'package:eye_control/presentation/widgets/setting_slider.dart';
import 'package:eye_control/presentation/widgets/status_card.dart';
import 'package:eye_control/presentation/widgets/status_indicator.dart';

void main() {
  testWidgets('status card exposes ready state', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: StatusCard(ready: true, title: 'Ready', subtitle: 'Tracking'),
    ));
    expect(find.text('Ready'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
  });

  testWidgets('permission tile exposes action when not granted', (tester) async {
    var pressed = false;
    await tester.pumpWidget(MaterialApp(
      home: PermissionTile(
        icon: Icons.camera_alt,
        title: 'Camera',
        subtitle: 'Required',
        granted: false,
        onPressed: () => pressed = true,
      ),
    ));
    await tester.tap(find.text('سماح'));
    expect(pressed, isTrue);
  });

  testWidgets('empty state renders copy', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: EmptyState(
        icon: Icons.visibility,
        title: 'No gaze',
        subtitle: 'Start tracking',
      ),
    ));
    expect(find.text('No gaze'), findsOneWidget);
    expect(find.text('Start tracking'), findsOneWidget);
  });

  testWidgets('status indicator renders active label', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: StatusIndicator(active: true),
    ));
    expect(find.text('نشط'), findsOneWidget);
  });

  testWidgets('setting slider emits changed value', (tester) async {
    double? value;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SettingSlider(
          value: 900,
          label: 'Dwell',
          onChanged: (v) => value = v,
        ),
      ),
    ));
    await tester.tapAt(tester.getCenter(find.byType(Slider)));
    expect(value, isNotNull);
  });

  testWidgets('gaze cursor builds in blinking state', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Stack(
        children: [GazeCursor(x: 40, y: 40, blinking: true)],
      ),
    ));
    expect(find.byType(GazeCursor), findsOneWidget);
  });
}
