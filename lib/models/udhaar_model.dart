class UdhaarModel {
  final int? id;
  final int customerId;
  final String? customerName; // For display purposes
  final String? customerPhone; // For display purposes
  final double totalAmount;
  final double paidAmount;
  final DateTime? dueDate;
  final String status; // 'pending', 'partial', 'paid'
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<UdhaarPayment> payments;

  UdhaarModel({
    this.id,
    required this.customerId,
    this.customerName,
    this.customerPhone,
    required this.totalAmount,
    this.paidAmount = 0.0,
    this.dueDate,
    this.status = 'pending',
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<UdhaarPayment>? payments,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now(),
        payments = payments ?? [];

  double get remainingAmount => totalAmount - paidAmount;

  bool get isFullyPaid => remainingAmount <= 0;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customer_id': customerId,
      'total_amount': totalAmount,
      'paid_amount': paidAmount,
      'due_date': dueDate?.toIso8601String(),
      'status': status,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory UdhaarModel.fromMap(Map<String, dynamic> map) {
    return UdhaarModel(
      id: map['id'] as int?,
      customerId: map['customer_id'] as int,
      customerName: map['customer_name'] as String?,
      customerPhone: map['customer_phone'] as String?,
      totalAmount: (map['total_amount'] as num).toDouble(),
      paidAmount: (map['paid_amount'] as num?)?.toDouble() ?? 0.0,
      dueDate: map['due_date'] != null
          ? DateTime.parse(map['due_date'] as String)
          : null,
      status: map['status'] as String? ?? 'pending',
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  UdhaarModel copyWith({
    int? id,
    int? customerId,
    String? customerName,
    String? customerPhone,
    double? totalAmount,
    double? paidAmount,
    DateTime? dueDate,
    String? status,
    String? notes,
    DateTime? updatedAt,
    List<UdhaarPayment>? payments,
  }) {
    return UdhaarModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      totalAmount: totalAmount ?? this.totalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      updatedAt: updatedAt ?? DateTime.now(),
      payments: payments ?? this.payments,
    );
  }

  @override
  String toString() {
    return 'UdhaarModel(id: $id, customerId: $customerId, totalAmount: $totalAmount, paidAmount: $paidAmount, remaining: $remainingAmount, status: $status)';
  }
}

class UdhaarPayment {
  final int? id;
  final int udhaarId;
  final double amount;
  final DateTime paymentDate;
  final String? paymentMethod;
  final String? notes;
  final DateTime createdAt;

  UdhaarPayment({
    this.id,
    required this.udhaarId,
    required this.amount,
    DateTime? paymentDate,
    this.paymentMethod,
    this.notes,
    DateTime? createdAt,
  })  : paymentDate = paymentDate ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'udhaar_id': udhaarId,
      'amount': amount,
      'payment_date': paymentDate.toIso8601String(),
      'payment_method': paymentMethod,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory UdhaarPayment.fromMap(Map<String, dynamic> map) {
    return UdhaarPayment(
      id: map['id'] as int?,
      udhaarId: map['udhaar_id'] as int,
      amount: (map['amount'] as num).toDouble(),
      paymentDate: DateTime.parse(map['payment_date'] as String),
      paymentMethod: map['payment_method'] as String?,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  // ADD THIS METHOD
  UdhaarPayment copyWith({
    int? id,
    int? udhaarId,
    double? amount,
    DateTime? paymentDate,
    String? paymentMethod,
    String? notes,
    DateTime? createdAt,
  }) {
    return UdhaarPayment(
      id: id ?? this.id,
      udhaarId: udhaarId ?? this.udhaarId,
      amount: amount ?? this.amount,
      paymentDate: paymentDate ?? this.paymentDate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'UdhaarPayment(id: $id, udhaarId: $udhaarId, amount: $amount, date: $paymentDate)';
  }
}
