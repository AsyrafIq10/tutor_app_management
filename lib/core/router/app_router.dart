import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/auth_provider.dart';
import '../../features/auth/login_screen.dart';
import '../../features/student/student_home_screen.dart';
import '../../features/tutor/home/tutor_home_screen.dart';
import '../../features/tutor/students/add_student_screen.dart';
import '../../features/tutor/students/student_profile_screen.dart';
import '../../features/tutor/students/students_screen.dart';
import '../../features/tutor/tutor_shell.dart';
import '../widgets/coming_soon.dart';

/// Paths used by the tutor area, so screens don't repeat string literals.
class TutorRoutes {
  static const home = '/tutor';
  static const students = '/tutor/students';
  static const schedule = '/tutor/schedule';
  static const payments = '/tutor/payments';
  static const chatbot = '/tutor/chatbot';
  static const addStudent = '/tutor/add-student';
  static String student(String id) => '/tutor/student/$id';
}

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
      final home = isTutor ? TutorRoutes.home : '/student';
      if (location == '/login' || location == '/splash') return home;
      if (location.startsWith('/tutor') && !isTutor) return home;
      if (location.startsWith('/student') && isTutor) return home;
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, _) => const _SplashScreen()),
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/student', builder: (_, _) => const StudentHomeScreen()),

      // Full-screen tutor pages (no bottom navigation bar).
      GoRoute(
        path: TutorRoutes.addStudent,
        builder: (_, _) => const AddStudentScreen(),
      ),
      GoRoute(
        path: '/tutor/student/:id',
        builder: (_, state) =>
            StudentProfileScreen(studentId: state.pathParameters['id']!),
      ),

      // Tutor area with the bottom navigation bar. Each tab keeps its
      // own state when you switch between tabs.
      StatefulShellRoute.indexedStack(
        builder: (_, _, navigationShell) =>
            TutorShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: TutorRoutes.home,
              builder: (_, _) => const TutorHomeScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: TutorRoutes.students,
              builder: (_, _) => const StudentsScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: TutorRoutes.schedule,
              builder: (_, _) => const ComingSoonScreen(
                title: 'Schedule',
                icon: Icons.calendar_month_outlined,
              ),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: TutorRoutes.payments,
              builder: (_, _) => const ComingSoonScreen(
                title: 'Payments',
                icon: Icons.payments_outlined,
              ),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: TutorRoutes.chatbot,
              builder: (_, _) => const ComingSoonScreen(
                title: 'Chatbot',
                icon: Icons.smart_toy_outlined,
              ),
            ),
          ]),
        ],
      ),
    ],
  );
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}
