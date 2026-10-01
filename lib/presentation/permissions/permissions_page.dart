import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/permission_provider.dart';
import '../widgets/permission_tile.dart';
import '../widgets/status_card.dart';

class PermissionsPage extends StatelessWidget {
  const PermissionsPage({super.key});
  @override Widget build(BuildContext context) {
    final p=context.watch<PermissionProvider>();
    return Scaffold(appBar:AppBar(title:const Text('جاهزية NewVision')),body:RefreshIndicator(onRefresh:p.refresh,child:ListView(physics:const AlwaysScrollableScrollPhysics(),padding:const EdgeInsets.fromLTRB(20,8,20,28),children:[
      StatusCard(ready:p.ready,title:p.ready?'الجهاز جاهز':'أكمل متطلبات التشغيل',subtitle:p.ready?'جميع الصلاحيات مفعلة ويمكن بدء التتبع.':'أكمل متطلبات الكاميرا والعرض فوق التطبيقات وإمكانية الوصول.'),
      const SizedBox(height:18),if(p.loading)const LinearProgressIndicator(minHeight:3),const SizedBox(height:12),
      PermissionTile(icon:Icons.camera_alt_outlined,title:'الكاميرا',subtitle:'تحليل العين محلياً على الجهاز.',granted:p.camera,onPressed:p.requestCamera),
      PermissionTile(icon:Icons.layers_outlined,title:'العرض فوق التطبيقات',subtitle:'إظهار المؤشر فوق التطبيقات الأخرى.',granted:p.overlay,onPressed:p.requestOverlay),
      PermissionTile(icon:Icons.accessibility_new_rounded,title:'إمكانية الوصول',subtitle:'السماح بالتفاعل بالنقرات من خلال النظام.',granted:p.accessibility,onPressed:p.requestAccessibility),
      if(p.error!=null)...[const SizedBox(height:12),Card(color:Theme.of(context).colorScheme.errorContainer,child:Padding(padding:const EdgeInsets.all(14),child:Row(children:[Icon(Icons.info_outline,color:Theme.of(context).colorScheme.onErrorContainer),const SizedBox(width:10),Expanded(child:Text(p.error!,style:TextStyle(color:Theme.of(context).colorScheme.onErrorContainer))),if(!p.camera)IconButton(tooltip:'إعدادات التطبيق',onPressed:p.openAppSettings,icon:const Icon(Icons.settings_outlined))])))],
      const SizedBox(height:18),FilledButton.icon(onPressed:p.ready?()=>context.go('/tracking'):null,icon:const Icon(Icons.visibility_rounded),label:const Padding(padding:EdgeInsets.symmetric(vertical:13),child:Text('متابعة إلى التتبع'))),
      if(!p.ready)...[const SizedBox(height:10),Text('لن يبدأ التتبع حتى تكتمل جميع المتطلبات.',textAlign:TextAlign.center,style:Theme.of(context).textTheme.bodySmall)],
    ])));
  }
}
