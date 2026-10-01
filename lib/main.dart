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

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settings),
        ChangeNotifierProvider(create: (_) => PermissionProvider()..refresh()),
        ChangeNotifierProvider(create: (_) => TrackingProvider()),
        ChangeNotifierProvider(create: (_) => CalibrationProvider()..refresh()),
        ChangeNotifierProvider(create: (_) => HomeViewModel()..initialize()),
      ],
      child: const EyeControlApp(),
    ),
  );
}

class EyeControlApp extends StatelessWidget {
  const EyeControlApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final lightScheme =
        ColorScheme.fromSeed(seedColor: const Color(0xFF0A8F83));
    final darkScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF0A8F83),
      brightness: Brightness.dark,
    );

    final baseTheme = ThemeData(
      useMaterial3: true,
      visualDensity: VisualDensity.standard,
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      cardTheme: const CardTheme(
        elevation: 0,
        margin: EdgeInsets.symmetric(vertical: 5),
        clipBehavior: Clip.antiAlias,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        scrolledUnderElevation: 0,
      ),
    );

    return MaterialApp.router(
      title: 'NewVision',
      debugShowCheckedModeBanner: false,
      locale: settings.locale,
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: baseTheme.copyWith(
        colorScheme: lightScheme,
        scaffoldBackgroundColor: const Color(0xFFF5F7F8),
      ),
      darkTheme: baseTheme.copyWith(
        colorScheme: darkScheme,
        scaffoldBackgroundColor: const Color(0xFF0E1417),
      ),
      themeMode: settings.darkMode ? ThemeMode.dark : ThemeMode.light,
      routerConfig: appRouter,
    );
  }
}
