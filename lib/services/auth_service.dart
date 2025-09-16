import 'package:flutter/material.dart';
import '../models/user.dart' as AppUser;

class AuthService {
  static String? _currentUserToken;
  static String? _currentUserId;
  static String? _currentUserRole;

  static void setSession(String token, String userId, String role) {
    _currentUserToken = token;
    _currentUserId = userId;
    _currentUserRole = role;
  }

  // Instance methods for compatibility
  Future<AppUser.User?> signIn(String email, String password) async {
    return AuthService._signIn(email, password);
  }

  Future<String> getUserRole() async {
    return AuthService._getUserRole();
  }

  String? get currentUser => AuthService._currentUserId;

  // Static methods
  static Future<AppUser.User?> _signIn(String email, String password) async {
    // Mock authentication
    if (email == 'admin@test.com' && password == 'admin') {
      setSession('mock_token', 'admin_id', 'Admin');
      return AppUser.User(
        id: 'admin_id', 
        email: email, 
        password: password, 
        role: 'Admin', 
        name: 'Admin User',
        createdAt: DateTime.now(),
      );
    }
    return null;
  }

  static Future<String> _getUserRole() async {
    return _currentUserRole ?? 'Employee';
  }

  static Future<void> logout(BuildContext context) async {
    _currentUserToken = null;
    _currentUserId = null;
    _currentUserRole = null;
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  static bool get isLoggedIn => _currentUserToken != null;
  static String? get currentUserId => _currentUserId;
  static String? get currentUserRole => _currentUserRole;
}