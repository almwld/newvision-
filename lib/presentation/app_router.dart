import 'package:go_router/go_router.dart';

import 'screens/about_screen.dart';
import 'screens/calibration_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/permissions_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/tracking_screen.dart';
import 'home/home_page.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (_, __) => const SplashPage(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (_, __) => const OnboardingPage(),
    ),
    GoRoute(
      path: '/permissions',
      builder: (_, __) => const PermissionsPage(),
    ),
    GoRoute(
      path: '/',
      builder: (_, __) => const HomePage(),
    ),
    GoRoute(
      path: '/calibration',
      builder: (_, __) => const CalibrationPage(),
    ),
    GoRoute(
      path: '/tracking',
      builder: (_, __) => const TrackingPage(),
    ),
    GoRoute(
      path: '/settings',
      builder: (_, __) => const SettingsPage(),
    ),
    GoRoute(
      path: '/about',
      builder: (_, __) => const AboutPage(),
    ),
  ],
);
