import 'package:flutter/material.dart';
class StatusCard extends StatelessWidget{
  const StatusCard({super.key,required this.ready,required this.title,required this.subtitle});
  final bool ready;final String title,subtitle;
  @override Widget build(BuildContext context){
    final s=Theme.of(context).colorScheme;
    final bg=ready?s.primaryContainer:s.surfaceContainerHighest;
    final fg=ready?s.onPrimaryContainer:s.onSurfaceVariant;
    return Semantics(container:true,label:'$title. $subtitle',child:Container(padding:const EdgeInsets.all(18),decoration:BoxDecoration(color:bg,borderRadius:BorderRadius.circular(22),border:Border.all(color:s.outlineVariant)),child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Container(width:46,height:46,decoration:BoxDecoration(color:ready?s.primary:s.surface,borderRadius:BorderRadius.circular(15)),child:Icon(ready?Icons.check_rounded:Icons.info_outline_rounded,color:ready?s.onPrimary:fg)),
      const SizedBox(width:14),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight:FontWeight.w800,color:fg)),const SizedBox(height:5),Text(subtitle,style:Theme.of(context).textTheme.bodyMedium?.copyWith(color:fg))]))
    ])));
  }
}