import 'package:flutter/material.dart';
import '../models/udhaar_model.dart';
import '../services/udhaar_service.dart';

class UdhaarProvider extends ChangeNotifier {
  final UdhaarService _udhaarService = UdhaarService();

  List<UdhaarModel> _udhaarEntries = [];
  List<UdhaarModel> _filteredEntries = [];
  bool _isLoading = false;
  String? _error;
  String _statusFilter = 'all'; // 'all', 'pending', 'partial', 'paid'
  String _searchQuery = '';

  List<UdhaarModel> get udhaarEntries =>
      _filteredEntries.isEmpty && _searchQuery.isEmpty && _statusFilter == 'all'
          ? _udhaarEntries
          : _filteredEntries;
  List<UdhaarModel> get allUdhaarEntries => _udhaarEntries;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // FIXED: Added public getter for statusFilter
  String get statusFilter => _statusFilter;

  double get totalUdhaar =>
      _udhaarEntries.fold(0, (sum, u) => sum + u.totalAmount);
  double get totalPaid =>
      _udhaarEntries.fold(0, (sum, u) => sum + u.paidAmount);
  double get totalRemaining =>
      _udhaarEntries.fold(0, (sum, u) => sum + u.remainingAmount);
  int get pendingCount =>
      _udhaarEntries.where((u) => u.status != 'paid').length;

  Future<void> loadUdhaarEntries() async {
    _isLoading = true;
    notifyListeners();

    try {
      _udhaarEntries = await _udhaarService.getAllUdhaar();
      _applyFilters();
    } catch (e) {
      _error = 'Failed to load udhaar entries';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<UdhaarModel?> getUdhaarById(int id) async {
    try {
      final udhaar = await _udhaarService.getUdhaarById(id);
      if (udhaar != null) {
        final payments = await _udhaarService.getUdhaarPayments(id);
        return udhaar.copyWith(payments: payments);
      }
      return null;
    } catch (e) {
      _error = 'Failed to load udhaar entry';
      notifyListeners();
      return null;
    }
  }

  Future<bool> addUdhaar(UdhaarModel udhaar) async {
    try {
      final id = await _udhaarService.addUdhaar(udhaar);
      if (id > 0) {
        final newUdhaar = udhaar.copyWith(id: id);
        _udhaarEntries.add(newUdhaar);
        _applyFilters();
        notifyListeners();
        return true;
      }
    } catch (e) {
      _error = 'Failed to add udhaar entry';
      notifyListeners();
    }
    return false;
  }

  Future<bool> updateUdhaar(UdhaarModel udhaar) async {
    try {
      final updated = await _udhaarService.updateUdhaar(udhaar);
      if (updated) {
        final index = _udhaarEntries.indexWhere((u) => u.id == udhaar.id);
        if (index != -1) {
          _udhaarEntries[index] = udhaar;
        }
        _applyFilters();
        notifyListeners();
        return true;
      }
    } catch (e) {
      _error = 'Failed to update udhaar entry';
      notifyListeners();
    }
    return false;
  }

  Future<bool> deleteUdhaar(int id) async {
    try {
      final deleted = await _udhaarService.deleteUdhaar(id);
      if (deleted) {
        _udhaarEntries.removeWhere((u) => u.id == id);
        _applyFilters();
        notifyListeners();
        return true;
      }
    } catch (e) {
      _error = 'Failed to delete udhaar entry';
      notifyListeners();
    }
    return false;
  }

  Future<bool> addPayment(UdhaarPayment payment) async {
    try {
      final id = await _udhaarService.addPayment(payment);
      if (id > 0) {
        final udhaar =
            _udhaarEntries.firstWhere((u) => u.id == payment.udhaarId);
        final newPaidAmount = udhaar.paidAmount + payment.amount;
        String newStatus = 'pending';
        if (newPaidAmount >= udhaar.totalAmount) {
          newStatus = 'paid';
        } else if (newPaidAmount > 0) {
          newStatus = 'partial';
        }

        final updatedUdhaar = udhaar.copyWith(
          paidAmount: newPaidAmount,
          status: newStatus,
          payments: [...udhaar.payments, payment.copyWith(id: id)],
        );

        return await updateUdhaar(updatedUdhaar);
      }
    } catch (e) {
      _error = 'Failed to add payment';
      notifyListeners();
    }
    return false;
  }

  Future<List<UdhaarModel>> getCustomerUdhaar(int customerId) async {
    try {
      return await _udhaarService.getCustomerUdhaar(customerId);
    } catch (e) {
      _error = 'Failed to load customer udhaar';
      notifyListeners();
      return [];
    }
  }

  void setStatusFilter(String status) {
    _statusFilter = status;
    _applyFilters();
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredEntries = List.from(_udhaarEntries);

    // Apply status filter
    if (_statusFilter != 'all') {
      _filteredEntries =
          _filteredEntries.where((u) => u.status == _statusFilter).toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      _filteredEntries = _filteredEntries.where((u) {
        return (u.customerName
                    ?.toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ??
                false) ||
            (u.customerPhone?.contains(_searchQuery) ?? false);
      }).toList();
    }

    // Sort by date (newest first)
    _filteredEntries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
