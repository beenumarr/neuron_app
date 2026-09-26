class RiskFlagModel {
  final String id;
  final String title;
  final String severity; // HIGH, MEDIUM, LOW
  final String description;
  final String recommendation;
  final String? action;

  RiskFlagModel({
    required this.id,
    required this.title,
    required this.severity,
    required this.description,
    required this.recommendation,
    this.action,
  });

  factory RiskFlagModel.fromJson(Map<String, dynamic> json) {
    return RiskFlagModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      severity: json['severity'] as String? ?? 'LOW',
      description: json['description'] as String? ?? '',
      recommendation: json['recommendation'] as String? ?? '',
      action: json['action'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'severity': severity,
        'description': description,
        'recommendation': recommendation,
        if (action != null) 'action': action,
      };
}

class RiskAssessmentModel {
  final String id;
  final String userId;
  final int healthScore;
  final List<RiskFlagModel> riskFlags;
  final String assessmentVersion;
  final DateTime? createdAt;

  RiskAssessmentModel({
    required this.id,
    required this.userId,
    required this.healthScore,
    this.riskFlags = const [],
    this.assessmentVersion = 'nrs_v1',
    this.createdAt,
  });

  factory RiskAssessmentModel.fromJson(Map<String, dynamic> json) {
    final flagsList = json['risk_flags'] as List<dynamic>? ?? [];
    return RiskAssessmentModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      healthScore: (json['health_score'] as num?)?.toInt() ?? 85,
      riskFlags: flagsList
          .map((f) => RiskFlagModel.fromJson(f as Map<String, dynamic>))
          .toList(),
      assessmentVersion: json['assessment_version'] as String? ?? 'nrs_v1',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'health_score': healthScore,
        'risk_flags': riskFlags.map((f) => f.toJson()).toList(),
        'assessment_version': assessmentVersion,
        'created_at': createdAt?.toIso8601String(),
      };
}
