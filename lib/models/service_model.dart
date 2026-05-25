class ServiceModel {
  final int? id;
  final String name;
  final double price;
  final int duration; // in minutes
  final String? category;
  final bool isActive;
  final bool isCustom; // To identify user-created services
  final DateTime createdAt;
  final DateTime updatedAt;

  ServiceModel({
    this.id,
    required this.name,
    required this.price,
    required this.duration,
    this.category,
    this.isActive = true,
    this.isCustom = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'duration': duration,
      'category': category,
      'is_active': isActive ? 1 : 0,
      'is_custom': isCustom ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory ServiceModel.fromMap(Map<String, dynamic> map) {
    return ServiceModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      price: (map['price'] as num).toDouble(),
      duration: map['duration'] as int,
      category: map['category'] as String?,
      isActive: (map['is_active'] as int?) == 1,
      isCustom: (map['is_custom'] as int?) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  ServiceModel copyWith({
    int? id,
    String? name,
    double? price,
    int? duration,
    String? category,
    bool? isActive,
    bool? isCustom,
    DateTime? updatedAt,
  }) {
    return ServiceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      duration: duration ?? this.duration,
      category: category ?? this.category,
      isActive: isActive ?? this.isActive,
      isCustom: isCustom ?? this.isCustom,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'ServiceModel(id: $id, name: $name, price: $price, duration: ${duration}min, category: $category, isActive: $isActive)';
  }
}
