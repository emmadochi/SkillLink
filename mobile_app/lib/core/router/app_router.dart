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
import '../../features/settings/presentation/screens/saved_addresses_screen.dart';
import '../../features/settings/presentation/screens/payment_methods_screen.dart';
import '../../features/settings/presentation/screens/faq_screen.dart';
import '../../features/settings/presentation/screens/privacy_policy_screen.dart';
import '../../features/settings/presentation/screens/about_screen.dart';
import '../../features/artisan/presentation/screens/artisan_setup_screen.dart';
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
      builder: (context, state) {
        final categoryIdStr = state.uri.queryParameters['categoryId'];
        return ArtisanListingScreen(
          category: state.uri.queryParameters['category'],
          categoryId: categoryIdStr != null ? int.tryParse(categoryIdStr) : null,
        );
      },
    ),
    GoRoute(
      path: '${AppRoutes.artisanProfile}/:id',
      name: 'artisan-profile',
      builder: (context, state) => ArtisanProfileScreen(
        artisanId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: AppRoutes.artisanProfileSetup,
      name: 'artisan-setup',
      builder: (_, __) => const ArtisanSetupScreen(),
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
    // ── Settings ──────────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.profile,
      name: 'profile',
      builder: (_, __) => const ProfileScreen(),
    ),
    GoRoute(
      path: AppRoutes.savedAddresses,
      name: 'saved-addresses',
      builder: (_, __) => const SavedAddressesScreen(),
    ),
    GoRoute(
      path: AppRoutes.paymentMethods,
      name: 'payment-methods',
      builder: (_, __) => const PaymentMethodsScreen(),
    ),
    GoRoute(
      path: AppRoutes.faq,
      name: 'faq',
      builder: (_, __) => const FAQScreen(),
    ),
    GoRoute(
      path: AppRoutes.privacyPolicy,
      name: 'privacy-policy',
      builder: (_, __) => const PrivacyPolicyScreen(),
    ),
    GoRoute(
      path: AppRoutes.about,
      name: 'about',
      builder: (_, __) => const AboutScreen(),
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
  static const artisanProfile      = '/artisan-profile';
  static const artisanProfileSetup = '/artisan-setup';
  static const booking             = '/booking';
  static const bookingDetail      = '/booking-detail';
  static const bookingConfirmation= '/booking/confirmation';
  static const chatList           = '/messages';
  static const chat               = '/chat';
  static const customerDashboard  = '/dashboard';
  static const artisanDashboard   = '/artisan-dashboard';
  static const notifications      = '/notifications';
  static const settings           = '/settings';
  static const profile            = '/profile';
  static const savedAddresses     = '/saved-addresses';
  static const paymentMethods     = '/payment-methods';
  static const faq                = '/faq';
  static const privacyPolicy      = '/privacy-policy';
  static const about              = '/about';
}
