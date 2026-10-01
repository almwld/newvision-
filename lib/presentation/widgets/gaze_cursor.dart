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
    final scheme = Theme.of(context).colorScheme;
    return Positioned(
      left: x - 18,
      top: y - 18,
      child: IgnorePointer(
        child: AnimatedOpacity(
          opacity: blinking ? 0.3 : 1,
          duration: const Duration(milliseconds: 100),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: scheme.primary.withOpacity(0.12),
              border: Border.all(width: 3, color: scheme.primary),
              boxShadow: [
                BoxShadow(
                  color: scheme.primary.withOpacity(0.18),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: scheme.primary,
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
