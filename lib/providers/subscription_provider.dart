import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/subscription_service.dart';
import '../models/subscription_model.dart';

class SubscriptionProvider extends ChangeNotifier {
  final SubscriptionService _subscriptionService = SubscriptionService();

  SubscriptionModel? _subscription;
  bool _isLoading = false;
  String? _error;
  Stream<DocumentSnapshot>? _subscriptionStream;

  SubscriptionModel? get subscription => _subscription;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String get status => _subscription?.status ?? 'loading';
  String? get plan => _subscription?.plan;
  DateTime? get trialEndDate => _subscription?.trialEndDate;
  DateTime? get subscriptionEndDate => _subscription?.subscriptionEndDate;
  int get remainingDays => _subscription?.remainingDays ?? 0;

  // FIXED: Added unified endDate getter
  DateTime? get endDate {
    if (isTrial) return trialEndDate;
    if (isActive) return subscriptionEndDate;
    return null;
  }

  // FIXED: Added startDate getter for consistency
  DateTime? get startDate {
    if (isTrial) return _subscription?.trialStartDate;
    if (isActive) return _subscription?.subscriptionStartDate;
    return null;
  }

  bool get isTrial => status == 'trial';
  bool get isActive => status == 'active';
  bool get isTrialExpired => status == 'trial_expired';
  bool get isPlanExpired => status == 'expired';
  bool get isExpired => isTrialExpired || isPlanExpired;
  bool get hasAccess => isTrial || isActive;

  Map<String, dynamic>? get planDetails => _subscription?.planDetails;

  // Available plans for display
  Map<String, Map<String, dynamic>> get availablePlans {
    return {
      'basic': {
        'name': 'Basic',
        'price': 999,
        'duration': '30 days',
        'pricePerMonth': 'Rs 999',
        'features': [
          'Customer Management',
          'Udhaar Book',
          'Basic Reports',
          'Up to 500 Customers',
          'Email Support',
        ],
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
          'Priority Support',
          'Data Export',
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
          'Advanced Analytics',
          'White Label Option',
        ],
        'color': 0xFF9C27B0,
      },
    };
  }

  SubscriptionProvider() {
    _setupSubscriptionListener();
  }

  void _setupSubscriptionListener() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _subscriptionStream = _subscriptionService.subscriptionStream();
    _subscriptionStream?.listen((doc) {
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        _subscription = SubscriptionModel.fromFirestore(data);

        // Auto-check for expiration
        if (_subscription!.isInTrial || _subscription!.isActive) {
          _checkExpiration();
        }

        notifyListeners();
      }
    });
  }

  Future<void> checkSubscription() async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _subscriptionService.checkSubscription();
      _subscription = SubscriptionModel.fromFirestore(result);
    } catch (e) {
      _error = 'Failed to check subscription status';
      _subscription = SubscriptionModel(status: 'error');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> activatePlan(String plan) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await _subscriptionService.activatePlan(
          plan: plan,
          userId: user.uid,
        );
        await checkSubscription();
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _error = 'No user logged in';
    } catch (e) {
      _error = 'Failed to activate plan. Please try again.';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> cancelSubscription() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('shops')
          .doc(user.uid)
          .update({
        'subscriptionStatus': 'cancelled',
      });
      await checkSubscription();
    } catch (e) {
      _error = 'Failed to cancel subscription';
      notifyListeners();
    }
  }

  void _checkExpiration() {
    if (_subscription == null) return;

    if (_subscription!.status == 'trial' && !_subscription!.isInTrial) {
      _updateStatus('trial_expired');
    } else if (_subscription!.status == 'active' && !_subscription!.isActive) {
      _updateStatus('expired');
    }
  }

  Future<void> _updateStatus(String newStatus) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('shops').doc(user.uid).update({
      'subscriptionStatus': newStatus,
    });
  }

  @override
  void dispose() {
    _subscriptionStream = null;
    super.dispose();
  }
}
