import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/initials_avatar.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../models/student.dart';
import 'students_provider.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  late final TextEditingController _search;

  @override
  void initState() {
    super.initState();
    final students = context.read<StudentsProvider>();
    _search = TextEditingController(text: students.query);
    students.ensureLoaded();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _addStudent() => context.push(TutorRoutes.addStudent);

  @override
  Widget build(BuildContext context) {
    final students = context.watch<StudentsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Students')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addStudent,
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Add student'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: TextField(
              controller: _search,
              onChanged: students.setQuery,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search by name or phone',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: students.query.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear search',
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _search.clear();
                          students.setQuery('');
                        },
                      ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FilterChip(
                label: const Text('Show inactive'),
                selected: students.showInactive,
                onSelected: students.setShowInactive,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Expanded(child: _buildList(students)),
        ],
      ),
    );
  }

  Widget _buildList(StudentsProvider students) {
    if (students.loading && !students.loaded) {
      return const Center(child: CircularProgressIndicator());
    }
    if (students.error != null && !students.loaded) {
      return EmptyState(
        icon: Icons.cloud_off_outlined,
        title: students.error!,
        actionLabel: 'Try again',
        onAction: students.load,
      );
    }
    if (students.isEmpty) {
      return EmptyState(
        icon: Icons.people_outline,
        title: 'No students yet',
        message: 'Add your first student to get started.',
        actionLabel: 'Add student',
        onAction: _addStudent,
      );
    }
    final list = students.visible;
    if (list.isEmpty) {
      return EmptyState(
        icon: Icons.search_off,
        title: 'No students found',
        message: students.query.trim().isEmpty
            ? 'All your students are inactive. Turn on "Show inactive".'
            : 'Try another name or number.',
        actionLabel: 'Add student',
        onAction: _addStudent,
      );
    }
    return RefreshIndicator(
      onRefresh: students.load,
      child: ListView.separated(
        // Extra bottom space so the FAB does not cover the last card.
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        itemCount: list.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (_, i) => _StudentTile(student: list[i]),
      ),
    );
  }
}

class _StudentTile extends StatelessWidget {
  const _StudentTile({required this.student});

  final Student student;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        onTap: () => context.push(TutorRoutes.student(student.id)),
        leading: Opacity(
          opacity: student.isActive ? 1 : 0.5,
          child: InitialsAvatar(initials: student.initials),
        ),
        title: Text(
          student.name,
          style: text.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: student.isActive ? AppColors.textDark : AppColors.textMuted,
          ),
        ),
        subtitle: Text(
          '${student.level} · ${student.classType.label}\n${student.phone}',
          style: text.bodySmall?.copyWith(color: AppColors.textMuted),
        ),
        isThreeLine: true,
        trailing: student.isActive
            ? const Icon(Icons.chevron_right, color: AppColors.textMuted)
            : const StatusChip(label: 'Inactive', tone: StatusTone.neutral),
      ),
    );
  }
}
