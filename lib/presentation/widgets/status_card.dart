import 'package:flutter/material.dart';

class StatusCard extends StatelessWidget {
  const StatusCard({
    super.key,
    required this.ready,
    required this.title,
    required this.subtitle,
  });

  final bool ready;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final background = ready ? scheme.primaryContainer : scheme.surfaceContainerHighest;
    final foreground = ready ? scheme.onPrimaryContainer : scheme.onSurfaceVariant;

    return Semantics(
      container: true,
      label: '$title. $subtitle',
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: ready ? scheme.primary : scheme.surface,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                ready ? Icons.check_rounded : Icons.info_outline_rounded,
                color: ready ? scheme.onPrimary : foreground,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800, color: foreground)),
                  const SizedBox(height: 5),
                  Text(subtitle, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: foreground)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
