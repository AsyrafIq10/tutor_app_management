import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/coming_soon.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/initials_avatar.dart';
import '../../../core/widgets/status_chip.dart';
import 'students_provider.dart';

/// Basic student profile. Tabs (classes, payments, progress) come later.
class StudentProfileScreen extends StatefulWidget {
  const StudentProfileScreen({super.key, required this.studentId});

  final String studentId;

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  @override
  void initState() {
    super.initState();
    context.read<StudentsProvider>().ensureLoaded();
  }

  @override
  Widget build(BuildContext context) {
    final students = context.watch<StudentsProvider>();
    final student = students.byId(widget.studentId);
    final text = Theme.of(context).textTheme;

    if (student == null) {
      return Scaffold(
        appBar: AppBar(),
        body: students.loading
            ? const Center(child: CircularProgressIndicator())
            : const EmptyState(
                icon: Icons.person_off_outlined,
                title: 'Student not found',
                message: 'This student may have been removed.',
              ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student profile'),
        actions: [
          IconButton(
            tooltip: 'Edit',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => showComingSoon(context, 'Edit student'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(child: InitialsAvatar(initials: student.initials, size: 80)),
          const SizedBox(height: 12),
          Text(
            student.name,
            textAlign: TextAlign.center,
            style: text.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: StatusChip(
              label: student.isActive ? 'Active' : 'Inactive',
              tone: student.isActive ? StatusTone.mint : StatusTone.neutral,
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: Column(
              children: [
                _InfoRow(Icons.phone_outlined, 'Contact number', student.phone),
                _InfoRow(Icons.cake_outlined, 'Age group', student.ageGroup.label),
                _InfoRow(Icons.school_outlined, 'Level', student.level),
                _InfoRow(Icons.groups_outlined, 'Class type',
                    student.classType.label),
                _InfoRow(Icons.payments_outlined, 'Monthly fee',
                    formatRm(student.monthlyFee)),
                _InfoRow(Icons.event_outlined, 'Fee due',
                    '${ordinal(student.dueDay)} of every month'),
                _InfoRow(Icons.calendar_today_outlined, 'Joined',
                    DateFormat('d MMM yyyy').format(student.createdAt)),
              ],
            ),
          ),
          if (student.notes.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Card(
              child: _InfoRow(Icons.notes_outlined, 'Notes', student.notes),
            ),
          ],
          const SizedBox(height: 20),
          Text(
            'Classes, payments and progress will show here later.',
            textAlign: TextAlign.center,
            style: text.bodySmall?.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.icon, this.label, this.value);

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(
        label,
        style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(fontSize: 16, color: AppColors.textDark),
      ),
    );
  }
}
