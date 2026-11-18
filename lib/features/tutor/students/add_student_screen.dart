import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/router/app_router.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../models/enums.dart';
import '../../../models/student.dart';
import 'students_provider.dart';

class AddStudentScreen extends StatefulWidget {
  const AddStudentScreen({super.key});

  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  static const _defaultDueDay = 10;

  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _fee = TextEditingController();
  final _notes = TextEditingController();

  AgeGroup? _ageGroup;
  String? _level;
  ClassType? _classType;
  int _dueDay = _defaultDueDay;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _fee.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final students = context.read<StudentsProvider>();
    // Make sure the list is there before checking for duplicates.
    await students.ensureLoaded();
    if (!mounted) return;

    // BR-03: warn about a duplicate name, but let the tutor decide.
    final existing = students.findDuplicate(_name.text);
    if (existing != null) {
      final choice = await showDialog<_DuplicateChoice>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Student already exists'),
          content: Text(
            'A student named "${existing.name}" is already in your list. '
            'Do you still want to add this student?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, _DuplicateChoice.view),
              child: const Text('View existing'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(minimumSize: const Size(0, 40)),
              onPressed: () => Navigator.pop(context, _DuplicateChoice.save),
              child: const Text('Save anyway'),
            ),
          ],
        ),
      );
      if (!mounted || choice == null) return;
      if (choice == _DuplicateChoice.view) {
        context.push(TutorRoutes.student(existing.id));
        return;
      }
    }

    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    try {
      final saved = await students.add(
        Student(
          id: '',
          name: _name.text.trim().replaceAll(RegExp(r'\s+'), ' '),
          phone: _phone.text.trim(),
          ageGroup: _ageGroup!,
          level: _level!,
          classType: _classType!,
          monthlyFee: double.parse(_fee.text.trim().replaceAll(',', '')),
          dueDay: _dueDay,
          createdAt: DateTime.now(),
          notes: _notes.text.trim(),
        ),
      );
      if (!mounted) return;
      router.pop();
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('${saved.name} added'),
            action: SnackBarAction(
              label: 'View',
              onPressed: () => router.push(TutorRoutes.student(saved.id)),
            ),
          ),
        );
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not save. Please try again.')),
      );
    }
  }

  String? _required(Object? value, String message) =>
      value == null ? message : null;

  @override
  Widget build(BuildContext context) {
    const gap = SizedBox(height: 16);

    return Scaffold(
      appBar: AppBar(title: const Text('Add student')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              TextFormField(
                controller: _name,
                enabled: !_saving,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Full name'),
                validator: Validators.fullName,
              ),
              gap,
              TextFormField(
                controller: _phone,
                enabled: !_saving,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Contact number',
                  hintText: 'e.g. 012-345 6789',
                ),
                validator: Validators.phone,
              ),
              gap,
              DropdownButtonFormField<AgeGroup>(
                initialValue: _ageGroup,
                decoration: const InputDecoration(labelText: 'Age group'),
                items: [
                  for (final a in AgeGroup.values)
                    DropdownMenuItem(value: a, child: Text(a.label)),
                ],
                onChanged: _saving ? null : (v) => setState(() => _ageGroup = v),
                validator: (v) => _required(v, 'Choose an age group'),
              ),
              gap,
              DropdownButtonFormField<String>(
                initialValue: _level,
                decoration: const InputDecoration(labelText: 'Level'),
                items: [
                  for (final l in studentLevels)
                    DropdownMenuItem(value: l, child: Text(l)),
                ],
                onChanged: _saving ? null : (v) => setState(() => _level = v),
                validator: (v) => _required(v, 'Choose a level'),
              ),
              gap,
              DropdownButtonFormField<ClassType>(
                initialValue: _classType,
                decoration: const InputDecoration(labelText: 'Class type'),
                items: [
                  for (final t in ClassType.values)
                    DropdownMenuItem(value: t, child: Text(t.label)),
                ],
                onChanged:
                    _saving ? null : (v) => setState(() => _classType = v),
                validator: (v) => _required(v, 'Choose a class type'),
              ),
              gap,
              TextFormField(
                controller: _fee,
                enabled: !_saving,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Monthly fee',
                  prefixText: 'RM ',
                ),
                validator: Validators.fee,
              ),
              gap,
              DropdownButtonFormField<int>(
                initialValue: _dueDay,
                decoration:
                    const InputDecoration(labelText: 'Fee due every month on'),
                menuMaxHeight: 320,
                items: [
                  for (var d = 1; d <= 28; d++)
                    DropdownMenuItem(value: d, child: Text(ordinal(d))),
                ],
                onChanged: _saving
                    ? null
                    : (v) => setState(() => _dueDay = v ?? _defaultDueDay),
              ),
              gap,
              TextFormField(
                controller: _notes,
                enabled: !_saving,
                minLines: 3,
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      )
                    : const Text('Save student'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _DuplicateChoice { view, save }
