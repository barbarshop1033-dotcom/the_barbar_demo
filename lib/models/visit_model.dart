class VisitModel {
  final int? id;
  final int customerId;
  final String? customerName; // For display
  final String? customerPhone; // For display
  final int? workerId;
  final String? workerName; // For display
  final DateTime visitDate;
  final List<String> services; // Service names
  final List<int> serviceIds; // Service IDs
  final double totalAmount;
  final String paymentStatus; // 'paid', 'unpaid', 'partial'
  final String? paymentMethod;
  final String? notes;
  final DateTime createdAt;

  VisitModel({
    this.id,
    required this.customerId,
    this.customerName,
    this.customerPhone,
    this.workerId,
    this.workerName,
    DateTime? visitDate,
    required this.services,
    required this.serviceIds,
    required this.totalAmount,
    this.paymentStatus = 'paid',
    this.paymentMethod,
    this.notes,
    DateTime? createdAt,
  })  : visitDate = visitDate ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customer_id': customerId,
      'worker_id': workerId,
      'visit_date': visitDate.toIso8601String(),
      'services': services.join(','),
      'service_ids': serviceIds.join(','),
      'total_amount': totalAmount,
      'payment_status': paymentStatus,
      'payment_method': paymentMethod,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory VisitModel.fromMap(Map<String, dynamic> map) {
    final servicesString = map['services'] as String? ?? '';
    final serviceIdsString = map['service_ids'] as String? ?? '';

    return VisitModel(
      id: map['id'] as int?,
      customerId: map['customer_id'] as int,
      customerName: map['customer_name'] as String?,
      customerPhone: map['customer_phone'] as String?,
      workerId: map['worker_id'] as int?,
      workerName: map['worker_name'] as String?,
      visitDate: DateTime.parse(map['visit_date'] as String),
      services: servicesString.isEmpty ? [] : servicesString.split(','),
      serviceIds: serviceIdsString.isEmpty
          ? []
          : serviceIdsString
              .split(',')
              .map((e) => int.parse(e.trim()))
              .toList(),
      totalAmount: (map['total_amount'] as num).toDouble(),
      paymentStatus: map['payment_status'] as String? ?? 'paid',
      paymentMethod: map['payment_method'] as String?,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  VisitModel copyWith({
    int? id,
    int? customerId,
    String? customerName,
    String? customerPhone,
    int? workerId,
    String? workerName,
    DateTime? visitDate,
    List<String>? services,
    List<int>? serviceIds,
    double? totalAmount,
    String? paymentStatus,
    String? paymentMethod,
    String? notes,
  }) {
    return VisitModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      workerId: workerId ?? this.workerId,
      workerName: workerName ?? this.workerName,
      visitDate: visitDate ?? this.visitDate,
      services: services ?? this.services,
      serviceIds: serviceIds ?? this.serviceIds,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      notes: notes ?? this.notes,
    );
  }

  @override
  String toString() {
    return 'VisitModel(id: $id, customer: $customerName, services: ${services.length}, totalAmount: $totalAmount, date: $visitDate)';
  }
}
