import 'package:flutter/material.dart';
class PermissionTile extends StatelessWidget{
 const PermissionTile({super.key,required this.icon,required this.title,required this.subtitle,required this.granted,required this.onPressed});
 final IconData icon; final String title,subtitle; final bool granted; final VoidCallback? onPressed;
 @override Widget build(BuildContext context){final s=Theme.of(context).colorScheme;return Card(child:ListTile(contentPadding:const EdgeInsets.symmetric(horizontal:16,vertical:6),leading:Container(width:44,height:44,decoration:BoxDecoration(color:granted?s.primaryContainer:s.surfaceContainerHighest,borderRadius:BorderRadius.circular(14)),child:Icon(granted?Icons.check_rounded:icon,color:granted?s.onPrimaryContainer:s.onSurfaceVariant)),title:Text(title,style:const TextStyle(fontWeight:FontWeight.w700)),subtitle:Padding(padding:const EdgeInsets.only(top:3),child:Text(subtitle)),trailing:granted?Icon(Icons.verified_rounded,color:s.primary):FilledButton.tonal(onPressed:onPressed,child:const Text('السماح'))));}
}
