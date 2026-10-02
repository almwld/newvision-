import 'package:flutter/material.dart';

class PermissionTile extends StatelessWidget {
  const PermissionTile({super.key, required this.icon, required this.title, required this.subtitle, required this.granted, required this.onPressed});
  final IconData icon;
  final String title;
  final String subtitle;
  final bool granted;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsetsDirectional.fromSTEB(14, 10, 10, 10),
        leading: Container(
          width: 46, height: 46,
          decoration: BoxDecoration(color: granted ? scheme.primaryContainer : scheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(14)),
          child: Icon(granted ? Icons.check_rounded : icon, color: granted ? scheme.onPrimaryContainer : scheme.onSurfaceVariant),
        ),
        title: Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
        subtitle: Padding(padding: const EdgeInsets.only(top: 3), child: Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis)),
        trailing: granted
            ? Icon(Icons.verified_rounded, color: scheme.primary)
            : FilledButton.tonal(onPressed: onPressed, child: const Text('سماح')),
      ),
    );
  }
}
