import 'package:flutter/material.dart';

class DwellProgressRing extends StatelessWidget {
  const DwellProgressRing({super.key, required this.progress, this.size = 56});

  final double progress;
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          value: progress.clamp(0.0, 1.0),
          strokeWidth: 5,
          semanticsLabel: 'Dwell progress',
        ),
      );
}
