import 'package:flutter/foundation.dart';

import '../../../data/student_repository.dart';
import '../../../models/student.dart';

/// Holds the student list for the tutor area.
/// Created once in main.dart, so the Students tab and the
/// Add student screen share the same data.
class StudentsProvider extends ChangeNotifier {
  StudentsProvider(this._repository);

  final StudentRepository _repository;

  List<Student> _all = [];
  bool _loading = false;
  bool _loaded = false;
  String? _error;
  String _query = '';
  bool _showInactive = false;

  bool get loading => _loading;
  bool get loaded => _loaded;
  String? get error => _error;
  String get query => _query;
  bool get showInactive => _showInactive;

  /// True when there are no students at all (not even inactive ones).
  bool get isEmpty => _all.isEmpty;

  /// The list to show: filtered by search and BR-10,
  /// sorted active first, then by name.
  List<Student> get visible {
    final q = _query.trim().toLowerCase();
    final qDigits = _digits(q);
    final result = _all.where((s) {
      if (!_showInactive && !s.isActive) return false;
      if (q.isEmpty) return true;
      if (s.name.toLowerCase().contains(q)) return true;
      return qDigits.isNotEmpty && _digits(s.phone).contains(qDigits);
    }).toList()
      ..sort((a, b) {
        if (a.isActive != b.isActive) return a.isActive ? -1 : 1;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });
    return result;
  }

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _all = [...await _repository.fetchAll()];
      _loaded = true;
    } catch (_) {
      _error = 'Could not load students. Please try again.';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Loads only the first time it is called.
  Future<void> ensureLoaded() async {
    if (_loaded || _loading) return;
    await load();
  }

  void setQuery(String value) {
    if (value == _query) return;
    _query = value;
    notifyListeners();
  }

  void setShowInactive(bool value) {
    if (value == _showInactive) return;
    _showInactive = value;
    notifyListeners();
  }

  Student? byId(String id) {
    for (final s in _all) {
      if (s.id == id) return s;
    }
    return null;
  }

  /// BR-03: returns a student with the same name, ignoring
  /// upper/lower case and extra spaces. Includes inactive students.
  Student? findDuplicate(String name) {
    final key = normalizeName(name);
    if (key.isEmpty) return null;
    for (final s in _all) {
      if (normalizeName(s.name) == key) return s;
    }
    return null;
  }

  Future<Student> add(Student student) async {
    final saved = await _repository.add(student);
    _all = [..._all, saved];
    notifyListeners();
    return saved;
  }

  static String normalizeName(String name) =>
      name.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();

  static String _digits(String text) => text.replaceAll(RegExp(r'\D'), '');
}
