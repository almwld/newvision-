import 'package:flutter/material.dart';
class PermissionTile extends StatelessWidget {
  const PermissionTile({super.key, required this.icon, required this.title, required this.subtitle, required this.granted, required this.onPressed});
  final IconData icon; final String title; final String subtitle; final bool granted; final VoidCallback? onPressed;
  @override Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(margin: const EdgeInsets.only(bottom: 10), child: InkWell(onTap: granted ? null : onPressed,
      child: Padding(padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 10, 12), child: Row(children: [
        Container(width: 46, height: 46, decoration: BoxDecoration(color: granted ? scheme.primaryContainer : scheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(14)),
          child: Icon(granted ? Icons.check_rounded : icon, color: granted ? scheme.onPrimaryContainer : scheme.onSurfaceVariant)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 3), Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
        ])),
        const SizedBox(width: 8),
        if (granted) Icon(Icons.verified_rounded, color: scheme.primary)
        else FilledButton(onPressed: onPressed, child: const Text('تفعيل')),
      ])));
  }
}
