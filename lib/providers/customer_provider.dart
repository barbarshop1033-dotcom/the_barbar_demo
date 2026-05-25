import 'package:flutter/material.dart';
import '../models/customer_model.dart';
import '../services/customer_service.dart';

class CustomerProvider extends ChangeNotifier {
  final CustomerService _customerService = CustomerService();

  List<CustomerModel> _customers = [];
  List<CustomerModel> _filteredCustomers = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String _sortBy = 'name'; // 'name', 'last_visit', 'total_spent', 'visits'
  bool _sortAscending = true;

  List<CustomerModel> get customers =>
      _filteredCustomers.isEmpty && _searchQuery.isEmpty
          ? _customers
          : _filteredCustomers;
  List<CustomerModel> get allCustomers => _customers;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get totalCustomers => _customers.length;
  int get regularCustomers => _customers.where((c) => c.isRegular).length;
  double get totalRevenue => _customers.fold(0, (sum, c) => sum + c.totalSpent);

  Future<void> loadCustomers() async {
    _isLoading = true;
    notifyListeners();

    try {
      _customers = await _customerService.getAllCustomers();
      _applyFilters();
    } catch (e) {
      _error = 'Failed to load customers';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<CustomerModel?> getCustomerById(int id) async {
    try {
      return await _customerService.getCustomerById(id);
    } catch (e) {
      _error = 'Failed to load customer';
      notifyListeners();
      return null;
    }
  }

  Future<bool> addCustomer(CustomerModel customer) async {
    try {
      final id = await _customerService.addCustomer(customer);
      if (id > 0) {
        final newCustomer = customer.copyWith(id: id);
        _customers.add(newCustomer);
        _applyFilters();
        notifyListeners();
        return true;
      }
    } catch (e) {
      _error = 'Failed to add customer';
      notifyListeners();
    }
    return false;
  }

  Future<bool> updateCustomer(CustomerModel customer) async {
    try {
      final updated = await _customerService.updateCustomer(customer);
      if (updated) {
        final index = _customers.indexWhere((c) => c.id == customer.id);
        if (index != -1) {
          _customers[index] = customer;
        }
        _applyFilters();
        notifyListeners();
        return true;
      }
    } catch (e) {
      _error = 'Failed to update customer';
      notifyListeners();
    }
    return false;
  }

  Future<bool> deleteCustomer(int id) async {
    try {
      final deleted = await _customerService.deleteCustomer(id);
      if (deleted) {
        _customers.removeWhere((c) => c.id == id);
        _applyFilters();
        notifyListeners();
        return true;
      }
    } catch (e) {
      _error = 'Failed to delete customer';
      notifyListeners();
    }
    return false;
  }

  Future<List<CustomerModel>> searchCustomers(String query) async {
    try {
      return await _customerService.searchCustomers(query);
    } catch (e) {
      _error = 'Search failed';
      notifyListeners();
      return [];
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void setSortBy(String sortBy) {
    if (_sortBy == sortBy) {
      _sortAscending = !_sortAscending;
    } else {
      _sortBy = sortBy;
      _sortAscending = true;
    }
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredCustomers = List.from(_customers);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      _filteredCustomers = _filteredCustomers.where((c) {
        return c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            c.phone.contains(_searchQuery);
      }).toList();
    }

    // Apply sorting
    _sortCustomers();
  }

  void _sortCustomers() {
    switch (_sortBy) {
      case 'name':
        _filteredCustomers.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'last_visit':
        _filteredCustomers.sort((a, b) {
          if (a.lastVisitDate == null && b.lastVisitDate == null) return 0;
          if (a.lastVisitDate == null) return 1;
          if (b.lastVisitDate == null) return -1;
          return a.lastVisitDate!.compareTo(b.lastVisitDate!);
        });
        break;
      case 'total_spent':
        _filteredCustomers.sort((a, b) => a.totalSpent.compareTo(b.totalSpent));
        break;
      case 'visits':
        _filteredCustomers.sort((a, b) => a.visitCount.compareTo(b.visitCount));
        break;
    }

    if (!_sortAscending) {
      _filteredCustomers = _filteredCustomers.reversed.toList();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
