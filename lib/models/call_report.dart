class CallReport {
  final int totalCalls;
  final int convertedCalls;
  final int notLiftedCalls;
  final int followUpsScheduled;
  final double conversionRate;
  final List<FollowUp> followUps;

  CallReport({
    required this.totalCalls,
    required this.convertedCalls,
    required this.notLiftedCalls,
    required this.followUpsScheduled,
    required this.conversionRate,
    required this.followUps,
  });
}

class FollowUp {
  final String contactId;
  final String contactName;
  final DateTime followUpDate;
  final String assignedEmployee;
  final String notes;

  FollowUp({
    required this.contactId,
    required this.contactName,
    required this.followUpDate,
    required this.assignedEmployee,
    required this.notes,
  });
}