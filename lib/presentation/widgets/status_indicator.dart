import 'package:flutter/material.dart';

class StatusIndicator extends StatelessWidget {
  const StatusIndicator({super.key, required this.active, this.label});

  final bool active;
  final String? label;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.circle,
            size: 10,
            color: active
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).disabledColor,
          ),
          const SizedBox(width: 8),
          Text(label ?? (active ? 'نشط' : 'غير نشط')),
        ],
      );
}
