import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
class SplashPage extends StatefulWidget { const SplashPage({super.key}); @override State<SplashPage> createState() => _SplashPageState(); }
class _SplashPageState extends State<SplashPage> {
  Timer? _timer;
  @override void initState() { super.initState(); _timer = Timer(const Duration(milliseconds: 1400), _route); }
  Future<void> _route() async {
    final preferences = await SharedPreferences.getInstance();
    final done = preferences.getBool('onboarding.done') ?? false;
    if (!mounted) return;
    context.go(done ? '/' : '/onboarding');
  }
  @override void dispose() { _timer?.cancel(); super.dispose(); }
  @override Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(body: DecoratedBox(
      decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [scheme.surface, scheme.surfaceContainerHighest])),
      child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 96, height: 96, decoration: BoxDecoration(color: scheme.primaryContainer, borderRadius: BorderRadius.circular(30)),
          child: Icon(Icons.visibility_rounded, size: 54, color: scheme.onPrimaryContainer)),
        const SizedBox(height: 24),
        Text('NewVision', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 6), const Text('On-device eye control'),
        const SizedBox(height: 34), const SizedBox(width: 34, height: 34, child: CircularProgressIndicator(strokeWidth: 3)),
      ])),
    ));
  }
}
