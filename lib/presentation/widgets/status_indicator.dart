import 'package:flutter/material.dart';

class StatusIndicator extends StatelessWidget {
  const StatusIndicator({super.key,required this.active,this.label});
  final bool active; final String? label;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(mainAxisSize: MainAxisSize.min,children: [
      Container(width: 9,height: 9,decoration: BoxDecoration(shape: BoxShape.circle,color: active ? scheme.primary : scheme.outlineVariant)),
      const SizedBox(width: 8),Text(label ?? (active ? 'نشط' : 'غير نشط')),
    ]);
  }
}
