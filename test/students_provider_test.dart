import 'package:flutter_test/flutter_test.dart';
import 'package:tutor_app_management/data/student_repository.dart';
import 'package:tutor_app_management/features/tutor/students/students_provider.dart';
import 'package:tutor_app_management/models/enums.dart';
import 'package:tutor_app_management/models/student.dart';

Student _student(String id, String name, String phone, {bool active = true}) =>
    Student(
      id: id,
      name: name,
      phone: phone,
      ageGroup: AgeGroup.adult,
      level: 'HSK 1',
      classType: ClassType.group,
      monthlyFee: 150,
      dueDay: 10,
      createdAt: DateTime(2026, 1, 1),
      isActive: active,
    );

void main() {
  late StudentsProvider provider;

  setUp(() async {
    provider = StudentsProvider(
      MockStudentRepository(
        delay: Duration.zero,
        seed: [
          _student('1', 'Daniel Lim', '012-345 6789'),
          _student('2', 'Kevin Wong', '013-222 4410'),
          _student('3', 'Aisyah Rahman', '017-889 1023'),
          _student('4', 'Brandon Lee', '012-998 1200', active: false),
        ],
      ),
    );
    await provider.load();
  });

  List<String> names() => provider.visible.map((s) => s.name).toList();

  test('inactive students are hidden by default (BR-10)', () {
    expect(names(), isNot(contains('Brandon Lee')));
    expect(names(), hasLength(3));
  });

  test('toggle shows inactive students, sorted after active ones', () {
    provider.setShowInactive(true);
    expect(names(), ['Aisyah Rahman', 'Daniel Lim', 'Kevin Wong', 'Brandon Lee']);
  });

  test('search by partial name ignores case', () {
    provider.setQuery('won');
    expect(names(), ['Kevin Wong']);
    provider.setQuery('DAN');
    expect(names(), ['Daniel Lim']);
  });

  test('search by phone digits ignores spaces and dashes', () {
    provider.setQuery('3456');
    expect(names(), ['Daniel Lim']);
    provider.setQuery('017 889');
    expect(names(), ['Aisyah Rahman']);
  });

  test('duplicate name check ignores case and spaces (BR-03)', () {
    expect(provider.findDuplicate('  daniel   LIM '), isNotNull);
    expect(provider.findDuplicate('Brandon Lee')?.id, '4'); // inactive too
    expect(provider.findDuplicate('Daniel Lin'), isNull);
    expect(provider.findDuplicate('   '), isNull);
  });

  test('a newly added student appears in the list', () async {
    final saved = await provider.add(_student('', 'Mei Ling Tan', '016-404 7788'));
    expect(saved.id, isNotEmpty);
    expect(names(), contains('Mei Ling Tan'));
    expect(provider.byId(saved.id)?.name, 'Mei Ling Tan');
  });
}
