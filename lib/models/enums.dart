enum AgeGroup {
  child('Child'),
  teen('Teen'),
  adult('Adult');

  const AgeGroup(this.label);
  final String label;
}

enum ClassType {
  oneToOne('One-to-one'),
  group('Group');

  const ClassType(this.label);
  final String label;
}

/// Levels offered by the tutor, in the order shown in dropdowns.
const List<String> studentLevels = [
  'Beginner',
  'HSK 1',
  'HSK 2',
  'HSK 3',
  'HSK 4',
  'HSK 5',
  'HSK 6',
];
