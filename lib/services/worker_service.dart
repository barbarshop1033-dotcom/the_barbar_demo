import '../models/worker_model.dart';
import 'database_service.dart';

class WorkerService {
  // Get all workers
  Future<List<WorkerModel>> getAllWorkers() async {
    final maps = await DatabaseService.getAll(DatabaseService.keyWorkers);
    maps.sort((a, b) => (a['name'] ?? '').compareTo(b['name'] ?? ''));
    return maps.map((map) => WorkerModel.fromMap(map)).toList();
  }

  // Get active workers
  Future<List<WorkerModel>> getActiveWorkers() async {
    final workers = await getAllWorkers();
    return workers.where((w) => w.isActive).toList();
  }

  // Get workers by role
  Future<List<WorkerModel>> getWorkersByRole(String role) async {
    final workers = await getAllWorkers();
    return workers.where((w) => w.role == role && w.isActive).toList();
  }

  // Get worker by ID
  Future<WorkerModel?> getWorkerById(int id) async {
    final workers = await getAllWorkers();
    return workers.firstWhere(
      (w) => w.id == id,
      orElse: () => throw Exception('Worker not found'),
    );
  }

  // Add worker
  Future<int> addWorker(WorkerModel worker) async {
    final now = DateTime.now().toIso8601String();
    final workerMap = {
      ...worker.toMap(),
      'created_at': now,
      'updated_at': now,
      'join_date': worker.joinDate.toIso8601String(),
    };
    workerMap.remove('id');
    return await DatabaseService.insert(DatabaseService.keyWorkers, workerMap);
  }

  // Update worker
  Future<bool> updateWorker(WorkerModel worker) async {
    final updatedMap = {
      ...worker.toMap(),
      'updated_at': DateTime.now().toIso8601String(),
    };
    final result = await DatabaseService.update(
      DatabaseService.keyWorkers,
      worker.id!,
      updatedMap,
    );
    return result > 0;
  }

  // Delete worker (deactivate instead)
  Future<bool> deleteWorker(int id) async {
    final result = await DatabaseService.update(
      DatabaseService.keyWorkers,
      id,
      {'is_active': 0, 'updated_at': DateTime.now().toIso8601String()},
    );
    return result > 0;
  }

  // Get worker stats
  Future<Map<String, dynamic>> getWorkerStats(int workerId) async {
    final bills = await DatabaseService.getAll(DatabaseService.keyBills);
    final visits = await DatabaseService.getAll(DatabaseService.keyVisits);
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);

    final workerBills = bills.where(
      (b) => b['worker_id'] == workerId && b['payment_status'] == 'paid',
    );
    final workerVisits = visits.where((v) => v['worker_id'] == workerId);

    final totalBills = workerBills.length;
    final totalEarnings = workerBills.fold(
      0.0,
      (sum, b) => sum + (b['final_amount'] as num).toDouble(),
    );

    final monthlyBills = workerBills.where((b) {
      final date = DateTime.parse(b['created_at']);
      return date.isAfter(startOfMonth);
    });
    final monthlyEarnings = monthlyBills.fold(
      0.0,
      (sum, b) => sum + (b['final_amount'] as num).toDouble(),
    );

    final uniqueCustomers = workerBills.map((b) => b['customer_id']).toSet();

    return {
      'totalBills': totalBills,
      'totalEarnings': totalEarnings,
      'totalCustomers': uniqueCustomers.length,
      'monthlyEarnings': monthlyEarnings,
      'totalVisits': workerVisits.length,
    };
  }

  // Get worker commission
  Future<double> getWorkerCommission(
    int workerId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final worker = await getWorkerById(workerId);
    if (worker == null) return 0.0;

    final bills = await DatabaseService.getAll(DatabaseService.keyBills);
    final workerBills = bills.where((b) {
      return b['worker_id'] == workerId &&
          b['payment_status'] == 'paid' &&
          DateTime.parse(b['created_at']).isAfter(startDate) &&
          DateTime.parse(b['created_at']).isBefore(endDate);
    });

    final total = workerBills.fold(
      0.0,
      (sum, b) => sum + (b['final_amount'] as num).toDouble(),
    );
    return total * (worker.commissionPercentage / 100);
  }

  // Get workers with stats
  Future<List<WorkerModel>> getWorkersWithStats() async {
    final workers = await getAllWorkers();
    final workersWithStats = <WorkerModel>[];

    for (var worker in workers) {
      final stats = await getWorkerStats(worker.id!);
      workersWithStats.add(
        worker.copyWith(
          totalEarnings: stats['totalEarnings'] as double?,
          totalCustomers: stats['totalCustomers'] as int?,
          totalServices: stats['totalBills'] as int?,
        ),
      );
    }

    return workersWithStats;
  }
}
