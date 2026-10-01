import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'presentation/app_router.dart';
import 'presentation/home/home_view_model.dart';
import 'presentation/providers/permission_provider.dart';
import 'presentation/providers/tracking_provider.dart';
import 'presentation/providers/settings_provider.dart';
import 'presentation/providers/calibration_provider.dart';

Future<void> main() async {
 WidgetsFlutterBinding.ensureInitialized();
 final settings=SettingsProvider(); await settings.load();
 runApp(MultiProvider(providers:[
  ChangeNotifierProvider.value(value:settings),
  ChangeNotifierProvider(create:(_)=>PermissionProvider()..refresh()),
  ChangeNotifierProvider(create:(_)=>TrackingProvider()),
  ChangeNotifierProvider(create:(_)=>CalibrationProvider()..refresh()),
  ChangeNotifierProvider(create:(_)=>HomeViewModel()..initialize()),
 ],child:const EyeControlApp()));
}
class EyeControlApp extends StatelessWidget{
 const EyeControlApp({super.key});
 @override Widget build(BuildContext context){final s=context.watch<SettingsProvider>();final light=ColorScheme.fromSeed(seedColor:const Color(0xFF0A8F83),brightness:Brightness.light);final dark=ColorScheme.fromSeed(seedColor:const Color(0xFF0A8F83),brightness:Brightness.dark);return MaterialApp.router(
  title:'NewVision',debugShowCheckedModeBanner:false,locale:s.locale,supportedLocales:const[Locale('ar'),Locale('en')],
  localizationsDelegates:GlobalMaterialLocalizations.delegates,
  theme:ThemeData(useMaterial3:true,colorScheme:light,scaffoldBackgroundColor:const Color(0xFFF4F6F7),cardTheme:const CardTheme(margin:EdgeInsets.symmetric(vertical:5),elevation:0)),
  darkTheme:ThemeData(useMaterial3:true,colorScheme:dark,cardTheme:const CardTheme(margin:EdgeInsets.symmetric(vertical:5),elevation:0)),
  themeMode:s.darkMode?ThemeMode.dark:ThemeMode.light,routerConfig:appRouter);
 }
}
