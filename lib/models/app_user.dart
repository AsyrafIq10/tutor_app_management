enum UserRole { tutor, student }

class AppUser {
  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
  });

  final String uid;
  final String name;
  final String email;
  final UserRole role;

  bool get isTutor => role == UserRole.tutor;

  /// Reads the Firestore document users/{uid}.
  /// Returns null if the role is missing or not "Tutor" / "Student".
  static AppUser? fromMap(String uid, Map<String, dynamic> data,
      {String? fallbackEmail}) {
    final roleText = (data['role'] as String? ?? '').toLowerCase();
    final UserRole role;
    if (roleText == 'tutor') {
      role = UserRole.tutor;
    } else if (roleText == 'student') {
      role = UserRole.student;
    } else {
      return null;
    }
    return AppUser(
      uid: uid,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? fallbackEmail ?? '',
      role: role,
    );
  }
}