import 'package:flutter/material.dart';
import '../models/contact.dart';
import '../models/employee.dart';
import '../models/user.dart';
import '../models/student.dart';

import '../services/api_service.dart';
import '../services/user_service.dart';
import '../services/student_service.dart';
import '../services/report_service.dart';
import '../services/auth_service.dart';
import '../services/excel_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:file_picker/file_picker.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final _dataService = DataService();
  final _userService = UserService();
  final _studentService = StudentService();
  List<Contact> _contacts = [];
  List<Employee> _employees = [];
  List<User> _users = [];
  List<Student> _students = [];
  int _selectedIndex = 0;
  String _reportPeriod = 'Daily';
  Set<String> _selectedStudentIds = {};

  @override
  void initState() {
    super.initState();
    _clearExistingEmployees();
    _loadData();
  }

  void _clearExistingEmployees() {
    _employees.removeWhere((emp) => emp.name == 'Jeevan' || emp.name == 'Shridhar');
  }

  Future<void> _loadData() async {
    final contacts = await _dataService.getContacts();
    final employees = await _dataService.getEmployees();
    final users = await _userService.getUsers();
    final students = await _studentService.getStudents();
    setState(() {
      _contacts = contacts;
      _employees = employees;
      _users = users;
      _students = students;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 280,
            color: const Color(0xFF2196F3),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  child: const Row(
                    children: [
                      Icon(Icons.phone_in_talk, color: Colors.white, size: 28),
                      SizedBox(width: 12),
                      Text('CallTrackPro', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: [
                      _buildNavItem(Icons.dashboard, 'Dashboard', 0),
                      _buildNavItem(Icons.people, 'User Management', 1),
                      _buildNavItem(Icons.school, 'Student Data', 2),
                      _buildNavItem(Icons.assignment, 'Assignments', 3),
                      _buildNavItem(Icons.analytics, 'Reports', 4),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Container(
                  height: 80,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
                  ),
                  child: Row(
                    children: [
                      Text(_getPageTitle(), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
                      const Spacer(),
                      const CircleAvatar(backgroundColor: Colors.blue, child: Text('A', style: TextStyle(color: Colors.white))),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: () => _logout(),
                        icon: const Icon(Icons.logout, color: Colors.white, size: 18),
                        label: const Text('Logout', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    color: const Color(0xFFF8F9FA),
                    child: _buildContent(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String title, int index) {
    final isSelected = _selectedIndex == index;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(icon, color: isSelected ? Colors.white : Colors.white70),
        title: Text(title, style: TextStyle(color: isSelected ? Colors.white : Colors.white70, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal)),
        onTap: () => setState(() => _selectedIndex = index),
      ),
    );
  }

  String _getPageTitle() {
    switch (_selectedIndex) {
      case 0: return 'Dashboard';
      case 1: return 'User Management';
      case 2: return 'Student Data';
      case 3: return 'Assignments';
      case 4: return 'Reports';
      default: return 'Dashboard';
    }
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0: return _buildDashboard();
      case 1: return _buildUserManagement();
      case 2: return _buildStudentData();
      case 3: return _buildAssignments();
      case 4: return _buildReports();
      default: return _buildDashboard();
    }
  }

  Widget _buildDashboard() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildStatCard('Total Users', _users.length.toString(), Icons.people, Colors.blue)),
              const SizedBox(width: 20),
              Expanded(child: _buildStatCard('Total Students', _students.length.toString(), Icons.school, Colors.green)),
              const SizedBox(width: 20),
              Expanded(child: _buildStatCard('Active Employees', _employees.length.toString(), Icons.work, Colors.orange)),
              const SizedBox(width: 20),
              Expanded(child: _buildStatCard('Assigned Students', _students.where((s) => s.assignedTo != null).length.toString(), Icons.assignment, Colors.purple)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserManagement() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: [
              const Text('User Management', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _showCreateUserDialog,
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('Create User', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    ),
                    child: const Row(
                      children: [
                        Expanded(flex: 2, child: Text('Name', style: TextStyle(fontWeight: FontWeight.w600))),
                        Expanded(flex: 2, child: Text('Email', style: TextStyle(fontWeight: FontWeight.w600))),
                        Expanded(flex: 1, child: Text('Role', style: TextStyle(fontWeight: FontWeight.w600))),
                        Expanded(flex: 1, child: Text('Actions', style: TextStyle(fontWeight: FontWeight.w600))),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _users.length,
                      itemBuilder: (context, index) {
                        final user = _users[index];
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey[200]!))),
                          child: Row(
                            children: [
                              Expanded(flex: 2, child: Text(user.name)),
                              Expanded(flex: 2, child: Text(user.email)),
                              Expanded(flex: 1, child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getRoleColor(user.role),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(user.role, style: const TextStyle(color: Colors.white, fontSize: 12)),
                              )),
                              Expanded(flex: 1, child: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteUser(user.id),
                              )),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentData() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: [
              const Text('Student Data Management', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _showAddStudentDialog,
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('Add Student', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _showImportDialog,
                icon: const Icon(Icons.upload, color: Colors.white),
                label: const Text('Import Excel', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    ),
                    child: const Row(
                      children: [
                        Expanded(child: Text('Name', style: TextStyle(fontWeight: FontWeight.w600))),
                        Expanded(child: Text('Standard', style: TextStyle(fontWeight: FontWeight.w600))),
                        Expanded(child: Text('Mobile', style: TextStyle(fontWeight: FontWeight.w600))),
                        Expanded(child: Text('School', style: TextStyle(fontWeight: FontWeight.w600))),
                        Expanded(child: Text('Assigned To', style: TextStyle(fontWeight: FontWeight.w600))),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _students.length,
                      itemBuilder: (context, index) {
                        final student = _students[index];
                        final assignedEmployee = _employees.firstWhere(
                          (e) => e.id == student.assignedTo,
                          orElse: () => Employee(id: '', name: 'Unassigned', email: '', role: ''),
                        );
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey[200]!))),
                          child: Row(
                            children: [
                              Expanded(child: Text(student.name)),
                              Expanded(child: Text(student.standard)),
                              Expanded(child: Text(student.mobile)),
                              Expanded(child: Text(student.school)),
                              Expanded(child: Text(assignedEmployee.name)),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignments() {
    var unassignedStudents = _students.where((s) => s.assignedTo == null).toList();
    
    // Sort by standard first, then by school
    unassignedStudents.sort((a, b) {
      final stdComparison = a.standard.compareTo(b.standard);
      if (stdComparison != 0) return stdComparison;
      return a.school.compareTo(b.school);
    });
    
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: [
              const Text('Student Assignments', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const Spacer(),
              if (_selectedStudentIds.isNotEmpty) ...[
                Text('${_selectedStudentIds.length} selected', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _showAssignSelectedDialog,
                  icon: const Icon(Icons.assignment_ind, color: Colors.white),
                  label: const Text('Assign Selected', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => setState(() => _selectedStudentIds.clear()),
                  child: const Text('Clear Selection'),
                ),
              ],
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                          ),
                          child: const Row(
                            children: [
                              Text('Unassigned Students', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              Spacer(),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              if (unassignedStudents.isNotEmpty)
                                CheckboxListTile(
                                  title: const Text('Select All', style: TextStyle(fontWeight: FontWeight.bold)),
                                  value: _selectedStudentIds.length == unassignedStudents.length,
                                  tristate: true,
                                  onChanged: (value) {
                                    setState(() {
                                      if (value == true) {
                                        _selectedStudentIds.addAll(unassignedStudents.map((s) => s.id));
                                      } else {
                                        _selectedStudentIds.clear();
                                      }
                                    });
                                  },
                                ),
                              const Divider(),
                              Expanded(
                                child: ListView.builder(
                                  itemCount: unassignedStudents.length,
                                  itemBuilder: (context, index) {
                                    final student = unassignedStudents[index];
                                    final isSelected = _selectedStudentIds.contains(student.id);
                                    return CheckboxListTile(
                                      title: Text(student.name),
                                      subtitle: Text('Std: ${student.standard} | School: ${student.school}\nMobile: ${student.mobile}'),
                                      value: isSelected,
                                      onChanged: (value) {
                                        setState(() {
                                          if (value == true) {
                                            _selectedStudentIds.add(student.id);
                                          } else {
                                            _selectedStudentIds.remove(student.id);
                                          }
                                        });
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                          ),
                          child: const Row(
                            children: [
                              Text('Employee Workload', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: _employees.length,
                            itemBuilder: (context, index) {
                              final employee = _employees[index];
                              final assignedCount = _students.where((s) => s.assignedTo == employee.id).length;
                              return ListTile(
                                title: Text(employee.name),
                                subtitle: Text('${employee.email} • ${employee.role}'),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: assignedCount > 50 ? Colors.red : Colors.green,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text('$assignedCount students', style: const TextStyle(color: Colors.white, fontSize: 10)),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReports() {
    final report = ReportService.generateReport(_contacts, _employees, _reportPeriod);
    
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: [
              const Text('Call Reports & Analytics', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const Spacer(),
              DropdownButton<String>(
                value: _reportPeriod,
                items: ['Daily', 'Weekly', 'Monthly'].map((period) => DropdownMenuItem(value: period, child: Text(period))).toList(),
                onChanged: (value) => setState(() => _reportPeriod = value!),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildReportCard('Total Calls', report.totalCalls.toString(), Icons.call, Colors.blue)),
              const SizedBox(width: 16),
              Expanded(child: _buildReportCard('Converted', report.convertedCalls.toString(), Icons.check_circle, Colors.green)),
              const SizedBox(width: 16),
              Expanded(child: _buildReportCard('Not Lifted', report.notLiftedCalls.toString(), Icons.call_missed, Colors.red)),
              const SizedBox(width: 16),
              Expanded(child: _buildReportCard('Follow-ups', report.followUpsScheduled.toString(), Icons.schedule, Colors.orange)),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Call Distribution', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        Expanded(
                          child: PieChart(
                            PieChartData(
                              sections: [
                                PieChartSectionData(
                                  value: report.convertedCalls.toDouble(), 
                                  color: Colors.green, 
                                  title: 'Converted',
                                  titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 0, 0, 0)),
                                  titlePositionPercentageOffset: 0.5,
                                ),
                                PieChartSectionData(
                                  value: report.notLiftedCalls.toDouble(), 
                                  color: Colors.red, 
                                  title: 'Not Lifted',
                                  titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                                  titlePositionPercentageOffset: 0.5,
                                ),
                                PieChartSectionData(
                                  value: report.followUpsScheduled.toDouble(), 
                                  color: Colors.orange, 
                                  title: 'Follow-ups',
                                  titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                                  titlePositionPercentageOffset: 0.5,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Conversion Rate: ${report.conversionRate.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        const Text('Employee Performance:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Expanded(
                          child: BarChart(
                            BarChartData(
                              barGroups: _employees.asMap().entries.map((entry) {
                                final empCalls = _contacts.where((c) => c.assignedTo == entry.value.id).length;
                                return BarChartGroupData(
                                  x: entry.key,
                                  barRods: [BarChartRodData(toY: empCalls.toDouble(), color: Colors.blue)],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text('Scheduled Follow-ups:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        ...report.followUps.take(5).map((followUp) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: [
                              Expanded(child: Text(followUp.contactName, style: const TextStyle(fontSize: 12))),
                              Expanded(child: Text(followUp.assignedEmployee, style: const TextStyle(fontSize: 12))),
                              Text('${followUp.followUpDate.day}/${followUp.followUpDate.month}', style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                        )),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
              Icon(icon, color: color, size: 24),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildReportCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          Text(title, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'Admin': return Colors.red;
      case 'Manager': return Colors.blue;
      case 'Employee': return Colors.green;
      default: return Colors.grey;
    }
  }

  void _showCreateUserDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    String selectedRole = 'Employee';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Create New User'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  decoration: const InputDecoration(labelText: 'Role', border: OutlineInputBorder()),
                  items: ['Admin', 'Manager', 'Employee'].map((role) => DropdownMenuItem(value: role, child: Text(role))).toList(),
                  onChanged: (value) => setDialogState(() => selectedRole = value!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty && emailController.text.isNotEmpty && passwordController.text.isNotEmpty) {
                  try {
                    // Create user
                    await _userService.createUser(emailController.text, passwordController.text, selectedRole, nameController.text);
                    
                    // Create employee directly in mock list
                    final newEmployee = Employee(
                      id: 'emp_${DateTime.now().millisecondsSinceEpoch}',
                      name: nameController.text,
                      email: emailController.text,
                      role: selectedRole,
                    );
                    _employees.add(newEmployee);
                    
                    Navigator.pop(context);
                    await _loadData();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User and employee created successfully')));
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                }
              },
              child: const Text('Create User'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteUser(String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: const Text('Are you sure you want to delete this user?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await _userService.deleteUser(userId);
              await _loadData();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User deleted successfully')));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAddStudentDialog() {
    final nameController = TextEditingController();
    final standardController = TextEditingController();
    final mobileController = TextEditingController();
    final addressController = TextEditingController();
    final schoolController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Student'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder())),
              const SizedBox(height: 16),
              TextField(controller: standardController, decoration: const InputDecoration(labelText: 'Standard', border: OutlineInputBorder())),
              const SizedBox(height: 16),
              TextField(controller: mobileController, decoration: const InputDecoration(labelText: 'Mobile No.', border: OutlineInputBorder())),
              const SizedBox(height: 16),
              TextField(controller: addressController, decoration: const InputDecoration(labelText: 'Address', border: OutlineInputBorder())),
              const SizedBox(height: 16),
              TextField(controller: schoolController, decoration: const InputDecoration(labelText: 'School', border: OutlineInputBorder())),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty && mobileController.text.isNotEmpty) {
                await _studentService.addStudent(Student(
                  id: '',
                  name: nameController.text,
                  standard: standardController.text,
                  mobile: mobileController.text,
                  address: addressController.text,
                  school: schoolController.text,
                  createdAt: DateTime.now(),
                ));
                Navigator.pop(context);
                await _loadData();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Student added successfully')));
              }
            },
            child: const Text('Add Student'),
          ),
        ],
      ),
    );
  }

  void _showImportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Student Data'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.upload_file, size: 64, color: Colors.blue),
            SizedBox(height: 16),
            Text('Select Excel/CSV file with columns: Name, Standard, Mobile, Address, School'),
            SizedBox(height: 8),
            Text('Supported formats: .xlsx, .xls, .csv', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _importExcelFile();
            },
            child: const Text('Select File'),
          ),
        ],
      ),
    );
  }

  Future<void> _importExcelFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls', 'csv'],
      );
      
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.bytes != null) {
          final importedStudents = await ExcelService.parseExcelFile(file.bytes!, fileName: file.name);
          print('Parsed ${importedStudents.length} students from ${file.name}');
          
          // Check for duplicates
          final duplicates = <String>[];
          for (final student in importedStudents) {
            if (_students.any((s) => s.mobile == student.mobile)) {
              duplicates.add(student.mobile);
            }
          }
          
          if (duplicates.isNotEmpty) {
            _showDuplicateDialog(duplicates, importedStudents);
          } else {
            for (final student in importedStudents) {
              await _studentService.addStudent(student);
            }
            await _loadData();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${importedStudents.length} students imported successfully')),
            );
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error importing file: $e')),
      );
    }
  }

  void _showDuplicateDialog(List<String> duplicates, List<Student> newStudents) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Duplicate Mobile Numbers Found'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('The following mobile numbers already exist:'),
            const SizedBox(height: 8),
            ...duplicates.map((mobile) => Text('• $mobile', style: const TextStyle(color: Colors.red))),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final uniqueStudents = newStudents.where((s) => !duplicates.contains(s.mobile)).toList();
              for (final student in uniqueStudents) {
                await _studentService.addStudent(student);
              }
              await _loadData();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${uniqueStudents.length} unique students imported')),
              );
            },
            child: const Text('Import Unique Only'),
          ),
        ],
      ),
    );
  }

  void _showAssignSelectedDialog() {
    String? selectedEmployee;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Assign ${_selectedStudentIds.length} Students'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Select employee to assign selected students:'),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Select Employee', border: OutlineInputBorder()),
                items: _employees.map((emp) => DropdownMenuItem(
                  value: emp.id, 
                  child: Text('${emp.name} (${emp.role})')
                )).toList(),
                onChanged: (value) => setDialogState(() => selectedEmployee = value),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: selectedEmployee != null ? () async {
                final assignedCount = _selectedStudentIds.length;
                await _studentService.assignStudents(_selectedStudentIds.toList(), selectedEmployee!);
                setState(() => _selectedStudentIds.clear());
                await _loadData();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Assigned $assignedCount students successfully')),
                );
              } : null,
              child: const Text('Assign'),
            ),
          ],
        ),
      ),
    );
  }



  void _deleteEmployee(Employee employee) {
    final assignedCount = _students.where((s) => s.assignedTo == employee.id).length;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Employee'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete ${employee.name}?'),
            const SizedBox(height: 8),
            if (assignedCount > 0) ...[
              const Text('Warning:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
              Text('This employee has $assignedCount assigned students.'),
              const Text('Students will become unassigned.'),
            ],
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              // Unassign all students from this employee
              final studentsToUnassign = _students.where((s) => s.assignedTo == employee.id).map((s) => s.id).toList();
              if (studentsToUnassign.isNotEmpty) {
                await _studentService.assignStudents(studentsToUnassign, '');
              }
              
              // Delete employee (mock - add actual delete method to DataService)
              _employees.removeWhere((e) => e.id == employee.id);
              
              Navigator.pop(context);
              await _loadData();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${employee.name} deleted successfully')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await AuthService.logout(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}