import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/calibration_provider.dart';
import '../providers/permission_provider.dart';
import '../widgets/setting_slider.dart';
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  @override Widget build(BuildContext context) {
    final settings=context.watch<SettingsProvider>(); final calibration=context.watch<CalibrationProvider>(); final permissions=context.watch<PermissionProvider>();
    final scheme=Theme.of(context).colorScheme;
    return Scaffold(appBar: AppBar(title: const Text('الإعدادات')),body: ListView(padding: const EdgeInsets.fromLTRB(20,8,20,30),children:[
      _Section(title:'المظهر',children:[
        SwitchListTile.adaptive(contentPadding: EdgeInsets.zero,secondary: const Icon(Icons.dark_mode_outlined),title: const Text('الوضع الداكن'),subtitle: const Text('تغيير مظهر الواجهة'),value: settings.darkMode,onChanged: settings.setDarkMode),
        ListTile(contentPadding: EdgeInsets.zero,leading: const Icon(Icons.language_rounded),title: const Text('اللغة'),trailing: DropdownButtonHideUnderline(child: DropdownButton<String>(value: settings.locale.languageCode,items: const [DropdownMenuItem(value:'ar',child:Text('العربية')),DropdownMenuItem(value:'en',child:Text('English'))],onChanged:(v){if(v!=null)settings.setLanguage(v);}))),
      ]),
      const SizedBox(height:14),
      _Section(title:'التفاعل',children:[SettingSlider(value:settings.dwellMs.toDouble(),label:'مدة التثبيت',onChanged:(v)=>settings.setDwellMs(v.round())),Text('المدة الحالية: '+settings.dwellMs.toString()+' ms',style:Theme.of(context).textTheme.bodySmall)]),
      const SizedBox(height:14),
      _Section(title:'الصلاحيات',children:[
        _PermissionRow(icon:Icons.camera_alt_outlined,title:'الكاميرا',active:permissions.camera,onTap:permissions.requestCamera),
        _PermissionRow(icon:Icons.layers_outlined,title:'العرض فوق التطبيقات',active:permissions.overlay,onTap:permissions.requestOverlay),
        _PermissionRow(icon:Icons.accessibility_new_rounded,title:'إمكانية الوصول',active:permissions.accessibility,onTap:permissions.requestAccessibility),
      ]),
      const SizedBox(height:14),
      Card(color:scheme.errorContainer,child:ListTile(leading:Icon(Icons.delete_outline_rounded,color:scheme.onErrorContainer),title:Text('إعادة ضبط المعايرة',style:TextStyle(color:scheme.onErrorContainer,fontWeight:FontWeight.w700)),subtitle:Text('يحذف نموذج المعايرة المحلي فقط.',style:TextStyle(color:scheme.onErrorContainer)),onTap:calibration.busy?null:()async{
        final confirmed=await showDialog<bool>(context:context,builder:(d)=>AlertDialog(title:const Text('حذف المعايرة؟'),content:const Text('سيحتاج التطبيق إلى معايرة جديدة قبل الاستخدام الدقيق.'),actions:[TextButton(onPressed:()=>Navigator.pop(d,false),child:const Text('إلغاء')),FilledButton(onPressed:()=>Navigator.pop(d,true),child:const Text('حذف'))]));
        if(confirmed==true)await calibration.clear();
      })),
      const SizedBox(height:20),Center(child:Text('NewVision 1.0.0',style:Theme.of(context).textTheme.labelMedium)),
    ]));
  }
}
class _Section extends StatelessWidget { const _Section({required this.title,required this.children}); final String title; final List<Widget> children; @override Widget build(BuildContext c)=>Card(child:Padding(padding:const EdgeInsets.fromLTRB(16,8,16,14),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Padding(padding:const EdgeInsets.symmetric(vertical:8),child:Text(title,style:Theme.of(c).textTheme.titleSmall?.copyWith(fontWeight:FontWeight.w800))),...children]))); }
class _PermissionRow extends StatelessWidget { const _PermissionRow({required this.icon,required this.title,required this.active,required this.onTap}); final IconData icon; final String title; final bool active; final VoidCallback onTap; @override Widget build(BuildContext c)=>ListTile(contentPadding:EdgeInsets.zero,leading:Icon(icon),title:Text(title),trailing:Icon(active?Icons.check_circle_rounded:Icons.open_in_new_rounded,color:active?Theme.of(c).colorScheme.primary:null),onTap:active?null:onTap); }
