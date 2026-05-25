import 'package:flutter/material.dart';
import '../models/worker_model.dart';
import '../services/worker_service.dart';

class WorkerProvider extends ChangeNotifier {
  final WorkerService _workerService = WorkerService();

  List<WorkerModel> _workers = [];
  bool _isLoading = false;
  String? _error;

  List<WorkerModel> get workers => _workers;
  List<WorkerModel> get activeWorkers =>
      _workers.where((w) => w.isActive).toList();
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadWorkers() async {
    _isLoading = true;
    notifyListeners();

    try {
      _workers = await _workerService.getAllWorkers();
    } catch (e) {
      _error = 'Failed to load workers';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<WorkerModel?> getWorkerById(int id) async {
    try {
      return await _workerService.getWorkerById(id);
    } catch (e) {
      _error = 'Failed to load worker';
      notifyListeners();
      return null;
    }
  }

  Future<bool> addWorker(WorkerModel worker) async {
    try {
      final id = await _workerService.addWorker(worker);
      if (id > 0) {
        _workers.add(worker.copyWith(id: id));
        notifyListeners();
        return true;
      }
    } catch (e) {
      _error = 'Failed to add worker';
      notifyListeners();
    }
    return false;
  }

  Future<bool> updateWorker(WorkerModel worker) async {
    try {
      final updated = await _workerService.updateWorker(worker);
      if (updated) {
        final index = _workers.indexWhere((w) => w.id == worker.id);
        if (index != -1) {
          _workers[index] = worker;
        }
        notifyListeners();
        return true;
      }
    } catch (e) {
      _error = 'Failed to update worker';
      notifyListeners();
    }
    return false;
  }

  Future<bool> deleteWorker(int id) async {
    try {
      final deleted = await _workerService.deleteWorker(id);
      if (deleted) {
        _workers.removeWhere((w) => w.id == id);
        notifyListeners();
        return true;
      }
    } catch (e) {
      _error = 'Failed to delete worker';
      notifyListeners();
    }
    return false;
  }

  Future<bool> toggleWorkerStatus(int id, bool isActive) async {
    try {
      final worker = _workers.firstWhere((w) => w.id == id);
      final updated = worker.copyWith(isActive: isActive);
      return await updateWorker(updated);
    } catch (e) {
      _error = 'Failed to update worker status';
      notifyListeners();
      return false;
    }
  }

  Future<Map<String, dynamic>> getWorkerStats(int workerId) async {
    try {
      return await _workerService.getWorkerStats(workerId);
    } catch (e) {
      _error = 'Failed to load worker stats';
      notifyListeners();
      return {};
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
