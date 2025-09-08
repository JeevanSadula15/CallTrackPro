import '../models/call_report.dart';
import '../models/contact.dart';
import '../models/employee.dart';

class ReportService {
  static CallReport generateReport(List<Contact> contacts, List<Employee> employees, String period) {
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
      default:
        startDate = DateTime(now.year, now.month, 1);
    }

    final filteredContacts = contacts.where((c) => 
      c.lastCalled != null && c.lastCalled!.isAfter(startDate)
    ).toList();

    final totalCalls = filteredContacts.length;
    final convertedCalls = filteredContacts.where((c) => c.status == 'completed').length;
    final notLiftedCalls = filteredContacts.where((c) => c.status == 'not_lifted').length;
    
    final followUps = _generateFollowUps(contacts, employees);
    
    return CallReport(
      totalCalls: totalCalls,
      convertedCalls: convertedCalls,
      notLiftedCalls: notLiftedCalls,
      followUpsScheduled: followUps.length,
      conversionRate: totalCalls > 0 ? (convertedCalls / totalCalls * 100) : 0,
      followUps: followUps,
    );
  }

  static List<FollowUp> _generateFollowUps(List<Contact> contacts, List<Employee> employees) {
    return contacts
        .where((c) => c.status == 'follow_up')
        .map((c) {
          final employee = employees.firstWhere(
            (e) => e.id == c.assignedTo,
            orElse: () => Employee(id: '', name: 'Unassigned', email: '', role: ''),
          );
          return FollowUp(
            contactId: c.id,
            contactName: c.name,
            followUpDate: c.lastCalled?.add(const Duration(days: 3)) ?? DateTime.now().add(const Duration(days: 1)),
            assignedEmployee: employee.name,
            notes: 'Follow-up required',
          );
        }).toList();
  }
}