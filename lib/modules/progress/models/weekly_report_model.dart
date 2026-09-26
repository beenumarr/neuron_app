class WeeklyReportModel {
  final String id;
  final String userId;
  final String reportText;
  final DateTime weekStart;
  final DateTime weekEnd;
  final DateTime createdAt;

  WeeklyReportModel({
    required this.id,
    required this.userId,
    required this.reportText,
    required this.weekStart,
    required this.weekEnd,
    required this.createdAt,
  });

  String get formattedDateRange {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final startStr = '${months[weekStart.month - 1]} ${weekStart.day}';
    final endStr = '${months[weekEnd.month - 1]} ${weekEnd.day}, ${weekEnd.year}';
    return '$startStr – $endStr';
  }

  factory WeeklyReportModel.fromJson(Map<String, dynamic> json) {
    return WeeklyReportModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      reportText: json['report_text'] as String? ?? '',
      weekStart: json['week_start'] != null
          ? DateTime.tryParse(json['week_start'].toString()) ?? DateTime.now().subtract(const Duration(days: 7))
          : DateTime.now().subtract(const Duration(days: 7)),
      weekEnd: json['week_end'] != null
          ? DateTime.tryParse(json['week_end'].toString()) ?? DateTime.now()
          : DateTime.now(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'report_text': reportText,
        'week_start': weekStart.toIso8601String(),
        'week_end': weekEnd.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
      };
}
