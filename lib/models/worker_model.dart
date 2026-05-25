class WorkerModel {
  final int? id;
  final String name;
  final String? phone;
  final String role; // 'admin', 'barber', 'receptionist'
  final double commissionPercentage;
  final bool isActive;
  final DateTime joinDate;
  final String? notes;
  final String? photoPath;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Stats (not stored in DB, calculated)
  final double? totalEarnings;
  final int? totalCustomers;
  final int? totalServices;

  // Predefined roles
  static const List<String> roles = [
    'Admin',
    'Barber',
    'Receptionist',
  ];

  WorkerModel({
    this.id,
    required this.name,
    this.phone,
    this.role = 'Barber',
    this.commissionPercentage = 0.0,
    this.isActive = true,
    DateTime? joinDate,
    this.notes,
    this.photoPath,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.totalEarnings,
    this.totalCustomers,
    this.totalServices,
  })  : joinDate = joinDate ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'role': role,
      'commission_percentage': commissionPercentage,
      'is_active': isActive ? 1 : 0,
      'join_date': joinDate.toIso8601String(),
      'notes': notes,
      'photo_path': photoPath,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory WorkerModel.fromMap(Map<String, dynamic> map) {
    return WorkerModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      phone: map['phone'] as String?,
      role: map['role'] as String? ?? 'Barber',
      commissionPercentage:
          (map['commission_percentage'] as num?)?.toDouble() ?? 0.0,
      isActive: (map['is_active'] as int?) == 1,
      joinDate: DateTime.parse(map['join_date'] as String),
      notes: map['notes'] as String?,
      photoPath: map['photo_path'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      totalEarnings: (map['total_earnings'] as num?)?.toDouble(),
      totalCustomers: map['total_customers'] as int?,
      totalServices: map['total_services'] as int?,
    );
  }

  WorkerModel copyWith({
    int? id,
    String? name,
    String? phone,
    String? role,
    double? commissionPercentage,
    bool? isActive,
    DateTime? joinDate,
    String? notes,
    String? photoPath,
    DateTime? updatedAt,
    double? totalEarnings,
    int? totalCustomers,
    int? totalServices,
  }) {
    return WorkerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      commissionPercentage: commissionPercentage ?? this.commissionPercentage,
      isActive: isActive ?? this.isActive,
      joinDate: joinDate ?? this.joinDate,
      notes: notes ?? this.notes,
      photoPath: photoPath ?? this.photoPath,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'WorkerModel(id: $id, name: $name, role: $role, commission: $commissionPercentage%, active: $isActive)';
  }
}
