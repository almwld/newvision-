import 'package:flutter/material.dart';
class StatusIndicator extends StatelessWidget {
  const StatusIndicator({super.key, required this.active, this.label});
  final bool active; final String? label;
  @override Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(color: (active ? scheme.primary : scheme.surfaceContainerHighest).withOpacity(.14), borderRadius: BorderRadius.circular(30)),
      child: Padding(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7), child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.circle, size: 8, color: active ? scheme.primary : scheme.onSurfaceVariant),
        const SizedBox(width: 7),
        Text(label ?? (active ? 'نشط' : 'غير نشط'), style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700)),
      ])));
  }
}
