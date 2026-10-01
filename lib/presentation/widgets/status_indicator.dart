import 'package:flutter/material.dart';
class StatusIndicator extends StatelessWidget{
 const StatusIndicator({super.key,required this.active,this.label}); final bool active; final String? label;
 @override Widget build(BuildContext context)=>Row(mainAxisSize:MainAxisSize.min,children:[Container(width:9,height:9,decoration:BoxDecoration(shape:BoxShape.circle,color:active?Theme.of(context).colorScheme.primary:Theme.of(context).disabledColor)),const SizedBox(width:7),Text(label??(active?'نشط':'غير نشط'),style:Theme.of(context).textTheme.labelMedium)]);
}
