class Contact {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String standard;
  final String assignedTo;
  final String status;
  final DateTime createdAt;
  final DateTime? lastCalled;
  final String? outcome; // 'converted', 'not_lifted', 'follow_up'

  Contact({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.standard,
    this.assignedTo = '',
    this.status = 'pending',
    required this.createdAt,
    this.lastCalled,
    this.outcome,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'email': email,
    'standard': standard,
    'assignedTo': assignedTo,
    'status': status,
    'createdAt': createdAt.toIso8601String(),
    'lastCalled': lastCalled?.toIso8601String(),
    'outcome': outcome,
  };

  Map<String, dynamic> toMap() => {
    'name': name,
    'phone': phone,
    'email': email,
    'standard': standard,
    'assignedTo': assignedTo,
    'status': status,
    'createdAt': createdAt,
    'lastCalled': lastCalled,
    'outcome': outcome,
  };

  factory Contact.fromJson(Map<String, dynamic> json) => Contact(
    id: json['_id'] ?? json['id'] ?? '',
    name: json['name'] ?? '',
    phone: json['phone'] ?? '',
    email: json['email'] ?? '',
    standard: json['standard'] ?? '',
    assignedTo: json['assignedTo'] ?? '',
    status: json['status'] ?? 'pending',
    createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    lastCalled: json['lastCalled'] != null ? DateTime.parse(json['lastCalled']) : null,
    outcome: json['outcome'],
  );

  factory Contact.fromMap(Map<String, dynamic> map, String id) => Contact(
    id: id,
    name: map['name'],
    phone: map['phone'],
    email: map['email'],
    standard: map['standard'],
    assignedTo: map['assignedTo'] ?? '',
    status: map['status'] ?? 'pending',
    createdAt: DateTime.parse(map['createdAt']),
    lastCalled: map['lastCalled'] != null ? DateTime.parse(map['lastCalled']) : null,
    outcome: map['outcome'],
  );
}