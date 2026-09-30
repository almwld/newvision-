import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});
  @override State<SplashPage> createState() => _SplashPageState();
}
class _SplashPageState extends State<SplashPage> {
  Timer? _timer;
  @override void initState() { super.initState(); _timer = Timer(const Duration(milliseconds: 1200), _route); }
  Future<void> _route() async {
    final p = await SharedPreferences.getInstance();
    final done = p.getBool('onboarding.done') ?? false;
    if (!mounted) return;
    context.go(done ? '/' : '/onboarding');
  }
  @override void dispose() { _timer?.cancel(); super.dispose(); }
  @override Widget build(BuildContext c) => Scaffold(
    body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.visibility_outlined, size: 72, color: Theme.of(c).colorScheme.primary),
      const SizedBox(height: 16), Text('NewVision', style: Theme.of(c).textTheme.headlineMedium),
      const SizedBox(height: 20), const CircularProgressIndicator(),
    ])),
  );
}