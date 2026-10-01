import 'package:flutter/material.dart';

class PermissionTile extends StatelessWidget {
  const PermissionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.granted,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool granted;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: granted ? scheme.primaryContainer : scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                granted ? Icons.check_rounded : icon,
                color: granted ? scheme.onPrimaryContainer : scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 3),
                  Text(subtitle, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            const SizedBox(width: 10),
            if (granted)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text('مفعّل', style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w800, color: scheme.onPrimaryContainer)),
              )
            else
              FilledButton.tonal(
                onPressed: onPressed,
                child: const Text('تفعيل'),
              ),
          ],
        ),
      ),
    );
  }
}
