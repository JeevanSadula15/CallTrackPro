class AnalyticsService {
  static Map<String, dynamic> generateAnalytics() {
    return {
      'totalCalls': 0,
      'completedCalls': 0,
      'conversionRate': 0.0,
    };
  }
}