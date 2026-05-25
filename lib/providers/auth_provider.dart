import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _shopData;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get shopData => _shopData;
  bool get isAuthenticated => _user != null;
  String get userId => _user?.uid ?? '';
  String get shopName => _shopData?['shopName'] ?? 'The Barber';
  String get ownerName => _shopData?['ownerName'] ?? '';
  String get shopPhone => _shopData?['phone'] ?? '';
  String get shopEmail => _user?.email ?? '';

  AuthProvider() {
    _user = _authService.getCurrentUser();
    if (_user != null) {
      _loadShopData();
    }
    // Listen to auth state changes
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      _user = user;
      if (user != null) {
        _loadShopData();
      } else {
        _shopData = null;
      }
      notifyListeners();
    });
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String shopName,
    required String ownerName,
    required String phone,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _authService.signUp(
        email: email.trim(),
        password: password,
        shopName: shopName.trim(),
        ownerName: ownerName.trim(),
        phone: phone.trim(),
      );
      if (_user != null) {
        await _loadShopData();
      }
    } on FirebaseAuthException catch (e) {
      _error = _getFirebaseErrorMessage(e.code);
      _user = null;
    } catch (e) {
      _error = 'An unexpected error occurred. Please try again.';
      _user = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> signIn(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _authService.signIn(email.trim(), password);
      if (_user != null) {
        await _loadShopData();
      }
    } on FirebaseAuthException catch (e) {
      _error = _getFirebaseErrorMessage(e.code);
      _user = null;
    } catch (e) {
      _error = 'An unexpected error occurred. Please try again.';
      _user = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    await _authService.signOut();
    _user = null;
    _shopData = null;

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadShopData() async {
    if (_user == null) return;
    try {
      final doc = await _authService.getShopData(_user!.uid);
      if (doc.exists) {
        _shopData = doc.data() as Map<String, dynamic>?;
      }
    } catch (e) {
      _error = 'Failed to load shop data';
    }
    notifyListeners();
  }

  Future<void> updateShopData(Map<String, dynamic> data) async {
    if (_user == null) return;
    try {
      await _authService.updateShopData(_user!.uid, data);
      await _loadShopData();
    } catch (e) {
      _error = 'Failed to update shop data';
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  String _getFirebaseErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      case 'weak-password':
        return 'Password is too weak. Please use at least 6 characters.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}
