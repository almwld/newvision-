import 'package:flutter/material.dart';

class PermissionTile extends StatelessWidget {
  const PermissionTile({super.key,required this.icon,required this.title,required this.subtitle,required this.granted,required this.onPressed});
  final IconData icon; final String title; final String subtitle; final bool granted; final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 14,vertical: 10),child: Row(children: [
      Container(width: 46,height: 46,decoration: BoxDecoration(color: granted ? scheme.primaryContainer : scheme.surfaceContainerHighest,borderRadius: BorderRadius.circular(14)),child: Icon(granted ? Icons.check_rounded : icon,color: granted ? scheme.onPrimaryContainer : scheme.onSurfaceVariant)),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,children: [
        Text(title,style: const TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 3),Text(subtitle,style: Theme.of(context).textTheme.bodySmall),
      ])),
      const SizedBox(width: 10),
      granted ? Icon(Icons.verified_rounded,color: scheme.primary) : OutlinedButton(onPressed: onPressed,child: const Text('سماح')),
    ]));
  }
}
