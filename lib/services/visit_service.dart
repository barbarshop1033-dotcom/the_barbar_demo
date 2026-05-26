import '../models/visit_model.dart';
import 'database_service.dart';

class VisitService {
  // Get all visits
  Future<List<VisitModel>> getAllVisits() async {
    final visits = await DatabaseService.getAll(DatabaseService.keyVisits);
    final customers = await DatabaseService.getAll(
      DatabaseService.keyCustomers,
    );
    final workers = await DatabaseService.getAll(DatabaseService.keyWorkers);

    final List<VisitModel> result = [];
    for (var v in visits) {
      // Find customer
      Map<String, dynamic> customer = {};
      for (var c in customers) {
        if (c['id'] == v['customer_id']) {
          customer = c;
          break;
        }
      }

      // Find worker
      Map<String, dynamic> worker = {};
      for (var w in workers) {
        if (w['id'] == v['worker_id']) {
          worker = w;
          break;
        }
      }

      result.add(
        VisitModel.fromMap({
          ...v,
          'customer_name': customer['name'],
          'customer_phone': customer['phone'],
          'worker_name': worker['name'],
        }),
      );
    }
    return result;
  }

  // Get visit by ID
  Future<VisitModel?> getVisitById(int id) async {
    final visits = await DatabaseService.getAll(DatabaseService.keyVisits);
    Map<String, dynamic>? foundVisit;
    for (var v in visits) {
      if (v['id'] == id) {
        foundVisit = v;
        break;
      }
    }

    if (foundVisit == null) return null;

    final customers = await DatabaseService.getAll(
      DatabaseService.keyCustomers,
    );
    final workers = await DatabaseService.getAll(DatabaseService.keyWorkers);

    Map<String, dynamic> customer = {};
    for (var c in customers) {
      if (c['id'] == foundVisit['customer_id']) {
        customer = c;
        break;
      }
    }

    Map<String, dynamic> worker = {};
    for (var w in workers) {
      if (w['id'] == foundVisit['worker_id']) {
        worker = w;
        break;
      }
    }

    return VisitModel.fromMap({
      ...foundVisit,
      'customer_name': customer['name'],
      'customer_phone': customer['phone'],
      'worker_name': worker['name'],
    });
  }

  // Get today's visits
  Future<List<VisitModel>> getTodayVisits() async {
    final visits = await getAllVisits();
    final today = DateTime.now();
    final List<VisitModel> result = [];
    for (var v in visits) {
      if (v.visitDate.year == today.year &&
          v.visitDate.month == today.month &&
          v.visitDate.day == today.day) {
        result.add(v);
      }
    }
    return result;
  }

  // Get visits by date
  Future<List<VisitModel>> getVisitsByDate(DateTime date) async {
    final visits = await getAllVisits();
    final List<VisitModel> result = [];
    for (var v in visits) {
      if (v.visitDate.year == date.year &&
          v.visitDate.month == date.month &&
          v.visitDate.day == date.day) {
        result.add(v);
      }
    }
    return result;
  }

  // Get month visits
  Future<List<VisitModel>> getMonthVisits(int year, int month) async {
    final visits = await getAllVisits();
    final List<VisitModel> result = [];
    for (var v in visits) {
      if (v.visitDate.year == year && v.visitDate.month == month) {
        result.add(v);
      }
    }
    return result;
  }

  // Get customer visits
  Future<List<VisitModel>> getCustomerVisits(int customerId) async {
    final visits = await getAllVisits();
    final List<VisitModel> result = [];
    for (var v in visits) {
      if (v.customerId == customerId) {
        result.add(v);
      }
    }
    return result;
  }

  // Get worker visits
  Future<List<VisitModel>> getWorkerVisits(int workerId) async {
    final visits = await getAllVisits();
    final List<VisitModel> result = [];
    for (var v in visits) {
      if (v.workerId == workerId) {
        result.add(v);
      }
    }
    return result;
  }

  // Add visit
  Future<int> addVisit(VisitModel visit) async {
    final now = DateTime.now().toIso8601String();
    final visitMap = {
      'customer_id': visit.customerId,
      'worker_id': visit.workerId,
      'visit_date': visit.visitDate.toIso8601String(),
      'services': visit.services.join(','),
      'service_ids': visit.serviceIds.join(','),
      'total_amount': visit.totalAmount,
      'payment_status': visit.paymentStatus,
      'payment_method': visit.paymentMethod,
      'notes': visit.notes,
      'created_at': now,
    };

    final visitId = await DatabaseService.insert(
      DatabaseService.keyVisits,
      visitMap,
    );

    if (visitId > 0) {
      // Update customer stats
      await _updateCustomerStats(visit.customerId, visit.totalAmount);
    }

    return visitId;
  }

  // Update visit
  Future<bool> updateVisit(VisitModel visit) async {
    final oldVisit = await getVisitById(visit.id!);
    final updatedMap = {
      'customer_id': visit.customerId,
      'worker_id': visit.workerId,
      'visit_date': visit.visitDate.toIso8601String(),
      'services': visit.services.join(','),
      'service_ids': visit.serviceIds.join(','),
      'total_amount': visit.totalAmount,
      'payment_status': visit.paymentStatus,
      'payment_method': visit.paymentMethod,
      'notes': visit.notes,
    };

    final result = await DatabaseService.update(
      DatabaseService.keyVisits,
      visit.id!,
      updatedMap,
    );

    if (result > 0 && oldVisit != null) {
      final amountDiff = visit.totalAmount - oldVisit.totalAmount;
      if (amountDiff != 0) {
        await _updateCustomerStats(visit.customerId, amountDiff);
      }
    }

    return result > 0;
  }

  // Delete visit
  Future<bool> deleteVisit(int id) async {
    final visit = await getVisitById(id);
    final result = await DatabaseService.delete(DatabaseService.keyVisits, id);

    if (result > 0 && visit != null) {
      await _updateCustomerStats(visit.customerId, -visit.totalAmount);
    }

    return result > 0;
  }

  // Get upcoming visits
  Future<List<VisitModel>> getUpcomingVisits() async {
    final visits = await getAllVisits();
    final now = DateTime.now();
    final List<VisitModel> result = [];
    for (var v in visits) {
      if (v.visitDate.isAfter(now)) {
        result.add(v);
      }
    }
    return result;
  }

  // Get popular services
  Future<List<Map<String, dynamic>>> getPopularServicesFromVisits(
    int limit,
  ) async {
    final visits = await getAllVisits();
    final Map<String, int> serviceCount = {};

    for (var visit in visits) {
      for (var service in visit.services) {
        serviceCount[service] = (serviceCount[service] ?? 0) + 1;
      }
    }

    // Convert to list and sort
    final List<MapEntry<String, int>> entries = [];
    for (var entry in serviceCount.entries) {
      entries.add(entry);
    }

    // Sort manually
    for (int i = 0; i < entries.length - 1; i++) {
      for (int j = i + 1; j < entries.length; j++) {
        if (entries[j].value > entries[i].value) {
          final temp = entries[i];
          entries[i] = entries[j];
          entries[j] = temp;
        }
      }
    }

    final List<Map<String, dynamic>> result = [];
    final int takeCount = limit < entries.length ? limit : entries.length;
    for (int i = 0; i < takeCount; i++) {
      result.add({'service': entries[i].key, 'count': entries[i].value});
    }

    return result;
  }

  // Helper: Update customer stats
  Future<void> _updateCustomerStats(int customerId, double amount) async {
    final customers = await DatabaseService.getAll(
      DatabaseService.keyCustomers,
    );

    Map<String, dynamic>? foundCustomer;
    for (var c in customers) {
      if (c['id'] == customerId) {
        foundCustomer = c;
        break;
      }
    }

    if (foundCustomer != null) {
      final currentSpent =
          (foundCustomer['total_spent'] as num?)?.toDouble() ?? 0.0;
      final currentVisits = foundCustomer['visit_count'] as int? ?? 0;
      final newSpent = currentSpent + amount;
      final newVisits = amount > 0 ? currentVisits + 1 : (currentVisits - 1);
      final isRegular = newVisits >= 5;

      await DatabaseService.update(DatabaseService.keyCustomers, customerId, {
        'total_spent': newSpent > 0 ? newSpent : 0,
        'visit_count': newVisits > 0 ? newVisits : 0,
        'last_visit_date': amount > 0
            ? DateTime.now().toIso8601String()
            : foundCustomer['last_visit_date'],
        'is_regular': isRegular ? 1 : 0,
      });
    }
  }
}
