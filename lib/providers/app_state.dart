import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/student.dart';
import '../models/employee.dart';

class AppState extends ChangeNotifier {
  List<User> _users = [];
  List<Student> _students = [];
  List<Employee> _employees = [];
  User? _currentUser;

  List<User> get users => _users;
  List<Student> get students => _students;
  List<Employee> get employees => _employees;
  User? get currentUser => _currentUser;

  void setCurrentUser(User user) {
    _currentUser = user;
    notifyListeners();
  }

  void addUser(User user) {
    _users.add(user);
    notifyListeners();
  }

  void removeUser(String userId) {
    _users.removeWhere((user) => user.id == userId);
    notifyListeners();
  }

  void addStudent(Student student) {
    _students.add(student);
    notifyListeners();
  }

  void importStudents(List<Student> students) {
    _students.addAll(students);
    notifyListeners();
  }

  void assignStudents(List<String> studentIds, String employeeId) {
    for (final id in studentIds) {
      final index = _students.indexWhere((s) => s.id == id);
      if (index != -1) {
        _students[index] = Student(
          id: _students[index].id,
          name: _students[index].name,
          standard: _students[index].standard,
          mobile: _students[index].mobile,
          address: _students[index].address,
          school: _students[index].school,
          assignedTo: employeeId,
          createdAt: _students[index].createdAt,
        );
      }
    }
    notifyListeners();
  }

  void loadMockData() {
    _employees = [
      Employee(id: 'emp1', name: 'John Smith', email: 'john@test.com', role: 'Employee'),
      Employee(id: 'emp2', name: 'Sarah Wilson', email: 'sarah@test.com', role: 'Employee'),
      Employee(id: 'emp3', name: 'Mike Johnson', email: 'mike@test.com', role: 'Manager'),
    ];

    _users = [
      User(id: 'admin1', email: 'admin@test.com', password: 'admin', role: 'Admin', name: 'Admin User', createdAt: DateTime.now()),
      User(id: 'emp1', email: 'john@test.com', password: 'password', role: 'Employee', name: 'John Smith', createdAt: DateTime.now()),
      User(id: 'emp2', email: 'sarah@test.com', password: 'password', role: 'Employee', name: 'Sarah Wilson', createdAt: DateTime.now()),
    ];

    _students = [
      Student(id: 'std1', name: 'Alice Brown', standard: '10th', mobile: '9876543210', address: '123 Main St', school: 'ABC School', createdAt: DateTime.now()),
      Student(id: 'std2', name: 'Bob Davis', standard: '9th', mobile: '9876543211', address: '456 Oak Ave', school: 'XYZ School', createdAt: DateTime.now()),
      Student(id: 'std3', name: 'Carol White', standard: '11th', mobile: '9876543212', address: '789 Pine Rd', school: 'DEF School', assignedTo: 'emp1', createdAt: DateTime.now()),
    ];
    notifyListeners();
  }
}