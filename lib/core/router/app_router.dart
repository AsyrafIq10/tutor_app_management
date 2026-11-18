import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/auth_provider.dart';
import '../../features/auth/login_screen.dart';
import '../../features/student/student_home_screen.dart';
import '../../features/tutor/tutor_home_screen.dart';

GoRouter createRouter(AuthProvider auth) {
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: auth,
    redirect: (context, state) {
      final location = state.matchedLocation;

      if (auth.status == AuthStatus.unknown) {
        return location == '/splash' ? null : '/splash';
      }
      if (auth.status == AuthStatus.unauthenticated) {
        return location == '/login' ? null : '/login';
      }

      // Authenticated: send each role to its own area (FR-01 acceptance:
      // a student can never reach tutor screens).
      final isTutor = auth.user!.isTutor;
      final home = isTutor ? '/tutor' : '/student';
      if (location == '/login' || location == '/splash') return home;
      if (location.startsWith('/tutor') && !isTutor) return home;
      if (location.startsWith('/student') && isTutor) return home;
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const _SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/tutor', builder: (_, __) => const TutorHomeScreen()),
      GoRoute(path: '/student', builder: (_, __) => const StudentHomeScreen()),
    ],
  );
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}