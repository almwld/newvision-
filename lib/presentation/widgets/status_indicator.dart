import 'package:flutter/material.dart';

class StatusIndicator extends StatelessWidget {
  const StatusIndicator({super.key, required this.active, this.label});
  final bool active;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = label ?? (active ? 'نشط' : 'غير نشط');
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(9, 6, 10, 6),
      decoration: BoxDecoration(color: active ? scheme.primaryContainer : scheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: active ? scheme.primary : scheme.outline, shape: BoxShape.circle)),
        const SizedBox(width: 7),
        Text(text, style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700)),
      ]),
    );
  }
}
