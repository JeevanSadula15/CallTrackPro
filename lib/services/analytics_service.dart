import '../models/contact.dart';
import '../models/employee.dart';

class AnalyticsService {
  static Map<String, dynamic> generateDashboardAnalytics(
    List<Contact> contacts,
    List<Employee> employees,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final thisWeek = today.subtract(Duration(days: today.weekday - 1));
    final thisMonth = DateTime(now.year, now.month, 1);

    // Basic stats
    final totalContacts = contacts.length;
    final assignedContacts = contacts.where((c) => c.assignedTo.isNotEmpty).length;
    final unassignedContacts = totalContacts - assignedContacts;
    final activeEmployees = employees.where((e) => e.isActive).length;

    // Call stats
    final callsToday = contacts.where((c) => 
      c.lastCalled != null && 
      c.lastCalled!.isAfter(today)
    ).length;
    
    final callsThisWeek = contacts.where((c) => 
      c.lastCalled != null && 
      c.lastCalled!.isAfter(thisWeek)
    ).length;

    // Status breakdown
    final pendingContacts = contacts.where((c) => c.status == 'pending').length;
    final inProgressContacts = contacts.where((c) => c.status == 'in_progress').length;
    final completedContacts = contacts.where((c) => c.status == 'completed').length;

    // Follow-ups (in_progress contacts)
    final pendingFollowups = inProgressContacts;

    // Completion rate
    final completionRate = totalContacts > 0 
      ? (completedContacts / totalContacts * 100).round() 
      : 0;

    // Standard-wise breakdown
    final standardBreakdown = <String, int>{};
    for (final contact in contacts) {
      standardBreakdown[contact.standard] = 
        (standardBreakdown[contact.standard] ?? 0) + 1;
    }

    // Employee performance
    final employeePerformance = employees.map((emp) {
      final empContacts = contacts.where((c) => c.assignedTo == emp.id).toList();
      final completed = empContacts.where((c) => c.status == 'completed').length;
      final total = empContacts.length;
      final rate = total > 0 ? (completed / total * 100).round() : 0;

      return {
        'id': emp.id,
        'name': emp.name,
        'totalAssigned': total,
        'completed': completed,
        'completionRate': rate,
        'pending': empContacts.where((c) => c.status == 'pending').length,
        'inProgress': empContacts.where((c) => c.status == 'in_progress').length,
      };
    }).toList();

    // Recent activity
    final recentContacts = contacts
      .where((c) => c.createdAt.isAfter(today.subtract(const Duration(days: 7))))
      .length;

    return {
      'totalContacts': totalContacts,
      'assignedContacts': assignedContacts,
      'unassignedContacts': unassignedContacts,
      'activeEmployees': activeEmployees,
      'callsToday': callsToday,
      'callsThisWeek': callsThisWeek,
      'pendingContacts': pendingContacts,
      'inProgressContacts': inProgressContacts,
      'completedContacts': completedContacts,
      'pendingFollowups': pendingFollowups,
      'completionRate': completionRate,
      'standardBreakdown': standardBreakdown,
      'employeePerformance': employeePerformance,
      'recentContacts': recentContacts,
    };
  }

  static Map<String, dynamic> generateDetailedReports(
    List<Contact> contacts,
    List<Employee> employees,
    String period,
    String? employeeId,
  ) {
    final now = DateTime.now();
    DateTime startDate;

    switch (period) {
      case 'Daily':
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case 'Weekly':
        startDate = now.subtract(Duration(days: now.weekday - 1));
        break;
      case 'Monthly':
        startDate = DateTime(now.year, now.month, 1);
        break;
      case 'Quarterly':
        final quarter = ((now.month - 1) ~/ 3) + 1;
        startDate = DateTime(now.year, (quarter - 1) * 3 + 1, 1);
        break;
      default:
        startDate = DateTime(now.year, now.month, 1);
    }

    // Filter contacts by period and employee
    var filteredContacts = contacts.where((c) => 
      c.createdAt.isAfter(startDate) || 
      (c.lastCalled != null && c.lastCalled!.isAfter(startDate))
    ).toList();

    if (employeeId != null && employeeId != 'All Employees') {
      filteredContacts = filteredContacts.where((c) => c.assignedTo == employeeId).toList();
    }

    // Call trends (mock data for chart)
    final callTrends = _generateCallTrends(startDate, now);
    
    // Performance metrics
    final totalCalls = filteredContacts.where((c) => c.lastCalled != null).length;
    final successfulCalls = filteredContacts.where((c) => c.status == 'completed').length;
    final successRate = totalCalls > 0 ? (successfulCalls / totalCalls * 100).round() : 0;

    // Top performers
    final topPerformers = employees.map((emp) {
      final empContacts = filteredContacts.where((c) => c.assignedTo == emp.id).toList();
      final completed = empContacts.where((c) => c.status == 'completed').length;
      return {
        'name': emp.name,
        'completed': completed,
        'total': empContacts.length,
        'rate': empContacts.isNotEmpty ? (completed / empContacts.length * 100).round() : 0,
      };
    }).where((p) => p['total'] != null && (p['total'] as int) > 0).toList()
      ..sort((a, b) => (b['completed'] as int).compareTo(a['completed'] as int));

    return {
      'period': period,
      'startDate': startDate,
      'endDate': now,
      'totalContacts': filteredContacts.length,
      'totalCalls': totalCalls,
      'successfulCalls': successfulCalls,
      'successRate': successRate,
      'callTrends': callTrends,
      'topPerformers': topPerformers.take(5).toList(),
      'employeeBreakdown': _getEmployeeBreakdown(filteredContacts, employees),
    };
  }

  static List<Map<String, dynamic>> _generateCallTrends(DateTime start, DateTime end) {
    final trends = <Map<String, dynamic>>[];
    final days = end.difference(start).inDays;
    
    for (int i = 0; i <= days; i++) {
      final date = start.add(Duration(days: i));
      trends.add({
        'date': date,
        'calls': 10 + (i * 2) + (i % 3 == 0 ? 5 : 0), // Mock trending data
        'completed': 7 + i + (i % 2 == 0 ? 3 : 0),
      });
    }
    
    return trends;
  }

  static List<Map<String, dynamic>> _getEmployeeBreakdown(
    List<Contact> contacts,
    List<Employee> employees,
  ) {
    return employees.map((emp) {
      final empContacts = contacts.where((c) => c.assignedTo == emp.id).toList();
      final completed = empContacts.where((c) => c.status == 'completed').length;
      final pending = empContacts.where((c) => c.status == 'pending').length;
      final inProgress = empContacts.where((c) => c.status == 'in_progress').length;
      
      return {
        'name': emp.name,
        'email': emp.email,
        'total': empContacts.length,
        'completed': completed,
        'pending': pending,
        'inProgress': inProgress,
        'completionRate': empContacts.isNotEmpty 
          ? (completed / empContacts.length * 100).round() 
          : 0,
      };
    }).where((e) => e['total'] != null && (e['total'] as int) > 0).toList();
  }
}