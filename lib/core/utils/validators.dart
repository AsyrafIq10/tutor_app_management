class Validators {
  static final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static final _letterRegex = RegExp(r'[A-Za-zÀ-ɏ一-鿿]');
  static final _feeRegex = RegExp(r'^\d+(\.\d{1,2})?$');

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

  /// Required, with at least 2 letters.
  static String? fullName(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return 'Enter the full name';
    if (_letterRegex.allMatches(text).length < 2) {
      return 'Name is too short';
    }
    return null;
  }

  /// 9 to 12 digits after removing spaces, "-" and "+".
  static String? phone(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return 'Enter a contact number';
    final cleaned = text.replaceAll(RegExp(r'[\s\-+]'), '');
    if (!RegExp(r'^\d{9,12}$').hasMatch(cleaned)) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  /// A number above 0 with at most 2 decimal places.
  static String? fee(String? value) {
    final text = (value ?? '').trim().replaceAll(',', '');
    if (text.isEmpty) return 'Enter the monthly fee';
    if (!_feeRegex.hasMatch(text)) return 'Enter a valid amount, e.g. 150';
    if (double.parse(text) <= 0) return 'Fee must be more than 0';
    return null;
  }
}
