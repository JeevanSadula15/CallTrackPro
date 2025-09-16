import '../models/user.dart';

class UserService {
  static List<User> _users = [
    User(
      id: 'admin_001',
      email: 'admin@callTrackPro.com',
      password: 'admin',
      role: 'Admin',
      name: 'Admin User',
      createdAt: DateTime.now(),
    ),
  ];

  Future<List<User>> getUsers() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.from(_users);
  }

  Future<User> createUser(String email, String password, String role, String name) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final newUser = User(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      password: password,
      role: role,
      name: name,
      createdAt: DateTime.now(),
    );
    _users.add(newUser);
    return newUser;
  }

  Future<void> deleteUser(String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _users.removeWhere((user) => user.id == userId);
  }

  Future<User?> authenticateUser(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      return _users.firstWhere(
        (user) => user.email == email && user.password == password && user.isActive,
      );
    } catch (e) {
      return null;
    }
  }
}