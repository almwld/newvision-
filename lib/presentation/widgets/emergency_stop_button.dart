import 'package:flutter/material.dart';

class EmergencyStopButton extends StatelessWidget {
  const EmergencyStopButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => FilledButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.stop_circle_outlined),
        label: const Text('إيقاف فوري'),
      );
}
