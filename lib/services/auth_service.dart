import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_user.dart';

enum AuthErrorType { invalidCredentials, offline, noRole, other }

class AuthException implements Exception {
  const AuthException(this.type, this.message);
  final AuthErrorType type;
  final String message;
}

class AuthService {
  AuthService({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  /// Called once at app start. Returns the saved user, or null.
  Future<AppUser?> restoreSession() async {
    final firebaseUser = await _auth.authStateChanges().first;
    if (firebaseUser == null) return null;
    try {
      return await _loadProfile(firebaseUser);
    } on AuthException catch (e) {
      if (e.type == AuthErrorType.noRole) await _auth.signOut();
      return null;
    }
  }

  /// FR-01: sign in, then read the role from Firestore.
  Future<AppUser> signIn(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return await _loadProfile(cred.user!);
    } on FirebaseAuthException catch (e) {
      throw _mapAuthError(e);
    } on AuthException catch (e) {
      if (e.type == AuthErrorType.noRole) await _auth.signOut();
      rethrow;
    }
  }

  Future<void> signOut() => _auth.signOut();

  Future<AppUser> _loadProfile(User firebaseUser) async {
    try {
      final doc = await _db.collection('users').doc(firebaseUser.uid).get();
      final data = doc.data();
      final user = data == null
          ? null
          : AppUser.fromMap(firebaseUser.uid, data,
          fallbackEmail: firebaseUser.email);
      if (user == null) {
        throw const AuthException(
          AuthErrorType.noRole,
          'This account has no role assigned. Please contact your tutor.',
        );
      }
      return user;
    } on FirebaseException catch (e) {
      if (e.code == 'unavailable') throw _offline;
      throw const AuthException(
        AuthErrorType.other,
        'Something went wrong. Please try again.',
      );
    }
  }

  static const _offline = AuthException(
    AuthErrorType.offline,
    'No internet connection. Check your connection and try again.',
  );

  AuthException _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-credential':
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-email':
        return const AuthException(
          AuthErrorType.invalidCredentials,
          'Invalid email or password.',
        );
      case 'network-request-failed':
        return _offline;
      case 'too-many-requests':
        return const AuthException(
          AuthErrorType.other,
          'Too many attempts. Please try again later.',
        );
      case 'user-disabled':
        return const AuthException(
          AuthErrorType.other,
          'This account has been disabled. Please contact your tutor.',
        );
      default:
        return const AuthException(
          AuthErrorType.other,
          'Something went wrong. Please try again.',
        );
    }
  }
}