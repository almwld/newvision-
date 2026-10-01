import 'package:flutter/material.dart';

class GazeCursor extends StatelessWidget {
  const GazeCursor({
    super.key,
    required this.x,
    required this.y,
    this.blinking = false,
  });

  final double x;
  final double y;
  final bool blinking;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;

    return Positioned(
      left: x - 18,
      top: y - 18,
      child: IgnorePointer(
        child: AnimatedOpacity(
          opacity: blinking ? 0.28 : 1,
          duration: const Duration(milliseconds: 100),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.10),
              border: Border.all(color: color, width: 3),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.22),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
