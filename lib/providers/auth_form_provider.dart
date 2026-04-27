import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class AuthFormProvider extends ChangeNotifier {
  bool _isLogin = true;
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLogin => _isLogin;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void toggleMode() {
    _isLogin = !_isLogin;
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> submit({
    required AuthService authService,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      if (_isLogin) {
        await authService.signIn(email: email, password: password);
      } else {
        await authService.register(email: email, password: password);
      }
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _friendlyError(e);
      return false;
    } catch (_) {
      _errorMessage = 'Something went wrong. Please try again.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _friendlyError(FirebaseAuthException exception) {
    switch (exception.code) {
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password should be at least 6 characters.';
      default:
        return exception.message ?? 'Authentication failed.';
    }
  }
}
