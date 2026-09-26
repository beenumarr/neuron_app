class UserModel {
  final String id;
  final String email;
  final String role;
  final String status;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.email,
    this.role = 'patient',
    this.status = 'active',
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'patient',
      status: json['status'] as String? ?? 'active',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'role': role,
        'status': status,
        'created_at': createdAt?.toIso8601String(),
      };
}
