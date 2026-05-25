import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SubscriptionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Check current subscription status
  Future<Map<String, dynamic>> checkSubscription() async {
    final user = _auth.currentUser;
    if (user == null) {
      return {'status': 'no_user'};
    }

    try {
      final doc = await _firestore.collection('shops').doc(user.uid).get();

      if (!doc.exists) {
        return {'status': 'no_shop'};
      }

      final data = doc.data()!;
      final status = data['subscriptionStatus'] as String? ?? 'trial';

      // Check trial expiration
      if (status == 'trial') {
        final trialEnd = (data['trialEndDate'] as Timestamp?)?.toDate();
        if (trialEnd != null && DateTime.now().isAfter(trialEnd)) {
          // Trial has expired
          await _firestore.collection('shops').doc(user.uid).update({
            'subscriptionStatus': 'trial_expired',
          });
          return {
            'status': 'trial_expired',
            'trialStartDate': (data['trialStartDate'] as Timestamp?)?.toDate(),
            'trialEndDate': trialEnd,
          };
        }

        return {
          'status': 'trial',
          'trialStartDate': (data['trialStartDate'] as Timestamp?)?.toDate(),
          'trialEndDate': trialEnd,
          'subscriptionPlan': null,
        };
      }

      // Check active subscription expiration
      if (status == 'active') {
        final planEnd = (data['subscriptionEndDate'] as Timestamp?)?.toDate();
        if (planEnd != null && DateTime.now().isAfter(planEnd)) {
          // Plan has expired
          await _firestore.collection('shops').doc(user.uid).update({
            'subscriptionStatus': 'expired',
          });
          return {
            'status': 'expired',
            'plan': data['subscriptionPlan'],
            'startDate':
                (data['subscriptionStartDate'] as Timestamp?)?.toDate(),
            'endDate': planEnd,
          };
        }

        return {
          'status': 'active',
          'plan': data['subscriptionPlan'],
          'startDate': (data['subscriptionStartDate'] as Timestamp?)?.toDate(),
          'endDate': planEnd,
          'autoRenew': data['autoRenew'] ?? false,
          'paymentMethod': data['paymentMethod'],
          'amountPaid': data['amountPaid'],
        };
      }

      // Return other statuses
      return {
        'status': status,
        'plan': data['subscriptionPlan'],
        'endDate': data['subscriptionEndDate'] != null
            ? (data['subscriptionEndDate'] as Timestamp).toDate()
            : null,
      };
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  // Activate a subscription plan
  Future<void> activatePlan({
    required String plan,
    required String userId,
  }) async {
    final planDurations = {
      'basic': 30,
      'premium': 30,
      'premium_plus': 30,
    };

    final planPrices = {
      'basic': 999,
      'premium': 1999,
      'premium_plus': 3999,
    };

    final startDate = DateTime.now();
    final endDate = startDate.add(Duration(days: planDurations[plan] ?? 30));

    await _firestore.collection('shops').doc(userId).update({
      'subscriptionStatus': 'active',
      'subscriptionPlan': plan,
      'subscriptionStartDate': Timestamp.fromDate(startDate),
      'subscriptionEndDate': Timestamp.fromDate(endDate),
      'amountPaid': planPrices[plan],
      'paymentMethod': 'manual',
      'autoRenew': false,
    });

    // Log subscription activation
    await _firestore.collection('subscription_history').add({
      'userId': userId,
      'plan': plan,
      'amount': planPrices[plan],
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'status': 'active',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Renew subscription
  Future<void> renewPlan({
    required String userId,
    required String plan,
  }) async {
    // Get current subscription end date
    final doc = await _firestore.collection('shops').doc(userId).get();
    final data = doc.data();

    DateTime startDate = DateTime.now();
    if (data != null && data['subscriptionStatus'] == 'active') {
      final currentEnd = (data['subscriptionEndDate'] as Timestamp).toDate();
      if (currentEnd.isAfter(DateTime.now())) {
        startDate = currentEnd;
      }
    }

    final endDate = startDate.add(const Duration(days: 30));
    final planPrices = {
      'basic': 999,
      'premium': 1999,
      'premium_plus': 3999,
    };

    await _firestore.collection('shops').doc(userId).update({
      'subscriptionStatus': 'active',
      'subscriptionPlan': plan,
      'subscriptionStartDate': Timestamp.fromDate(startDate),
      'subscriptionEndDate': Timestamp.fromDate(endDate),
      'amountPaid': planPrices[plan],
    });

    // Log renewal
    await _firestore.collection('subscription_history').add({
      'userId': userId,
      'plan': plan,
      'amount': planPrices[plan],
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'status': 'renewed',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Cancel subscription
  Future<void> cancelSubscription(String userId) async {
    await _firestore.collection('shops').doc(userId).update({
      'subscriptionStatus': 'cancelled',
      'autoRenew': false,
    });
  }

  // Toggle auto-renewal
  Future<void> toggleAutoRenew(String userId, bool autoRenew) async {
    await _firestore.collection('shops').doc(userId).update({
      'autoRenew': autoRenew,
    });
  }

  // Get remaining days
  int getRemainingDays(DateTime endDate) {
    final now = DateTime.now();
    if (now.isAfter(endDate)) return 0;
    return endDate.difference(now).inDays + 1;
  }

  // Check if subscription is valid
  bool isSubscriptionValid(Map<String, dynamic> subscriptionData) {
    final status = subscriptionData['status'] as String? ?? 'trial';

    if (status == 'trial') {
      final trialEnd = subscriptionData['trialEndDate'] as DateTime?;
      return trialEnd != null && DateTime.now().isBefore(trialEnd);
    }

    if (status == 'active') {
      final endDate = subscriptionData['endDate'] as DateTime?;
      return endDate != null && DateTime.now().isBefore(endDate);
    }

    return false;
  }

  // Stream subscription changes
  Stream<DocumentSnapshot<Map<String, dynamic>>> subscriptionStream() {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No user logged in');
    }
    return _firestore.collection('shops').doc(user.uid).snapshots();
  }

  // Get subscription history
  Future<List<Map<String, dynamic>>> getSubscriptionHistory(
      String userId) async {
    final querySnapshot = await _firestore
        .collection('subscription_history')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      return {
        ...data,
        'id': doc.id,
      };
    }).toList();
  }
}
