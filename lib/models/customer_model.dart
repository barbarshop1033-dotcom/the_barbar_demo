class CustomerModel {
  final int? id;
  final String name;
  final String phone;
  final String? photoPath;
  final String? notes;
  final String? favoriteHairstyle;
  final String? preferredWorker;
  final bool isRegular;
  final String? allergyNotes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double totalSpent;
  final DateTime? lastVisitDate;
  final int visitCount;

  CustomerModel({
    this.id,
    required this.name,
    required this.phone,
    this.photoPath,
    this.notes,
    this.favoriteHairstyle,
    this.preferredWorker,
    this.isRegular = false,
    this.allergyNotes,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.totalSpent = 0.0,
    this.lastVisitDate,
    this.visitCount = 0,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'photo_path': photoPath,
      'notes': notes,
      'favorite_hairstyle': favoriteHairstyle,
      'preferred_worker': preferredWorker,
      'is_regular': isRegular ? 1 : 0,
      'allergy_notes': allergyNotes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'total_spent': totalSpent,
      'last_visit_date': lastVisitDate?.toIso8601String(),
      'visit_count': visitCount,
    };
  }

  factory CustomerModel.fromMap(Map<String, dynamic> map) {
    return CustomerModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      phone: map['phone'] as String,
      photoPath: map['photo_path'] as String?,
      notes: map['notes'] as String?,
      favoriteHairstyle: map['favorite_hairstyle'] as String?,
      preferredWorker: map['preferred_worker'] as String?,
      isRegular: (map['is_regular'] as int?) == 1,
      allergyNotes: map['allergy_notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      totalSpent: (map['total_spent'] as num?)?.toDouble() ?? 0.0,
      lastVisitDate: map['last_visit_date'] != null
          ? DateTime.parse(map['last_visit_date'] as String)
          : null,
      visitCount: (map['visit_count'] as int?) ?? 0,
    );
  }

  CustomerModel copyWith({
    int? id,
    String? name,
    String? phone,
    String? photoPath,
    String? notes,
    String? favoriteHairstyle,
    String? preferredWorker,
    bool? isRegular,
    String? allergyNotes,
    double? totalSpent,
    DateTime? lastVisitDate,
    int? visitCount,
    DateTime? updatedAt,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      photoPath: photoPath ?? this.photoPath,
      notes: notes ?? this.notes,
      favoriteHairstyle: favoriteHairstyle ?? this.favoriteHairstyle,
      preferredWorker: preferredWorker ?? this.preferredWorker,
      isRegular: isRegular ?? this.isRegular,
      allergyNotes: allergyNotes ?? this.allergyNotes,
      totalSpent: totalSpent ?? this.totalSpent,
      lastVisitDate: lastVisitDate ?? this.lastVisitDate,
      visitCount: visitCount ?? this.visitCount,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'CustomerModel(id: $id, name: $name, phone: $phone, totalSpent: $totalSpent, isRegular: $isRegular, visitCount: $visitCount)';
  }
}
