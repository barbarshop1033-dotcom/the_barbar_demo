class ExpenseModel {
  final int? id;
  final String category;
  final double amount;
  final String? description;
  final DateTime expenseDate;
  final String? paymentMethod;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Predefined expense categories
  static const List<String> categories = [
    'Rent',
    'Utilities',
    'Products',
    'Equipment',
    'Salary',
    'Marketing',
    'Maintenance',
    'Other',
  ];

  ExpenseModel({
    this.id,
    required this.category,
    required this.amount,
    this.description,
    DateTime? expenseDate,
    this.paymentMethod,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : expenseDate = expenseDate ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'amount': amount,
      'description': description,
      'expense_date': expenseDate.toIso8601String(),
      'payment_method': paymentMethod,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt!.toIso8601String(),
    };
  }

  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      id: map['id'] as int?,
      category: map['category'] as String,
      amount: (map['amount'] as num).toDouble(),
      description: map['description'] as String?,
      expenseDate: DateTime.parse(map['expense_date'] as String),
      paymentMethod: map['payment_method'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }

  ExpenseModel copyWith({
    int? id,
    String? category,
    double? amount,
    String? description,
    DateTime? expenseDate,
    String? paymentMethod,
    DateTime? updatedAt,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      expenseDate: expenseDate ?? this.expenseDate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'ExpenseModel(id: $id, category: $category, amount: $amount, date: $expenseDate)';
  }
}
