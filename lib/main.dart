import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'presentation/home/home_view_model.dart';
import 'presentation/home/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => HomeViewModel()..initialize(),
      child: const EyeControlApp(),
    ),
  );
}

class EyeControlApp extends StatelessWidget {
  const EyeControlApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        title: 'NewVision',
        debugShowCheckedModeBanner: false,
        supportedLocales: const [
          Locale('ar'),
          Locale('en'),
        ],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        localeResolutionCallback: (locale, supported) {
          if (locale == null) return const Locale('ar');
          return supported.firstWhere(
            (item) => item.languageCode == locale.languageCode,
            orElse: () => const Locale('ar'),
          );
        },
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: const Color(0xFF0A8F83),
          brightness: Brightness.light,
          scaffoldBackgroundColor: const Color(0xFFF4F6F7),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: const Color(0xFF0A8F83),
          brightness: Brightness.dark,
        ),
        themeMode: ThemeMode.system,
        routerConfig: appRouter,
      );
}
