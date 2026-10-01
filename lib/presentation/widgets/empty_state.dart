import 'package:flutter/material.dart';
class EmptyState extends StatelessWidget{
 const EmptyState({super.key,required this.icon,required this.title,required this.subtitle,this.action});
 final IconData icon; final String title,subtitle; final Widget? action;
 @override Widget build(BuildContext context)=>Center(child:Padding(padding:const EdgeInsets.all(32),child:Column(mainAxisSize:MainAxisSize.min,children:[Container(width:84,height:84,decoration:BoxDecoration(color:Theme.of(context).colorScheme.primaryContainer,shape:BoxShape.circle),child:Icon(icon,size:42,color:Theme.of(context).colorScheme.onPrimaryContainer)),const SizedBox(height:20),Text(title,style:Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight:FontWeight.w800),textAlign:TextAlign.center),const SizedBox(height:8),Text(subtitle,textAlign:TextAlign.center,style:Theme.of(context).textTheme.bodyMedium),if(action!=null)...[const SizedBox(height:20),action!]]));}
}
