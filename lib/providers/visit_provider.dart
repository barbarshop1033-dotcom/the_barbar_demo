import 'package:flutter/material.dart';
import '../models/visit_model.dart';
import '../services/visit_service.dart';

class VisitProvider extends ChangeNotifier {
  final VisitService _visitService = VisitService();

  List<VisitModel> _visits = [];
  bool _isLoading = false;
  String? _error;
  DateTime? _filterDate;

  List<VisitModel> get visits {
    if (_filterDate == null) return _visits;
    return _visits.where((v) {
      return v.visitDate.year == _filterDate!.year &&
          v.visitDate.month == _filterDate!.month &&
          v.visitDate.day == _filterDate!.day;
    }).toList();
  }

  List<VisitModel> get allVisits => _visits;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get filterDate => _filterDate;

  List<VisitModel> get todayVisits {
    final now = DateTime.now();
    return _visits.where((v) {
      return v.visitDate.year == now.year &&
          v.visitDate.month == now.month &&
          v.visitDate.day == now.day;
    }).toList();
  }

  Future<void> loadVisits() async {
    _isLoading = true;
    notifyListeners();

    try {
      _visits = await _visitService.getAllVisits();
    } catch (e) {
      _error = 'Failed to load visits';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<VisitModel?> getVisitById(int id) async {
    try {
      return await _visitService.getVisitById(id);
    } catch (e) {
      _error = 'Failed to load visit';
      notifyListeners();
      return null;
    }
  }

  Future<List<VisitModel>> getCustomerVisits(int customerId) async {
    try {
      return await _visitService.getCustomerVisits(customerId);
    } catch (e) {
      _error = 'Failed to load customer visits';
      notifyListeners();
      return [];
    }
  }

  Future<List<VisitModel>> getWorkerVisits(int workerId) async {
    try {
      return await _visitService.getWorkerVisits(workerId);
    } catch (e) {
      _error = 'Failed to load worker visits';
      notifyListeners();
      return [];
    }
  }

  Future<bool> addVisit(VisitModel visit) async {
    try {
      final id = await _visitService.addVisit(visit);
      if (id > 0) {
        _visits.add(visit.copyWith(id: id));
        notifyListeners();
        return true;
      }
    } catch (e) {
      _error = 'Failed to add visit';
      notifyListeners();
    }
    return false;
  }

  Future<bool> updateVisit(VisitModel visit) async {
    try {
      final updated = await _visitService.updateVisit(visit);
      if (updated) {
        final index = _visits.indexWhere((v) => v.id == visit.id);
        if (index != -1) {
          _visits[index] = visit;
        }
        notifyListeners();
        return true;
      }
    } catch (e) {
      _error = 'Failed to update visit';
      notifyListeners();
    }
    return false;
  }

  Future<bool> deleteVisit(int id) async {
    try {
      final deleted = await _visitService.deleteVisit(id);
      if (deleted) {
        _visits.removeWhere((v) => v.id == id);
        notifyListeners();
        return true;
      }
    } catch (e) {
      _error = 'Failed to delete visit';
      notifyListeners();
    }
    return false;
  }

  void setFilterDate(DateTime? date) {
    _filterDate = date;
    notifyListeners();
  }

  void clearFilter() {
    _filterDate = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
