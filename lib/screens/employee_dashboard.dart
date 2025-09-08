import 'package:flutter/material.dart';
import '../models/contact.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class EmployeeDashboard extends StatefulWidget {
  const EmployeeDashboard({super.key});

  @override
  State<EmployeeDashboard> createState() => _EmployeeDashboardState();
}

class _EmployeeDashboardState extends State<EmployeeDashboard> with TickerProviderStateMixin {
  final _dataService = DataService();
  final _authService = AuthService();
  late TabController _tabController;
  List<Contact> _assignedContacts = [];
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadAssignedContacts();
  }

  Future<void> _loadAssignedContacts() async {
    try {
      final contacts = await _dataService.getContacts();
      final currentUserId = _authService.currentUser;
      setState(() {
        _assignedContacts = contacts
            .where((c) => c.assignedTo == currentUserId)
            .toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading contacts: $e')),
      );
    }
  }

  List<Contact> get _filteredContacts {
    switch (_selectedFilter) {
      case 'Pending':
        return _assignedContacts.where((c) => c.status == 'pending').toList();
      case 'In Progress':
        return _assignedContacts.where((c) => c.status == 'in_progress').toList();
      case 'Completed':
        return _assignedContacts.where((c) => c.status == 'completed').toList();
      default:
        return _assignedContacts;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CallTrackPro Employee'),
        backgroundColor: Colors.green[800],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacementNamed(context, '/'),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Dashboard'),
            Tab(icon: Icon(Icons.contacts), text: 'My Contacts'),
            Tab(icon: Icon(Icons.schedule), text: 'Follow-ups'),
            Tab(icon: Icon(Icons.history), text: 'Call History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDashboardTab(),
          _buildContactsTab(),
          _buildFollowUpsTab(),
          _buildHistoryTab(),
        ],
      ),
    );
  }

  Widget _buildDashboardTab() {
    final totalAssigned = _assignedContacts.length;
    final pending = _assignedContacts.where((c) => c.status == 'pending').length;
    final inProgress = _assignedContacts.where((c) => c.status == 'in_progress').length;
    final completed = _assignedContacts.where((c) => c.status == 'completed').length;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard('Total Assigned', totalAssigned.toString(), Icons.assignment, Colors.blue),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard('Pending', pending.toString(), Icons.pending, Colors.orange),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard('In Progress', inProgress.toString(), Icons.phone_in_talk, Colors.purple),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard('Completed', completed.toString(), Icons.check_circle, Colors.green),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Today\'s Priority Calls', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  ...(_assignedContacts.where((c) => c.status == 'pending').take(3).map((contact) => 
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.orange,
                        child: Text(contact.name[0]),
                      ),
                      title: Text(contact.name),
                      subtitle: Text('${contact.phone} • ${contact.standard}'),
                      trailing: ElevatedButton(
                        onPressed: () => _makeCall(contact),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        child: const Text('Call'),
                      ),
                    )
                  ).toList()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedFilter,
                  decoration: const InputDecoration(
                    labelText: 'Filter by Status',
                    border: OutlineInputBorder(),
                  ),
                  items: ['All', 'Pending', 'In Progress', 'Completed']
                      .map((filter) => DropdownMenuItem(value: filter, child: Text(filter)))
                      .toList(),
                  onChanged: (value) => setState(() => _selectedFilter = value!),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _loadAssignedContacts,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredContacts.length,
              itemBuilder: (context, index) {
                final contact = _filteredContacts[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor: _getStatusColor(contact.status),
                      child: Text(contact.name[0]),
                    ),
                    title: Text(contact.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${contact.phone} • ${contact.email}'),
                        Text('Standard: ${contact.standard}'),
                        Row(
                          children: [
                            _buildStatusChip(contact.status),
                            const SizedBox(width: 8),
                            if (contact.lastCalled != null)
                              Text('Last called: ${_formatDate(contact.lastCalled!)}', 
                                   style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () => _makeCall(contact),
                              icon: const Icon(Icons.call),
                              label: const Text('Call'),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                            ),
                            ElevatedButton.icon(
                              onPressed: () => _sendMessage(contact),
                              icon: const Icon(Icons.message),
                              label: const Text('SMS'),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                            ),
                            ElevatedButton.icon(
                              onPressed: () => _updateStatus(contact),
                              icon: const Icon(Icons.edit),
                              label: const Text('Update'),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFollowUpsTab() {
    final followUpContacts = _assignedContacts.where((c) => c.status == 'follow_up').toList();
    final todayFollowUps = followUpContacts.where((c) => _isToday(c.lastCalled ?? DateTime.now())).toList();
    final upcomingFollowUps = followUpContacts.where((c) => !_isToday(c.lastCalled ?? DateTime.now())).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          if (todayFollowUps.isNotEmpty) ...[
            Card(
              color: Colors.orange[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.today, color: Colors.orange),
                        const SizedBox(width: 8),
                        Text('Today\'s Follow-ups (${todayFollowUps.length})', 
                             style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...todayFollowUps.map((contact) => Card(
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.orange,
                          child: Icon(Icons.schedule, color: Colors.white),
                        ),
                        title: Text(contact.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${contact.phone} • ${contact.standard}'),
                        trailing: ElevatedButton(
                          onPressed: () => _makeCall(contact),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          child: const Text('Call Now'),
                        ),
                      ),
                    )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Upcoming Follow-ups', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Expanded(
                  child: upcomingFollowUps.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.schedule, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text('No upcoming follow-ups', style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: upcomingFollowUps.length,
                          itemBuilder: (context, index) {
                            final contact = upcomingFollowUps[index];
                            return Card(
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.blue,
                                  child: Text(contact.name[0]),
                                ),
                                title: Text(contact.name),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${contact.phone} • ${contact.standard}'),
                                    Text('Scheduled: ${_formatDate(contact.lastCalled ?? DateTime.now())}',
                                         style: const TextStyle(color: Colors.blue)),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      onPressed: () => _makeCall(contact),
                                      icon: const Icon(Icons.call, color: Colors.green),
                                    ),
                                    IconButton(
                                      onPressed: () => _scheduleFollowUp(contact),
                                      icon: const Icon(Icons.edit, color: Colors.orange),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    final calledContacts = _assignedContacts.where((c) => c.lastCalled != null).toList();
    calledContacts.sort((a, b) => b.lastCalled!.compareTo(a.lastCalled!));

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text('Calls Today', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('${calledContacts.where((c) => _isToday(c.lastCalled!)).length}', 
                           style: const TextStyle(fontSize: 24, color: Colors.green)),
                    ],
                  ),
                  Column(
                    children: [
                      const Text('This Week', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('${calledContacts.where((c) => _isThisWeek(c.lastCalled!)).length}', 
                           style: const TextStyle(fontSize: 24, color: Colors.blue)),
                    ],
                  ),
                  Column(
                    children: [
                      const Text('Success Rate', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('${_calculateSuccessRate()}%', 
                           style: const TextStyle(fontSize: 24, color: Colors.purple)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Recent Calls', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: calledContacts.length,
              itemBuilder: (context, index) {
                final contact = calledContacts[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getStatusColor(contact.status),
                      child: const Icon(Icons.call, color: Colors.white),
                    ),
                    title: Text(contact.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(contact.phone),
                        Text('Called: ${_formatDateTime(contact.lastCalled!)}'),
                      ],
                    ),
                    trailing: _buildStatusChip(contact.status),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(title, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    return Chip(
      label: Text(status, style: const TextStyle(color: Colors.white, fontSize: 12)),
      backgroundColor: _getStatusColor(status),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'in_progress':
        return Colors.purple;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _makeCall(Contact contact) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Call Status - ${contact.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Phone: ${contact.phone}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text('Select call outcome:', style: TextStyle(fontSize: 16)),
          ],
        ),
        actions: [
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _updateContactStatus(contact, 'converted');
                      },
                      icon: const Icon(Icons.check_circle, color: Colors.white),
                      label: const Text('Converted', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _updateContactStatus(contact, 'not_lifted');
                      },
                      icon: const Icon(Icons.call_missed, color: Colors.white),
                      label: const Text('Not Lifted', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _scheduleFollowUp(contact);
                      },
                      icon: const Icon(Icons.schedule, color: Colors.white),
                      label: const Text('Follow-up', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _scheduleFollowUp(Contact contact) {
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Schedule Follow-up - ${contact.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Select follow-up date:'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setDialogState(() => selectedDate = date);
                  }
                },
                child: Text('${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _updateContactWithFollowUp(contact, selectedDate);
              },
              child: const Text('Schedule'),
            ),
          ],
        ),
      ),
    );
  }

  void _updateContactWithFollowUp(Contact contact, DateTime followUpDate) {
    setState(() {
      final index = _assignedContacts.indexWhere((c) => c.id == contact.id);
      if (index != -1) {
        _assignedContacts[index] = Contact(
          id: contact.id,
          name: contact.name,
          phone: contact.phone,
          email: contact.email,
          standard: contact.standard,
          assignedTo: contact.assignedTo,
          status: 'follow_up',
          createdAt: contact.createdAt,
          lastCalled: DateTime.now(),
        );
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Follow-up scheduled for ${contact.name} on ${followUpDate.day}/${followUpDate.month}')),
    );
  }

  void _sendMessage(Contact contact) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Send SMS to ${contact.name}'),
        content: const TextField(
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Type your message here...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Message sent successfully')),
              );
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  void _updateStatus(Contact contact) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update ${contact.name} Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Pending'),
              leading: Radio(
                value: 'pending',
                groupValue: contact.status,
                onChanged: (value) {
                  Navigator.pop(context);
                  _updateContactStatus(contact, value!);
                },
              ),
            ),
            ListTile(
              title: const Text('In Progress'),
              leading: Radio(
                value: 'in_progress',
                groupValue: contact.status,
                onChanged: (value) {
                  Navigator.pop(context);
                  _updateContactStatus(contact, value!);
                },
              ),
            ),
            ListTile(
              title: const Text('Completed'),
              leading: Radio(
                value: 'completed',
                groupValue: contact.status,
                onChanged: (value) {
                  Navigator.pop(context);
                  _updateContactStatus(contact, value!);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updateContactStatus(Contact contact, String newStatus) {
    setState(() {
      final index = _assignedContacts.indexWhere((c) => c.id == contact.id);
      if (index != -1) {
        _assignedContacts[index] = Contact(
          id: contact.id,
          name: contact.name,
          phone: contact.phone,
          email: contact.email,
          standard: contact.standard,
          assignedTo: contact.assignedTo,
          status: newStatus,
          createdAt: contact.createdAt,
          lastCalled: DateTime.now(),
        );
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${contact.name} status updated to $newStatus')),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  bool _isThisWeek(DateTime date) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    return date.isAfter(weekStart);
  }

  int _calculateSuccessRate() {
    final calledContacts = _assignedContacts.where((c) => c.lastCalled != null).length;
    final completedContacts = _assignedContacts.where((c) => c.status == 'completed').length;
    if (calledContacts == 0) return 0;
    return ((completedContacts / calledContacts) * 100).round();
  }
}