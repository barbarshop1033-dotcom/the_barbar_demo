class AppConstants {
  static const String appName = 'The Barber';
  static const int trialDays = 7;

  // Subscription Plans
  static const Map<String, Map<String, dynamic>> subscriptionPlans = {
    'basic': {
      'name': 'Basic',
      'price': 999,
      'duration': 30, // days
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

  // Payment Methods
  static const List<String> paymentMethods = [
    'Cash',
    'JazzCash',
    'EasyPaisa',
    'Bank Transfer',
  ];

  // QR Payment Types
  static const Map<String, String> qrPaymentTypes = {
    'jazzcash': 'JazzCash',
    'easypaisa': 'EasyPaisa',
    'bank': 'Bank Account',
  };
}
