import '../models/contact.dart';
import '../models/employee.dart';
import 'dart:math';

class DataService {
  static List<Contact> _contacts = [
    Contact(
      id: '1',
      name: 'John Smith',
      phone: '+91 9876543210',
      email: 'john.smith@example.com',
      standard: '9th',
      status: 'pending',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Contact(
      id: '2',
      name: 'Sarah Johnson',
      phone: '+91 9876543211',
      email: 'sarah.johnson@example.com',
      standard: '10th',
      assignedTo: 'emp123',
      status: 'in_progress',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      lastCalled: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    Contact(
      id: '3',
      name: 'Michael Brown',
      phone: '+91 9876543212',
      email: 'michael.brown@example.com',
      standard: '8th',
      assignedTo: 'emp123',
      status: 'completed',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      lastCalled: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    Contact(
      id: '4',
      name: 'Emily Davis',
      phone: '+91 9876543213',
      email: 'emily.davis@example.com',
      standard: '7th',
      status: 'pending',
      createdAt: DateTime.now().subtract(const Duration(hours: 12)),
    ),
    Contact(
      id: '5',
      name: 'David Wilson',
      phone: '+91 9876543214',
      email: 'david.wilson@example.com',
      standard: '9th',
      assignedTo: 'emp456',
      status: 'in_progress',
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      lastCalled: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
    Contact(
      id: '6',
      name: 'Lisa Anderson',
      phone: '+91 9876543215',
      email: 'lisa.anderson@example.com',
      standard: '10th',
      assignedTo: 'emp456',
      status: 'completed',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      lastCalled: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    Contact(
      id: '7',
      name: 'Robert Taylor',
      phone: '+91 9876543216',
      email: 'robert.taylor@example.com',
      standard: '6th',
      status: 'pending',
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
    ),
    Contact(
      id: '8',
      name: 'Jennifer Martinez',
      phone: '+91 9876543217',
      email: 'jennifer.martinez@example.com',
      standard: '8th',
      assignedTo: 'emp123',
      status: 'pending',
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
    ),
  ];

  static List<Employee> _employees = [
    Employee(
      id: 'emp123',
      name: 'Sarah Johnson',
      email: 'sarah@calltrack.com',
      role: 'employee',
      isActive: true,
    ),
    Employee(
      id: 'emp456',
      name: 'Mike Chen',
      email: 'mike@calltrack.com',
      role: 'employee',
      isActive: true,
    ),
    Employee(
      id: 'emp789',
      name: 'John Smith',
      email: 'john@calltrack.com',
      role: 'employee',
      isActive: true,
    ),
    Employee(
      id: 'emp101',
      name: 'Lisa Davis',
      email: 'lisa@calltrack.com',
      role: 'employee',
      isActive: true,
    ),
  ];

  Future<List<Contact>> getContacts() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_contacts);
  }

  Future<Contact> addContact(Contact contact) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final newContact = Contact(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: contact.name,
      phone: contact.phone,
      email: contact.email,
      standard: contact.standard,
      assignedTo: contact.assignedTo,
      status: contact.status,
      createdAt: DateTime.now(),
    );
    _contacts.add(newContact);
    return newContact;
  }

  Future<void> updateContact(Contact contact) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _contacts.indexWhere((c) => c.id == contact.id);
    if (index != -1) {
      _contacts[index] = contact;
    }
  }

  Future<void> deleteContact(String contactId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _contacts.removeWhere((c) => c.id == contactId);
  }

  Future<void> assignContacts(List<String> contactIds, String employeeId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    for (int i = 0; i < _contacts.length; i++) {
      if (contactIds.contains(_contacts[i].id)) {
        _contacts[i] = Contact(
          id: _contacts[i].id,
          name: _contacts[i].name,
          phone: _contacts[i].phone,
          email: _contacts[i].email,
          standard: _contacts[i].standard,
          assignedTo: employeeId,
          status: _contacts[i].status,
          createdAt: _contacts[i].createdAt,
          lastCalled: _contacts[i].lastCalled,
        );
      }
    }
  }

  Future<void> updateContactsStatus(List<String> contactIds, String status) async {
    await Future.delayed(const Duration(milliseconds: 500));
    for (int i = 0; i < _contacts.length; i++) {
      if (contactIds.contains(_contacts[i].id)) {
        _contacts[i] = Contact(
          id: _contacts[i].id,
          name: _contacts[i].name,
          phone: _contacts[i].phone,
          email: _contacts[i].email,
          standard: _contacts[i].standard,
          assignedTo: _contacts[i].assignedTo,
          status: status,
          createdAt: _contacts[i].createdAt,
          lastCalled: status == 'completed' ? DateTime.now() : _contacts[i].lastCalled,
        );
      }
    }
  }

  Future<void> makeCall(String contactId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _contacts.indexWhere((c) => c.id == contactId);
    if (index != -1) {
      _contacts[index] = Contact(
        id: _contacts[index].id,
        name: _contacts[index].name,
        phone: _contacts[index].phone,
        email: _contacts[index].email,
        standard: _contacts[index].standard,
        assignedTo: _contacts[index].assignedTo,
        status: 'in_progress',
        createdAt: _contacts[index].createdAt,
        lastCalled: DateTime.now(),
      );
    }
  }

  Future<List<Employee>> getEmployees() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.from(_employees);
  }

  Future<Employee> addEmployee(Employee employee) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final newEmployee = Employee(
      id: 'emp${Random().nextInt(9999)}',
      name: employee.name,
      email: employee.email,
      role: employee.role,
      isActive: true,
    );
    _employees.add(newEmployee);
    return newEmployee;
  }

  Future<void> reassignContacts(String fromEmployee, String toEmployee) async {
    await Future.delayed(const Duration(milliseconds: 500));
    for (int i = 0; i < _contacts.length; i++) {
      if (_contacts[i].assignedTo == fromEmployee) {
        _contacts[i] = Contact(
          id: _contacts[i].id,
          name: _contacts[i].name,
          phone: _contacts[i].phone,
          email: _contacts[i].email,
          standard: _contacts[i].standard,
          assignedTo: toEmployee,
          status: _contacts[i].status,
          createdAt: _contacts[i].createdAt,
          lastCalled: _contacts[i].lastCalled,
        );
      }
    }
  }

  Future<Map<String, dynamic>> getReportData() async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    final totalContacts = _contacts.length;
    final assignedContacts = _contacts.where((c) => c.assignedTo.isNotEmpty).length;
    final completedContacts = _contacts.where((c) => c.status == 'completed').length;
    final pendingContacts = _contacts.where((c) => c.status == 'pending').length;
    
    final employeeStats = _employees.map((emp) {
      final empContacts = _contacts.where((c) => c.assignedTo == emp.id).toList();
      final completed = empContacts.where((c) => c.status == 'completed').length;
      final total = empContacts.length;
      final completionRate = total > 0 ? (completed / total * 100).round() : 0;
      
      return {
        'name': emp.name,
        'totalCalls': total,
        'completedCalls': completed,
        'completionRate': completionRate,
      };
    }).toList();
    
    return {
      'totalContacts': totalContacts,
      'assignedContacts': assignedContacts,
      'completedContacts': completedContacts,
      'pendingContacts': pendingContacts,
      'employeeStats': employeeStats,
    };
  }
}