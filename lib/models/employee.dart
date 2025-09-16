class Employee {
  final String id;
  final String name;
  final String email;
  final String role;
  final bool isActive;

  Employee({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'role': role,
    'isActive': isActive,
  };

  Map<String, dynamic> toMap() => {
    'name': name,
    'email': email,
    'role': role,
    'isActive': isActive,
  };

  factory Employee.fromJson(Map<String, dynamic> json) => Employee(
    id: json['_id'] ?? json['id'] ?? '',
    name: json['name'] ?? '',
    email: json['email'] ?? '',
    role: json['role'] ?? '',
    isActive: json['isActive'] ?? true,
  );

  factory Employee.fromMap(Map<String, dynamic> map, String id) => Employee(
    id: id,
    name: map['name'],
    email: map['email'],
    role: map['role'],
    isActive: map['isActive'] ?? true,
  );
}