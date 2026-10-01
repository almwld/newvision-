import 'package:flutter/material.dart';

class GazeCursor extends StatelessWidget {
  const GazeCursor({super.key, required this.x, required this.y, this.blinking = false});
  final double x;
  final double y;
  final bool blinking;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Positioned(
      left: x - 18, top: y - 18,
      child: IgnorePointer(child: AnimatedOpacity(
        opacity: blinking ? .3 : 1,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(width: 3, color: primary),
            boxShadow: [BoxShadow(color: primary.withOpacity(.25), blurRadius: 10)],
          ),
        ),
      )),
    );
  }
}