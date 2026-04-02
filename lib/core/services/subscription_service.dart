import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../models/subscription_model.dart';

class SubscriptionService {
  static final _firestore = FirebaseFirestore.instance;
  late Razorpay _razorpay;

  SubscriptionService() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  // Define on success/error callbacks to be provided by UI
  Function(PaymentSuccessResponse)? onSuccess;
  Function(PaymentFailureResponse)? onError;

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    if (onSuccess != null) onSuccess!(response);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (onError != null) onError!(response);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Handle external wallet if needed
  }

  void openCheckout({
    required int amountInPaise,
    required String name,
    required String description,
    required String contact,
    required String email,
  }) {
    var options = {
      'key': 'rzp_test_YourMockKeyHere', // Replace with real key
      'amount': amountInPaise,
      'name': 'KI Job Portal',
      'description': description,
      'prefill': {
        'contact': contact,
        'email': email,
      },
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      // Handle Error
    }
  }

  void dispose() {
    _razorpay.clear(); // Removes all listeners
  }

  static Future<SubscriptionModel?> getSubscription(String uid) async {
    final doc = await _firestore.collection('subscriptions').doc(uid).get();
    if (!doc.exists || doc.data() == null) {
      // If no document exists, they are on 'free' tier locally
      return SubscriptionModel(userId: uid);
    }
    return SubscriptionModel.fromMap(doc.data()!);
  }

  static Future<void> updateSubscription(String uid, String tier, int durationDays, int maxApp) async {
    final expiry = DateTime.now().add(Duration(days: durationDays));
    
    await _firestore.collection('subscriptions').doc(uid).set({
      'userId': uid,
      'currentTier': tier,
      'validUntil': Timestamp.fromDate(expiry),
      'maxApplicationsPerDay': maxApp,
      'usedApplicationsToday': 0,
      'lastApplicationDate': Timestamp.fromDate(DateTime.now()),
    }, SetOptions(merge: true));
    
    // Also update users collection for quick checks
    await _firestore.collection('users').doc(uid).update({
      'subscriptionTier': tier,
      'subscriptionValidUntil': Timestamp.fromDate(expiry),
    });
  }

  static Future<bool> deductApplication(String uid) async {
    final sub = await getSubscription(uid);
    if (sub == null || !sub.isActive || !sub.canApplyForJob) return false;

    int newUsed = sub.usedApplicationsToday + 1;
    // reset if new day
    if (sub.lastApplicationDate != null) {
      final now = DateTime.now();
      if (now.day != sub.lastApplicationDate!.day || 
          now.month != sub.lastApplicationDate!.month || 
          now.year != sub.lastApplicationDate!.year) {
        newUsed = 1;
      }
    }

    await _firestore.collection('subscriptions').doc(uid).update({
      'usedApplicationsToday': newUsed,
      'lastApplicationDate': Timestamp.fromDate(DateTime.now()),
    });
    return true;
  }
}
