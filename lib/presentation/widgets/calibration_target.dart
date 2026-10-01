import 'package:flutter/material.dart';

class CalibrationTarget extends StatelessWidget {
  const CalibrationTarget({super.key, this.size = 32, this.active = true});

  final double size;
  final bool active;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: active
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).disabledColor,
            width: 3,
          ),
        ),
        child: SizedBox(width: size, height: size),
      );
}
