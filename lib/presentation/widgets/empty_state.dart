import 'package:flutter/material.dart';
class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.title, required this.subtitle});
  final IconData icon; final String title; final String subtitle;
  @override Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 88, height: 88, decoration: BoxDecoration(color: scheme.primaryContainer, shape: BoxShape.circle),
        child: Icon(icon, size: 42, color: scheme.onPrimaryContainer)),
      const SizedBox(height: 20),
      Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800), textAlign: TextAlign.center),
      const SizedBox(height: 8),
      ConstrainedBox(constraints: const BoxConstraints(maxWidth: 360), child: Text(subtitle, textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.45))),
    ])));
  }
}
