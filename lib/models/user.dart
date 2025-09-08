class User {
  final String id;
  final String email;
  final String password;
  final String role; // Admin, Manager, Employee
  final String name;
  final DateTime createdAt;
  final bool isActive;

  User({
    required this.id,
    required this.email,
    required this.password,
    required this.role,
    required this.name,
    required this.createdAt,
    this.isActive = true,
  });
}