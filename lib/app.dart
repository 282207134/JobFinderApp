import 'package:flutter/material.dart';

import 'core/theme.dart';
import 'data/app_state.dart';
import 'data/jobs.dart';
import 'features/auth/auth_pages.dart';
import 'features/discovery/discovery_pages.dart';
import 'features/jobs/job_pages.dart';
import 'features/account/account_pages.dart';
import 'features/payments/payment_pages.dart';

class JobFinderApp extends StatelessWidget {
  const JobFinderApp({super.key, required this.state, this.navigatorKey});
  final AppState state;
  final GlobalKey<NavigatorState>? navigatorKey;
  @override
  Widget build(BuildContext context) => AppScope(
    state: state,
    child: ListenableBuilder(
      listenable: state,
      builder: (context, _) => MaterialApp(
        title: 'Job Finder',
        builder: (context, child) => MediaQuery.removePadding(
          context: context,
          removeTop: true,
          removeBottom: true,
          child: child!,
        ),
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
        theme: appTheme(),
        darkTheme: appTheme(dark: true),
        themeMode: state.dark ? ThemeMode.dark : ThemeMode.light,
        initialRoute: !state.onboarded
            ? '/onboarding'
            : state.signedIn
            ? '/home'
            : '/login',
        onGenerateRoute: (settings) {
          final args = settings.arguments;
          final page = switch (settings.name) {
            '/onboarding' || '/' => const OnboardingPage(),
            '/login' => const AuthPage(),
            '/signup' => const AuthPage(signup: true),
            '/forgot' => const RecoveryPage(mode: 'forgot'),
            '/otp' => const RecoveryPage(mode: 'otp'),
            '/reset' => const RecoveryPage(mode: 'reset'),
            '/phone' => const RecoveryPage(mode: 'phone'),
            '/home' => const HomePage(),
            '/search' => SearchPage(
              initialQuery: args is String ? args : '',
              initialFilter: args is JobFilter ? args : const JobFilter(),
            ),
            '/categories' => const CategoriesPage(),
            '/popular' => const JobListPage(),
            '/saved' => const JobListPage(saved: true),
            '/applications' => const JobListPage(applied: true),
            '/filter' => FilterPage(
              initial: args is JobFilter ? args : const JobFilter(),
            ),
            '/job' => JobDetailPage(job: args is Job ? args : jobs[8]),
            '/map' => const MapPage(),
            '/profile' => const ProfilePage(),
            '/account' => const AccountPage(),
            '/settings' => const SettingsPage(),
            '/activity' => const ActivityPage(),
            '/notifications' => const NotificationsPage(),
            '/help' => const HelpPage(),
            '/payments' => const PaymentMethodsPage(),
            '/card' => const AddCardPage(),
            _ => const HomePage(),
          };
          return MaterialPageRoute<dynamic>(
            settings: settings,
            builder: (_) => page,
          );
        },
      ),
    ),
  );
}
