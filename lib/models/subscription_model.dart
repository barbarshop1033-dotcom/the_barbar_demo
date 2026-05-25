class SubscriptionModel {
  final String
      status; // 'trial', 'active', 'trial_expired', 'expired', 'cancelled'
  final String? plan; // 'basic', 'premium', 'premium_plus'
  final DateTime? trialStartDate;
  final DateTime? trialEndDate;
  final DateTime? subscriptionStartDate;
  final DateTime? subscriptionEndDate;
  final String? paymentMethod;
  final String? transactionId;
  final double? amountPaid;
  final bool autoRenew;

  SubscriptionModel({
    required this.status,
    this.plan,
    this.trialStartDate,
    this.trialEndDate,
    this.subscriptionStartDate,
    this.subscriptionEndDate,
    this.paymentMethod,
    this.transactionId,
    this.amountPaid,
    this.autoRenew = false,
  });

  // Check if currently in trial period
  bool get isInTrial {
    if (status != 'trial' || trialEndDate == null) return false;
    return DateTime.now().isBefore(trialEndDate!);
  }

  // Check if subscription is active
  bool get isActive {
    if (status != 'active' || subscriptionEndDate == null) return false;
    return DateTime.now().isBefore(subscriptionEndDate!);
  }

  // Get remaining days (trial or subscription)
  int get remainingDays {
    DateTime? endDate;
    if (status == 'trial') {
      endDate = trialEndDate;
    } else if (status == 'active') {
      endDate = subscriptionEndDate;
    }

    if (endDate == null) return 0;
    if (DateTime.now().isAfter(endDate)) return 0;
    return endDate.difference(DateTime.now()).inDays + 1;
  }

  // Get plan details
  Map<String, dynamic>? get planDetails {
    if (plan == null) return null;

    final plans = {
      'basic': {
        'name': 'Basic',
        'price': 999,
        'duration': 30,
        'features': [
          'Customer Management',
          'Udhaar Book',
          'Basic Reports',
          'Up to 500 Customers',
        ],
      },
      'premium': {
        'name': 'Premium',
        'price': 1999,
        'duration': 30,
        'features': [
          'Everything in Basic',
          'Advanced Reports',
          'Staff Management',
          'QR Payments',
          'Unlimited Customers',
          'Priority Support',
        ],
      },
      'premium_plus': {
        'name': 'Premium Plus',
        'price': 3999,
        'duration': 30,
        'features': [
          'Everything in Premium',
          'Multi-shop Support',
          'API Access',
          'Custom Branding',
          '24/7 Support',
          'Data Export',
        ],
      },
    };

    return plans[plan];
  }

  factory SubscriptionModel.fromFirestore(Map<String, dynamic> data) {
    return SubscriptionModel(
      status: data['subscriptionStatus'] as String? ?? 'trial',
      plan: data['subscriptionPlan'] as String?,
      trialStartDate: _toDateTime(data['trialStartDate']),
      trialEndDate: _toDateTime(data['trialEndDate']),
      subscriptionStartDate: _toDateTime(data['subscriptionStartDate']),
      subscriptionEndDate: _toDateTime(data['subscriptionEndDate']),
      paymentMethod: data['paymentMethod'] as String?,
      transactionId: data['transactionId'] as String?,
      amountPaid: (data['amountPaid'] as num?)?.toDouble(),
      autoRenew: data['autoRenew'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'subscriptionStatus': status,
      'subscriptionPlan': plan,
      'trialStartDate': trialStartDate,
      'trialEndDate': trialEndDate,
      'subscriptionStartDate': subscriptionStartDate,
      'subscriptionEndDate': subscriptionEndDate,
      'paymentMethod': paymentMethod,
      'transactionId': transactionId,
      'amountPaid': amountPaid,
      'autoRenew': autoRenew,
    };
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    // Handle Firestore Timestamp
    if (value.toString().contains('Timestamp')) {
      return DateTime.fromMillisecondsSinceEpoch(
        (value as dynamic).seconds * 1000,
      );
    }
    return DateTime.tryParse(value.toString());
  }

  @override
  String toString() {
    return 'SubscriptionModel(status: $status, plan: $plan, remainingDays: $remainingDays)';
  }
}
