import '../models/class_session.dart';
import '../models/enums.dart';

abstract class ClassRepository {
  /// Classes that start on the same calendar day as [day].
  Future<List<ClassSession>> fetchForDay(DateTime day);
}

/// In-memory data: three classes, always dated today.
class MockClassRepository implements ClassRepository {
  MockClassRepository({this.delay = const Duration(milliseconds: 400)});

  final Duration delay;

  @override
  Future<List<ClassSession>> fetchForDay(DateTime day) async {
    await Future<void>.delayed(delay);
    final today = DateTime.now();
    if (day.year != today.year ||
        day.month != today.month ||
        day.day != today.day) {
      return const [];
    }
    DateTime at(int hour, int minute) =>
        DateTime(today.year, today.month, today.day, hour, minute);

    return [
      ClassSession(
        id: 'c1',
        title: 'HSK 1 Group',
        start: at(10, 0),
        end: at(11, 30),
        type: ClassType.group,
        location: 'Online (Google Meet)',
        studentIds: const ['s3', 's4', 's6'],
      ),
      ClassSession(
        id: 'c2',
        title: 'Daniel Lim',
        start: at(15, 0),
        end: at(16, 0),
        type: ClassType.oneToOne,
        location: 'Home studio',
        studentIds: const ['s1'],
      ),
      ClassSession(
        id: 'c3',
        title: 'HSK 3 Adults',
        start: at(20, 0),
        end: at(21, 30),
        type: ClassType.group,
        location: 'Online (Zoom)',
        studentIds: const ['s2', 's5'],
      ),
    ];
  }
}
