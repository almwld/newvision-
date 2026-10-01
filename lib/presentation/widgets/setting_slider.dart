import 'package:flutter/material.dart';

class SettingSlider extends StatelessWidget {
  const SettingSlider({super.key, required this.value, required this.label, required this.onChanged});
  final double value;
  final String label;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(500, 2000);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(child: Text(label, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700))),
        Text('$clamped ms', style: Theme.of(context).textTheme.labelLarge),
      ]),
      Slider(value: clamped, min: 500, max: 2000, divisions: 15, label: '$clamped ms', onChanged: onChanged),
    ]);
  }
}