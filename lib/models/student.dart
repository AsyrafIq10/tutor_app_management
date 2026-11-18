import 'enums.dart';

class Student {
  const Student({
    required this.id,
    required this.name,
    required this.phone,
    required this.ageGroup,
    required this.level,
    required this.classType,
    required this.monthlyFee,
    required this.dueDay,
    required this.createdAt,
    this.notes = '',
    this.isActive = true,
  }) : assert(dueDay >= 1 && dueDay <= 28);

  final String id;
  final String name;
  final String phone;
  final AgeGroup ageGroup;

  /// One of [studentLevels], e.g. "HSK 2".
  final String level;
  final ClassType classType;

  /// Monthly fee in RM.
  final double monthlyFee;

  /// Day of the month the fee is due (1 to 28).
  final int dueDay;
  final DateTime createdAt;
  final String notes;

  /// BR-10: inactive students are hidden from active lists, history is kept.
  final bool isActive;

  /// "Daniel Lim" -> "DL", "Mei" -> "M".
  String get initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return '?';
    final first = parts.first[0];
    final last = parts.length > 1 ? parts.last[0] : '';
    return (first + last).toUpperCase();
  }

  Student copyWith({
    String? id,
    String? name,
    String? phone,
    AgeGroup? ageGroup,
    String? level,
    ClassType? classType,
    double? monthlyFee,
    int? dueDay,
    DateTime? createdAt,
    String? notes,
    bool? isActive,
  }) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      ageGroup: ageGroup ?? this.ageGroup,
      level: level ?? this.level,
      classType: classType ?? this.classType,
      monthlyFee: monthlyFee ?? this.monthlyFee,
      dueDay: dueDay ?? this.dueDay,
      createdAt: createdAt ?? this.createdAt,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
    );
  }
}
