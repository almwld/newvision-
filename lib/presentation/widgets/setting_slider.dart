import 'package:flutter/material.dart';

class SettingSlider extends StatelessWidget {
  const SettingSlider({super.key, required this.value, required this.label, required this.onChanged});
  final double value;
  final String label;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final milliseconds = value.round();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(child: Text(label, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700))),
        Text('$milliseconds ms', style: theme.textTheme.labelLarge?.copyWith(color: scheme.primary, fontWeight: FontWeight.w800)),
      ]),
      Slider(value: value.clamp(500, 2000), min: 500, max: 2000, divisions: 15, label: '$milliseconds ms', onChanged: onChanged),
    ]);
  }
}
