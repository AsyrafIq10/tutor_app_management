import 'package:flutter/material.dart';

import 'empty_state.dart';

/// Use this for buttons whose feature is not built yet,
/// so there are no dead buttons.
void showComingSoon(BuildContext context, String feature) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text('$feature is coming soon')));
}

/// A placeholder tab or screen for a feature that is not built yet.
class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({super.key, required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: EmptyState(
        icon: icon,
        title: '$title is coming soon',
        message: 'This part of TutorIQ is still being built.',
      ),
    );
  }
}
