class Validators {
  static final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? email(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return 'Enter your email';
    if (!_emailRegex.hasMatch(text)) return 'Enter a valid email address';
    return null;
  }

  static String? password(String? value) {
    if ((value ?? '').isEmpty) return 'Enter your password';
    return null;
  }
}