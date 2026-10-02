import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'presentation/app_router.dart';
import 'presentation/home/home_view_model.dart';
import 'presentation/providers/calibration_provider.dart';
import 'presentation/providers/permission_provider.dart';
import 'presentation/providers/settings_provider.dart';
import 'presentation/providers/tracking_provider.dart';

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
class EyeControlApp extends StatelessWidget {
 const EyeControlApp({super.key});
 @override Widget build(BuildContext context){
  final settings=context.watch<SettingsProvider>();
  const seed=Color(0xFF0A8F83);
  final light=ColorScheme.fromSeed(seedColor:seed);
  final dark=ColorScheme.fromSeed(seedColor:seed,brightness:Brightness.dark);
  ThemeData makeTheme(ColorScheme s,Brightness b){
   final base=ThemeData(useMaterial3:true,colorScheme:s,brightness:b);
   return base.copyWith(
    scaffoldBackgroundColor:b==Brightness.dark?const Color(0xFF0B1113):const Color(0xFFF5F8F8),
    appBarTheme:AppBarTheme(centerTitle:false,scrolledUnderElevation:0,backgroundColor:Colors.transparent,surfaceTintColor:Colors.transparent,titleTextStyle:base.textTheme.titleLarge?.copyWith(fontWeight:FontWeight.w800,color:s.onSurface)),
    cardTheme:CardTheme(elevation:0,margin:const EdgeInsets.only(bottom:10),shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(20))),
    filledButtonTheme:FilledButtonThemeData(style:FilledButton.styleFrom(minimumSize:const Size.fromHeight(52),shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(16)))),
    outlinedButtonTheme:OutlinedButtonThemeData(style:OutlinedButton.styleFrom(minimumSize:const Size.fromHeight(52),shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(16)))),
   );
  }
  return MaterialApp.router(title:'NewVision',debugShowCheckedModeBanner:false,locale:settings.locale,supportedLocales:const[Locale('ar'),Locale('en')],localizationsDelegates:GlobalMaterialLocalizations.delegates,theme:makeTheme(light,Brightness.light),darkTheme:makeTheme(dark,Brightness.dark),themeMode:settings.darkMode?ThemeMode.dark:ThemeMode.light,routerConfig:appRouter);
 }
}