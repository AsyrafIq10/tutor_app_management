import 'enums.dart';

class ClassSession {
  const ClassSession({
    required this.id,
    required this.title,
    required this.start,
    required this.end,
    required this.type,
    required this.location,
    required this.studentIds,
  });

  final String id;
  final String title;
  final DateTime start;
  final DateTime end;
  final ClassType type;
  final String location;
  final List<String> studentIds;
}
