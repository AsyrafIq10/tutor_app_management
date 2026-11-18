import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/coming_soon.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/initials_avatar.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../data/class_repository.dart';
import '../../../data/payment_repository.dart';
import '../../../models/class_session.dart';
import '../../../models/enums.dart';
import '../../auth/auth_provider.dart';
import '../students/students_provider.dart';
import 'tutor_home_provider.dart';

class TutorHomeScreen extends StatelessWidget {
  const TutorHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TutorHomeProvider(
        context.read<ClassRepository>(),
        context.read<PaymentRepository>(),
      )..load(),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  @override
  void initState() {
    super.initState();
    // Needed for the avatars on class cards.
    context.read<StudentsProvider>().ensureLoaded();
  }

  @override
  Widget build(BuildContext context) {
    final home = context.watch<TutorHomeProvider>();
    final name = context.watch<AuthProvider>().user?.name.trim() ?? '';
    final firstName = name.isEmpty ? 'Tutor' : name.split(RegExp(r'\s+')).first;
    final now = DateTime.now();
    final text = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: home.load,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${greetingFor(now)}, $firstName',
                          style: text.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          longDate(now),
                          style: text.bodyMedium
                              ?.copyWith(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Notifications',
                    onPressed: () => showComingSoon(context, 'Notifications'),
                    icon: const Badge(
                      smallSize: 8,
                      child: Icon(Icons.notifications_outlined),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Sign out',
                    icon: const Icon(Icons.logout),
                    onPressed: () => context.read<AuthProvider>().signOut(),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const _SectionTitle('Today\'s classes'),
              const SizedBox(height: 12),
              ..._buildClasses(home),
              const SizedBox(height: 24),
              const _SectionTitle('Payments'),
              const SizedBox(height: 12),
              _OverdueCard(home: home),
              const SizedBox(height: 24),
              const _SectionTitle('Quick actions'),
              const SizedBox(height: 12),
              const _QuickActions(),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildClasses(TutorHomeProvider home) {
    if (home.loading && home.todayClasses.isEmpty) {
      return const [
        Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          ),
        ),
      ];
    }
    if (home.error != null) {
      return [
        Card(
          child: EmptyState(
            compact: true,
            icon: Icons.cloud_off_outlined,
            title: home.error!,
            actionLabel: 'Try again',
            onAction: home.load,
          ),
        ),
      ];
    }
    if (home.todayClasses.isEmpty) {
      return const [
        Card(
          child: EmptyState(
            compact: true,
            icon: Icons.event_available_outlined,
            title: 'No classes today',
            message: 'Enjoy the free time!',
          ),
        ),
      ];
    }
    return [
      for (final c in home.todayClasses)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _ClassCard(session: c),
        ),
    ];
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
    );
  }
}

class _ClassCard extends StatelessWidget {
  const _ClassCard({required this.session});

  final ClassSession session;

  @override
  Widget build(BuildContext context) {
    final students = context.watch<StudentsProvider>();
    final initials = [
      for (final id in session.studentIds) students.byId(id)?.initials,
    ].whereType<String>().toList();
    final text = Theme.of(context).textTheme;
    final isGroup = session.type == ClassType.group;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    timeRange(session.start, session.end),
                    style: text.labelLarge?.copyWith(color: AppColors.primary),
                  ),
                ),
                StatusChip(
                  label: session.type.label,
                  tone: isGroup ? StatusTone.mint : StatusTone.neutral,
                  icon: isGroup ? Icons.groups_outlined : Icons.person_outline,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              session.title,
              style: text.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.place_outlined,
                    size: 16, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    session.location,
                    style: text.bodySmall?.copyWith(color: AppColors.textMuted),
                  ),
                ),
                AvatarStack(initials: initials, size: 28),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OverdueCard extends StatelessWidget {
  const _OverdueCard({required this.home});

  final TutorHomeProvider home;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    if (home.loading && home.overdue.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }
    final count = home.overdue.length;
    final hasOverdue = count > 0;

    return Card(
      color: hasOverdue ? AppColors.warningSoft : AppColors.mintSoft,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
        child: Row(
          children: [
            Icon(
              hasOverdue
                  ? Icons.warning_amber_rounded
                  : Icons.check_circle_outline,
              color: hasOverdue ? AppColors.warning : AppColors.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasOverdue ? 'Overdue payments' : 'No overdue payments',
                    style: text.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  if (hasOverdue)
                    Text(
                      '$count ${count == 1 ? 'student' : 'students'} · '
                      '${formatRm(home.overdueTotal)}',
                      style: text.bodyMedium?.copyWith(color: AppColors.warning),
                    ),
                ],
              ),
            ),
            if (hasOverdue)
              TextButton(
                onPressed: () => context.go(TutorRoutes.payments),
                child: const Text('View'),
              ),
          ],
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    final actions = [
      (
        Icons.person_add_alt_1_outlined,
        'Add student',
        () => context.push(TutorRoutes.addStudent),
      ),
      (
        Icons.event_outlined,
        'Add class',
        () => showComingSoon(context, 'Add class'),
      ),
      (
        Icons.receipt_long_outlined,
        'Record payment',
        () => showComingSoon(context, 'Record payment'),
      ),
      (
        Icons.smart_toy_outlined,
        'Ask chatbot',
        () => context.go(TutorRoutes.chatbot),
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.4,
      children: [
        for (final (icon, label, onTap) in actions)
          Card(
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppColors.mintSoft,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, size: 20, color: AppColors.primary),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        label,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
