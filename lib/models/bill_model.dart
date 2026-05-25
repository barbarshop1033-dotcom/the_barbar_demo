class BillModel {
  final int? id;
  final int customerId;
  final String? customerName;
  final String? customerPhone;
  final int? workerId;
  final String? workerName;
  final double totalAmount;
  final double discount;
  final double tax;
  final double finalAmount;
  final String paymentMethod;
  final String paymentStatus;
  final String? notes;
  final DateTime createdAt;
  final List<BillItem> items;

  BillModel({
    this.id,
    required this.customerId,
    this.customerName,
    this.customerPhone,
    this.workerId,
    this.workerName,
    required this.totalAmount,
    this.discount = 0.0,
    this.tax = 0.0,
    required this.finalAmount,
    this.paymentMethod = 'Cash',
    this.paymentStatus = 'paid',
    this.notes,
    DateTime? createdAt,
    List<BillItem>? items,
  })  : createdAt = createdAt ?? DateTime.now(),
        items = items ?? [];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customer_id': customerId,
      'worker_id': workerId,
      'total_amount': totalAmount,
      'discount': discount,
      'tax': tax,
      'final_amount': finalAmount,
      'payment_method': paymentMethod,
      'payment_status': paymentStatus,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory BillModel.fromMap(Map<String, dynamic> map) {
    return BillModel(
      id: map['id'] as int?,
      customerId: map['customer_id'] as int,
      customerName: map['customer_name'] as String?,
      customerPhone: map['customer_phone'] as String?,
      workerId: map['worker_id'] as int?,
      workerName: map['worker_name'] as String?,
      totalAmount: (map['total_amount'] as num).toDouble(),
      discount: (map['discount'] as num?)?.toDouble() ?? 0.0,
      tax: (map['tax'] as num?)?.toDouble() ?? 0.0,
      finalAmount: (map['final_amount'] as num).toDouble(),
      paymentMethod: map['payment_method'] as String? ?? 'Cash',
      paymentStatus: map['payment_status'] as String? ?? 'paid',
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  // ADD THIS METHOD
  BillModel copyWith({
    int? id,
    int? customerId,
    String? customerName,
    String? customerPhone,
    int? workerId,
    String? workerName,
    double? totalAmount,
    double? discount,
    double? tax,
    double? finalAmount,
    String? paymentMethod,
    String? paymentStatus,
    String? notes,
    DateTime? createdAt,
    List<BillItem>? items,
  }) {
    return BillModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      workerId: workerId ?? this.workerId,
      workerName: workerName ?? this.workerName,
      totalAmount: totalAmount ?? this.totalAmount,
      discount: discount ?? this.discount,
      tax: tax ?? this.tax,
      finalAmount: finalAmount ?? this.finalAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      items: items ?? this.items,
    );
  }

  @override
  String toString() {
    return 'BillModel(id: $id, customerId: $customerId, totalAmount: $totalAmount, finalAmount: $finalAmount, status: $paymentStatus)';
  }
}

class BillItem {
  final int? id;
  final int billId;
  final int serviceId;
  final String serviceName;
  final double price;
  final int quantity;
  final double total;

  BillItem({
    this.id,
    required this.billId,
    required this.serviceId,
    required this.serviceName,
    required this.price,
    this.quantity = 1,
    required this.total,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bill_id': billId,
      'service_id': serviceId,
      'service_name': serviceName,
      'price': price,
      'quantity': quantity,
      'total': total,
    };
  }

  factory BillItem.fromMap(Map<String, dynamic> map) {
    return BillItem(
      id: map['id'] as int?,
      billId: map['bill_id'] as int,
      serviceId: map['service_id'] as int,
      serviceName: map['service_name'] as String,
      price: (map['price'] as num).toDouble(),
      quantity: (map['quantity'] as int?) ?? 1,
      total: (map['total'] as num).toDouble(),
    );
  }

  // ADD THIS METHOD
  BillItem copyWith({
    int? id,
    int? billId,
    int? serviceId,
    String? serviceName,
    double? price,
    int? quantity,
    double? total,
  }) {
    return BillItem(
      id: id ?? this.id,
      billId: billId ?? this.billId,
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      total: total ?? this.total,
    );
  }
}
