import '../models/enums.dart';
import '../models/student.dart';

/// Screens and providers depend only on this interface.
/// A Firestore version will replace [MockStudentRepository] later.
abstract class StudentRepository {
  Future<List<Student>> fetchAll();

  /// Saves a new student and returns it with its final id.
  Future<Student> add(Student student);
}

/// In-memory data for development. Data resets when the app restarts.
class MockStudentRepository implements StudentRepository {
  MockStudentRepository({
    this.delay = const Duration(milliseconds: 400),
    List<Student>? seed,
  }) : _students = [...(seed ?? _seedStudents())];

  /// Fake network delay so loading states are visible.
  final Duration delay;
  final List<Student> _students;
  int _nextId = 100;

  @override
  Future<List<Student>> fetchAll() async {
    await Future<void>.delayed(delay);
    return List.unmodifiable(_students);
  }

  @override
  Future<Student> add(Student student) async {
    await Future<void>.delayed(delay);
    final saved = student.copyWith(id: 's${_nextId++}');
    _students.add(saved);
    return saved;
  }
}

List<Student> _seedStudents() {
  final created = DateTime(2026, 9, 1);
  Student s(
    String id,
    String name,
    String phone,
    AgeGroup age,
    String level,
    ClassType type,
    double fee, {
    int dueDay = 10,
    bool isActive = true,
    String notes = '',
  }) =>
      Student(
        id: id,
        name: name,
        phone: phone,
        ageGroup: age,
        level: level,
        classType: type,
        monthlyFee: fee,
        dueDay: dueDay,
        createdAt: created,
        isActive: isActive,
        notes: notes,
      );

  return [
    s('s1', 'Daniel Lim', '012-345 6789', AgeGroup.teen, 'HSK 2',
        ClassType.oneToOne, 240),
    s('s2', 'Kevin Wong', '013-222 4410', AgeGroup.adult, 'HSK 3',
        ClassType.group, 180, dueDay: 5),
    s('s3', 'Aisyah Rahman', '017-889 1023', AgeGroup.child, 'Beginner',
        ClassType.group, 150),
    s('s4', 'Mei Ling Tan', '016-404 7788', AgeGroup.teen, 'HSK 1',
        ClassType.group, 150, dueDay: 15),
    s('s5', 'Arjun Nair', '019-675 3341', AgeGroup.adult, 'HSK 4',
        ClassType.oneToOne, 280, notes: 'Prefers evening classes'),
    s('s6', 'Sophia Chong', '011-2345 6780', AgeGroup.child, 'Beginner',
        ClassType.group, 150),
    s('s7', 'Hafiz Ismail', '014-567 2290', AgeGroup.adult, 'HSK 2',
        ClassType.oneToOne, 240, dueDay: 20),
    s('s8', 'Brandon Lee', '012-998 1200', AgeGroup.teen, 'HSK 1',
        ClassType.group, 150, isActive: false, notes: 'Paused for exams'),
  ];
}
