import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/student.dart';


class FirebaseService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Add Student
  Future<void> addStudent(Student student) async {
    final callable = _functions.httpsCallable('addStudent');
    await callable.call({
      'name': student.name,
      'standard': student.standard,
      'mobile': student.mobile,
      'address': student.address,
      'school': student.school,
    });
  }

  // Get Students
  Future<List<Student>> getStudents() async {
    final callable = _functions.httpsCallable('getStudents');
    final result = await callable.call();
    
    return (result.data as List).map((data) => Student(
      id: data['_id'],
      name: data['name'],
      standard: data['standard'],
      mobile: data['mobile'],
      address: data['address'],
      school: data['school'],
      assignedTo: data['assignedTo'],
      createdAt: DateTime.parse(data['createdAt']),
    )).toList();
  }

  // Assign Students
  Future<void> assignStudents(List<String> studentIds, String employeeId) async {
    final callable = _functions.httpsCallable('assignStudents');
    await callable.call({
      'studentIds': studentIds,
      'employeeId': employeeId,
    });
  }

  // Authentication
  Future<User?> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  Future<User?> createUser(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } catch (e) {
      throw Exception('User creation failed: $e');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  User? get currentUser => _auth.currentUser;
}