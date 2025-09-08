import '../models/student.dart';

class StudentService {
  static List<Student> _students = [];

  Future<List<Student>> getStudents() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.from(_students);
  }

  Future<Student> addStudent(Student student) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final newStudent = Student(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: student.name,
      standard: student.standard,
      mobile: student.mobile,
      address: student.address,
      school: student.school,
      assignedTo: student.assignedTo,
      createdAt: DateTime.now(),
    );
    _students.add(newStudent);
    return newStudent;
  }

  Future<List<Student>> importFromExcel(List<Map<String, dynamic>> data) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final students = <Student>[];
    
    for (final row in data) {
      // Check for duplicates
      final exists = _students.any((s) => s.mobile == row['mobile']);
      if (!exists) {
        final student = Student(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: row['name'] ?? '',
          standard: row['standard'] ?? '',
          mobile: row['mobile'] ?? '',
          address: row['address'] ?? '',
          school: row['school'] ?? '',
          createdAt: DateTime.now(),
        );
        _students.add(student);
        students.add(student);
      }
    }
    return students;
  }

  Future<void> assignStudents(List<String> studentIds, String employeeId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    for (int i = 0; i < _students.length; i++) {
      if (studentIds.contains(_students[i].id)) {
        _students[i] = Student(
          id: _students[i].id,
          name: _students[i].name,
          standard: _students[i].standard,
          mobile: _students[i].mobile,
          address: _students[i].address,
          school: _students[i].school,
          assignedTo: employeeId,
          createdAt: _students[i].createdAt,
        );
      }
    }
  }
}