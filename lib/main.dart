import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/auth_provider.dart';
import 'firebase_options.dart'; // created by `flutterfire configure`
import 'services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider(AuthService())..init(),
      child: const TutorIQApp(),
    ),
  );
}

class TutorIQApp extends StatefulWidget {
  const TutorIQApp({super.key});

  @override
  State<TutorIQApp> createState() => _TutorIQAppState();
}

class _TutorIQAppState extends State<TutorIQApp> {
  late final GoRouter _router = createRouter(context.read<AuthProvider>());

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'TutorIQ',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: _router,
    );
  }
}