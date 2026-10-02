import 'package:flutter/material.dart';

class StatusCard extends StatelessWidget {
  const StatusCard({super.key, required this.ready, required this.title, required this.subtitle});
  final bool ready; final String title; final String subtitle;
  @override
  Widget build(BuildContext context) { final theme = Theme.of(context); final scheme = theme.colorScheme; final background = ready ? scheme.primaryContainer : scheme.surfaceContainerLow; final foreground = ready ? scheme.onPrimaryContainer : scheme.onSurface; return Card(color: background, child: Padding(padding: const EdgeInsets.all(16), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Container(width: 44, height: 44, decoration: BoxDecoration(color: ready ? scheme.primary : scheme.surface, borderRadius: BorderRadius.circular(14)), child: Icon(ready ? Icons.check_circle_rounded : Icons.info_outline_rounded, color: ready ? scheme.onPrimary : scheme.primary)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800, color: foreground)), const SizedBox(height: 4), Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(height: 1.4, color: foreground.withOpacity(0.82)))]))]))); }
}
