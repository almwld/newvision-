import 'package:flutter/material.dart';

class StatusIndicator extends StatelessWidget {
  const StatusIndicator({super.key, required this.active, this.label});
  final bool active;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: (active ? scheme.primary : scheme.surfaceContainerHighest).withOpacity(.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.circle, size: 8, color: active ? scheme.primary : scheme.outline),
        const SizedBox(width: 7),
        Text(label ?? (active ? 'نشط' : 'غير نشط')),
      ]),
    );
  }
}