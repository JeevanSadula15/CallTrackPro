class Student {
  final String id;
  final String name;
  final String standard;
  final String mobile;
  final String address;
  final String school;
  final String? assignedTo;
  final DateTime createdAt;

  Student({
    required this.id,
    required this.name,
    required this.standard,
    required this.mobile,
    required this.address,
    required this.school,
    this.assignedTo,
    required this.createdAt,
  });
}