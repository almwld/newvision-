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
  final settings = SettingsProvider();
  await settings.load();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: settings),
      ChangeNotifierProvider(create: (_) => PermissionProvider()..refresh()),
      ChangeNotifierProvider(create: (_) => TrackingProvider()),
      ChangeNotifierProvider(create: (_) => CalibrationProvider()..refresh()),
      ChangeNotifierProvider(create: (_) => HomeViewModel()..initialize()),
    ],
    child: const EyeControlApp(),
  ));
}

class EyeControlApp extends StatelessWidget {
  const EyeControlApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    const seed = Color(0xFF0A8F83);

    ThemeData theme(Brightness brightness) {
      final scheme = ColorScheme.fromSeed(seedColor: seed, brightness: brightness);
      final base = ThemeData(useMaterial3: true, colorScheme: scheme, brightness: brightness);
      final dark = brightness == Brightness.dark;
      return base.copyWith(
        scaffoldBackgroundColor: dark ? const Color(0xFF091112) : const Color(0xFFF4F8F7),
        appBarTheme: AppBarTheme(
          centerTitle: false,
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: base.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: scheme.onSurface,
          ),
        ),
        cardTheme: CardTheme(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 10),
          color: dark ? const Color(0xFF101B1D) : Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: BorderSide(color: scheme.outlineVariant.withOpacity(.45)),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            textStyle: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      );
    }

    return MaterialApp.router(
      title: 'NewVision',
      debugShowCheckedModeBanner: false,
      locale: settings.locale,
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: theme(Brightness.light),
      darkTheme: theme(Brightness.dark),
      themeMode: settings.darkMode ? ThemeMode.dark : ThemeMode.light,
      routerConfig: appRouter,
      builder: (context, child) => Directionality(
        textDirection: settings.locale.languageCode == 'ar'
            ? TextDirection.rtl
            : TextDirection.ltr,
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}