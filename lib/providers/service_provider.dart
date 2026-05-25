import 'package:flutter/material.dart';
import '../models/service_model.dart';
import '../services/service_management_service.dart';

class ServiceProvider extends ChangeNotifier {
  final ServiceManagementService _serviceService = ServiceManagementService();

  List<ServiceModel> _services = [];
  List<String> _categories = [];
  bool _isLoading = false;
  String? _error;
  String? _selectedCategory;

  List<ServiceModel> get services {
    if (_selectedCategory == null) return _services;
    return _services.where((s) => s.category == _selectedCategory).toList();
  }

  List<ServiceModel> get allServices => _services;
  List<String> get categories => _categories;
  String? get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadServices() async {
    _isLoading = true;
    notifyListeners();

    try {
      _services = await _serviceService.getAllServices();
      _categories = _services
          .map((s) => s.category)
          .where((c) => c != null)
          .cast<String>()
          .toSet()
          .toList();
      _categories.sort();
    } catch (e) {
      _error = 'Failed to load services';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<ServiceModel?> getServiceById(int id) async {
    try {
      return await _serviceService.getServiceById(id);
    } catch (e) {
      _error = 'Failed to load service';
      notifyListeners();
      return null;
    }
  }

  Future<bool> addService(ServiceModel service) async {
    try {
      final id = await _serviceService.addService(service);
      if (id > 0) {
        final newService = service.copyWith(id: id);
        _services.add(newService);
        if (newService.category != null &&
            !_categories.contains(newService.category)) {
          _categories.add(newService.category!);
          _categories.sort();
        }
        notifyListeners();
        return true;
      }
    } catch (e) {
      _error = 'Failed to add service';
      notifyListeners();
    }
    return false;
  }

  Future<bool> updateService(ServiceModel service) async {
    try {
      final updated = await _serviceService.updateService(service);
      if (updated) {
        final index = _services.indexWhere((s) => s.id == service.id);
        if (index != -1) {
          _services[index] = service;
        }
        notifyListeners();
        return true;
      }
    } catch (e) {
      _error = 'Failed to update service';
      notifyListeners();
    }
    return false;
  }

  Future<bool> deleteService(int id) async {
    try {
      final deleted = await _serviceService.deleteService(id);
      if (deleted) {
        _services.removeWhere((s) => s.id == id);
        _updateCategories();
        notifyListeners();
        return true;
      }
    } catch (e) {
      _error = 'Failed to delete service';
      notifyListeners();
    }
    return false;
  }

  Future<bool> toggleServiceStatus(int id, bool isActive) async {
    try {
      final service = _services.firstWhere((s) => s.id == id);
      final updated = service.copyWith(isActive: isActive);
      return await updateService(updated);
    } catch (e) {
      _error = 'Failed to update service status';
      notifyListeners();
      return false;
    }
  }

  void setSelectedCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void _updateCategories() {
    _categories = _services
        .map((s) => s.category)
        .where((c) => c != null)
        .cast<String>()
        .toSet()
        .toList();
    _categories.sort();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
