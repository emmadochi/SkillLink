import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/onboarding/presentation/screens/splash_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/auth/presentation/screens/otp_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/artisan/presentation/screens/artisan_listing_screen.dart';
import '../../features/artisan/presentation/screens/artisan_profile_screen.dart';
import '../../features/booking/presentation/screens/booking_screen.dart';
import '../../features/booking/presentation/screens/booking_confirmation_screen.dart';
import '../../features/chat/presentation/screens/chat_screen.dart';
import '../../features/chat/presentation/screens/chat_list_screen.dart';
import '../../features/dashboard/presentation/screens/customer_dashboard_screen.dart';
import '../../features/dashboard/presentation/screens/artisan_dashboard_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/settings/presentation/screens/profile_screen.dart';
import '../constants/app_constants.dart';
import 'shell_route.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  debugLogDiagnostics: true,
  routes: [
    // ── Splash & Onboarding ──────────────────────────────────────────
    GoRoute(
      path: AppRoutes.splash,
      name: 'splash',
      builder: (_, __) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.onboarding,
      name: 'onboarding',
      builder: (_, __) => const OnboardingScreen(),
    ),

    // ── Authentication ───────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.login,
      name: 'login',
      builder: (_, __) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.signup,
      name: 'signup',
      builder: (_, __) => const SignupScreen(),
    ),
    GoRoute(
      path: AppRoutes.otp,
      name: 'otp',
      builder: (context, state) => OtpScreen(
        phone: state.uri.queryParameters['phone'] ?? '',
      ),
    ),

    // ── Authenticated Shell (Bottom Nav) ─────────────────────────────
    AppShellRoute.route,

    // ── Artisan ───────────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.artisanListing,
      name: 'artisan-listing',
      builder: (context, state) => ArtisanListingScreen(
        category: state.uri.queryParameters['category'],
      ),
    ),
    GoRoute(
      path: '${AppRoutes.artisanProfile}/:id',
      name: 'artisan-profile',
      builder: (context, state) => ArtisanProfileScreen(
        artisanId: state.pathParameters['id']!,
      ),
    ),

    // ── Booking ───────────────────────────────────────────────────────
    GoRoute(
      path: '${AppRoutes.booking}/:artisanId',
      name: 'booking',
      builder: (context, state) => BookingScreen(
        artisanId: state.pathParameters['artisanId']!,
      ),
    ),
    GoRoute(
      path: AppRoutes.bookingConfirmation,
      name: 'booking-confirmation',
      builder: (_, __) => const BookingConfirmationScreen(),
    ),

    // ── Chat ──────────────────────────────────────────────────────────
    GoRoute(
      path: '${AppRoutes.chat}/:conversationId',
      name: 'chat',
      builder: (context, state) => ChatScreen(
        conversationId: state.pathParameters['conversationId']!,
      ),
    ),
  ],
);

abstract class AppRoutes {
  static const splash             = '/';
  static const onboarding         = '/onboarding';
  static const login              = '/login';
  static const signup             = '/signup';
  static const otp                = '/otp';
  static const home               = '/home';
  static const artisanListing     = '/artisans';
  static const artisanProfile     = '/artisan';
  static const booking            = '/booking';
  static const bookingConfirmation= '/booking/confirmation';
  static const chatList           = '/messages';
  static const chat               = '/chat';
  static const customerDashboard  = '/dashboard';
  static const artisanDashboard   = '/artisan-dashboard';
  static const notifications      = '/notifications';
  static const settings           = '/settings';
  static const profile            = '/profile';
}
