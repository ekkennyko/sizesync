import 'package:go_router/go_router.dart';
import 'package:sizesync/features/converter/converter_screen.dart';
import 'package:sizesync/features/onboarding/onboarding_screen.dart';
import 'package:sizesync/features/profile/profile_screen.dart';
import 'package:sizesync/features/settings/paywall_screen.dart';
import 'package:sizesync/features/settings/settings_screen.dart';

GoRouter createRouter({required bool showOnboarding}) => GoRouter(
  initialLocation: showOnboarding ? '/onboarding' : '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const ConverterScreen()),
    GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
    GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
    GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingScreen()),
    GoRoute(path: '/paywall', builder: (context, state) => const PaywallScreen()),
  ],
);
