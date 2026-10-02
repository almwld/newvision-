import 'package:flutter/material.dart';
class StatusCard extends StatelessWidget {
 const StatusCard({super.key,required this.ready,required this.title,required this.subtitle});
 final bool ready; final String title; final String subtitle;
 @override Widget build(BuildContext context){
  final s=Theme.of(context).colorScheme;
  return Card(child:Container(padding:const EdgeInsets.all(16),decoration:BoxDecoration(borderRadius:BorderRadius.circular(20),border:Border.all(color:s.outlineVariant.withOpacity(.55))),child:Row(children:[
   CircleAvatar(radius:24,backgroundColor:ready?s.primaryContainer:s.surfaceContainerHighest,child:Icon(ready?Icons.check_rounded:Icons.info_outline_rounded,color:ready?s.onPrimaryContainer:s.onSurfaceVariant)),
   const SizedBox(width:14),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:const TextStyle(fontWeight:FontWeight.w800)),const SizedBox(height:4),Text(subtitle,style:TextStyle(color:s.onSurfaceVariant))]))
  ])));
 }
}