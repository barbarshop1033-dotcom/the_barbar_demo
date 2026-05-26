import 'package:flutter/material.dart';

class SubscriptionProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  
  // Always active for demo
  String get status => 'active';
  String? get plan => 'premium';
  DateTime? get endDate => DateTime.now().add(const Duration(days: 365));
  int get remainingDays => 365;
  
  bool get isTrial => false;
  bool get isActive => true;
  bool get isTrialExpired => false;
  bool get isPlanExpired => false;
  bool get isExpired => false;
  bool get hasAccess => true;
  
  Map<String, dynamic>? get planDetails {
    return {
      'name': 'Premium',
      'features': [
        'Customer Management',
        'Udhaar Book',
        'Billing & POS',
        'Staff Management',
        'Reports & Analytics',
        'QR Payments',
        'Unlimited Customers',
        'Priority Support',
      ],
    };
  }
  
  Map<String, Map<String, dynamic>> get availablePlans {
    return {
      'basic': {
        'name': 'Basic',
        'price': 999,
        'duration': '30 days',
        'pricePerMonth': 'Rs 999',
        'features': ['Customer Management', 'Udhaar Book', 'Basic Reports'],
        'color': 0xFF4CAF50,
      },
      'premium': {
        'name': 'Premium',
        'price': 1999,
        'duration': '30 days',
        'pricePerMonth': 'Rs 1,999',
        'features': [
          'Everything in Basic',
          'Advanced Reports',
          'Staff Management',
          'QR Payments',
          'Unlimited Customers',
        ],
        'color': 0xFF2196F3,
      },
      'premium_plus': {
        'name': 'Premium Plus',
        'price': 3999,
        'duration': '30 days',
        'pricePerMonth': 'Rs 3,999',
        'features': [
          'Everything in Premium',
          'Multi-shop Support',
          'API Access',
          'Custom Branding',
          '24/7 Support',
        ],
        'color': 0xFF9C27B0,
      },
    };
  }
  
  Future<void> checkSubscription() async {
    // Do nothing - always active in demo
    notifyListeners();
  }
  
  Future<bool> activatePlan(String plan) async {
    // Simulate activation
    await Future.delayed(const Duration(milliseconds: 500));
    notifyListeners();
    return true;
  }
  
  Future<void> cancelSubscription() async {
    // Do nothing for demo
    notifyListeners();
  }
}