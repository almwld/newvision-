import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key,required this.icon,required this.title,required this.subtitle,this.action});
  final IconData icon; final String title; final String subtitle; final Widget? action;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(child: Padding(padding: const EdgeInsets.all(32),child: Column(mainAxisSize: MainAxisSize.min,children: [
      Container(width: 84,height: 84,decoration: BoxDecoration(color: scheme.primaryContainer,shape: BoxShape.circle),child: Icon(icon,size: 40,color: scheme.onPrimaryContainer)),
      const SizedBox(height: 18),
      Text(title,style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),textAlign: TextAlign.center),
      const SizedBox(height: 8),Text(subtitle,textAlign: TextAlign.center),
      if (action != null) ...[const SizedBox(height: 18),action!],
    ]));
  }
}
