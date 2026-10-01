import 'package:flutter/material.dart';
class SettingSlider extends StatelessWidget{
 const SettingSlider({super.key,required this.value,required this.label,required this.onChanged});
 final double value; final String label; final ValueChanged<double> onChanged;
 @override Widget build(BuildContext context)=>Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Row(children:[Text(label,style:Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight:FontWeight.w700)),const Spacer(),Text(value.round().toString()+' ms',style:Theme.of(context).textTheme.labelLarge)]),Slider(value:value,min:500,max:2000,divisions:15,label:value.round().toString()+' ms',onChanged:onChanged)]);
}
