import 'package:flutter/foundation.dart';

import '../../models/app_user.dart';
import '../../services/auth_service.dart';

enum AuthStatus { unknown, unauthenticated, authenticated }

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._service);

  final AuthService _service;

  AuthStatus _status = AuthStatus.unknown;
  AppUser? _user;
  bool _loading = false;
  AuthException? _error;

  AuthStatus get status => _status;
  AppUser? get user => _user;
  bool get loading => _loading;
  AuthException? get error => _error;

  Future<void> init() async {
    _user = await _service.restoreSession();
    _status =
    _user == null ? AuthStatus.unauthenticated : AuthStatus.authenticated;
    notifyListeners();
  }

  Future<bool> signIn(String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _user = await _service.signIn(email, password);
      _status = AuthStatus.authenticated;
      return true;
    } on AuthException catch (e) {
      _error = e;
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _service.signOut();
    _user = null;
    _error = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  void clearError() {
    if (_error == null) return;
    _error = null;
    notifyListeners();
  }
}