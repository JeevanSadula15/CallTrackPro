import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/contact.dart';
import '../models/employee.dart';

class DataService {
  static const String baseUrl = 'http://localhost:3000/api';

  Future<List<Contact>> getContacts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/contacts'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Contact.fromJson(json)).toList();
      }
    } catch (e) {
      print('Backend not available, using mock data');
    }
    return _mockContacts;
  }

  static final List<Contact> _mockContacts = [];

  Future<Contact> addContact(Contact contact) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/contacts'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(contact.toJson()),
      );
      if (response.statusCode == 201) {
        return Contact.fromJson(json.decode(response.body));
      }
    } catch (e) {
      print('Error adding contact: $e');
    }
    throw Exception('Failed to add contact');
  }

  Future<void> updateContact(Contact contact) async {
    try {
      await http.put(
        Uri.parse('$baseUrl/contacts/${contact.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(contact.toJson()),
      );
    } catch (e) {
      print('Error updating contact: $e');
    }
  }

  Future<void> deleteContact(String contactId) async {
    try {
      await http.delete(Uri.parse('$baseUrl/contacts/$contactId'));
    } catch (e) {
      print('Error deleting contact: $e');
    }
  }

  Future<List<Employee>> getEmployees() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/employees'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Employee.fromJson(json)).toList();
      }
    } catch (e) {
      print('Backend not available, using mock data');
    }
    return _mockEmployees;
  }

  static final List<Employee> _mockEmployees = [];

  Future<Employee> addEmployee(Employee employee) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/employees'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(employee.toJson()),
      );
      if (response.statusCode == 201) {
        return Employee.fromJson(json.decode(response.body));
      }
    } catch (e) {
      print('Error adding employee: $e');
    }
    throw Exception('Failed to add employee');
  }

  Future<Map<String, dynamic>> getReportData() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/reports'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('Error fetching report data: $e');
    }
    return {};
  }
}