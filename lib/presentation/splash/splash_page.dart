import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});
  @override State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  static const _keyLastSplash = 'last_splash_shown';
  static const _splashInterval = Duration(hours: 12);

  @override void initState() { super.initState(); _checkSplash(); }

  Future<void> _checkSplash() async {
    final prefs = await SharedPreferences.getInstance();
    final lastShown = prefs.getInt(_keyLastSplash) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    final diff = now - lastShown;

    if (lastShown > 0 && diff >= 0 && diff < _splashInterval.inMilliseconds) {
      debugPrint('NewVision: splash skipped');
      if (mounted) _navigateNext();
      return;
    }

    debugPrint('NewVision: showing splash');
    await prefs.setInt(_keyLastSplash, now);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (mounted) _navigateNext();
  }

  Future<void> _navigateNext() async {
    final prefs = await SharedPreferences.getInstance();
    final onboardingDone = prefs.getBool('onboarding.done') ?? false;
    if (!onboardingDone) { if (mounted) context.go('/onboarding'); return; }

    const channel = MethodChannel('com.eyecontrol/platform');
    try {
      final ready = await channel.invokeMethod<bool>('calibration.isReady') ?? false;
      if (mounted) context.go(ready ? '/tracking' : '/calibration');
    } catch (error) {
      debugPrint('NewVision: calibration readiness check failed: $error');
      if (mounted) context.go('/calibration');
    }
  }

  @override Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [scheme.surface, scheme.surfaceContainerHighest],
          ),
        ),
        child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 96, height: 96,
            decoration: BoxDecoration(color: scheme.primaryContainer, borderRadius: BorderRadius.circular(30)),
            child: Icon(Icons.visibility_rounded, size: 54, color: scheme.onPrimaryContainer)),
          const SizedBox(height: 24),
          Text('NewVision', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          const Text('On-device eye control'),
          const SizedBox(height: 34),
          const SizedBox(width: 34, height: 34, child: CircularProgressIndicator(strokeWidth: 3)),
        ])),
      ),
    );
  }
}