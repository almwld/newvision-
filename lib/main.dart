import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'presentation/home/home_view_model.dart';
import 'presentation/home/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => HomeViewModel(),
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
        theme: ThemeData.dark(useMaterial3: true),
        routerConfig: appRouter,
      );
}
