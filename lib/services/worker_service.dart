import 'package:sqflite/sqflite.dart';
import '../models/worker_model.dart';
import 'database_service.dart';

class WorkerService {
  // Get database instance
  Future<Database> get _db async => DatabaseService.database;

  // Get all workers
  Future<List<WorkerModel>> getAllWorkers() async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'workers',
      orderBy: 'name ASC',
    );
    return maps.map((map) => WorkerModel.fromMap(map)).toList();
  }

  // Get active workers
  Future<List<WorkerModel>> getActiveWorkers() async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'workers',
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'name ASC',
    );
    return maps.map((map) => WorkerModel.fromMap(map)).toList();
  }

  // Get workers by role
  Future<List<WorkerModel>> getWorkersByRole(String role) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'workers',
      where: 'role = ? AND is_active = ?',
      whereArgs: [role, 1],
      orderBy: 'name ASC',
    );
    return maps.map((map) => WorkerModel.fromMap(map)).toList();
  }

  // Get worker by ID
  Future<WorkerModel?> getWorkerById(int id) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'workers',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return WorkerModel.fromMap(maps.first);
  }

  // Add new worker
  Future<int> addWorker(WorkerModel worker) async {
    final db = await _db;
    return await db.insert('workers', worker.toMap());
  }

  // Update worker
  Future<bool> updateWorker(WorkerModel worker) async {
    final db = await _db;
    final updated = worker.copyWith(updatedAt: DateTime.now());
    final count = await db.update(
      'workers',
      updated.toMap(),
      where: 'id = ?',
      whereArgs: [worker.id],
    );
    return count > 0;
  }

  // Delete worker
  Future<bool> deleteWorker(int id) async {
    final db = await _db;
    // Instead of deleting, deactivate the worker
    final count = await db.update(
      'workers',
      {
        'is_active': 0,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
    return count > 0;
  }

  // Get worker stats
  Future<Map<String, dynamic>> getWorkerStats(int workerId) async {
    final db = await _db;

    // Get total bills and earnings
    final billStats = await db.rawQuery('''
      SELECT COUNT(*) as total_bills, SUM(final_amount) as total_earnings
      FROM bills
      WHERE worker_id = ? AND payment_status = 'paid'
    ''', [workerId]);

    // Get total customers served
    final customerStats = await db.rawQuery('''
      SELECT COUNT(DISTINCT customer_id) as total_customers
      FROM bills
      WHERE worker_id = ?
    ''', [workerId]);

    // Get monthly earnings
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1).toIso8601String();
    final monthlyStats = await db.rawQuery('''
      SELECT SUM(final_amount) as monthly_earnings
      FROM bills
      WHERE worker_id = ? AND created_at >= ? AND payment_status = 'paid'
    ''', [workerId, startOfMonth]);

    // Get visit count
    final visitStats = await db.rawQuery('''
      SELECT COUNT(*) as total_visits
      FROM visits
      WHERE worker_id = ?
    ''', [workerId]);

    return {
      'totalBills': billStats.first['total_bills'] ?? 0,
      'totalEarnings': billStats.first['total_earnings'] ?? 0.0,
      'totalCustomers': customerStats.first['total_customers'] ?? 0,
      'monthlyEarnings': monthlyStats.first['monthly_earnings'] ?? 0.0,
      'totalVisits': visitStats.first['total_visits'] ?? 0,
    };
  }

  // Get worker commission
  Future<double> getWorkerCommission(
      int workerId, DateTime startDate, DateTime endDate) async {
    final db = await _db;
    final worker = await getWorkerById(workerId);
    if (worker == null) return 0.0;

    final result = await db.rawQuery('''
      SELECT SUM(final_amount) as total
      FROM bills
      WHERE worker_id = ? 
        AND created_at >= ? 
        AND created_at <= ?
        AND payment_status = 'paid'
    ''', [workerId, startDate.toIso8601String(), endDate.toIso8601String()]);

    final total = (result.first['total'] as num?)?.toDouble() ?? 0.0;
    return total * (worker.commissionPercentage / 100);
  }

  // Get all workers with stats
  Future<List<WorkerModel>> getWorkersWithStats() async {
    final workers = await getAllWorkers();
    final workersWithStats = <WorkerModel>[];

    for (var worker in workers) {
      final stats = await getWorkerStats(worker.id!);
      workersWithStats.add(worker.copyWith(
        totalEarnings: (stats['totalEarnings'] as num?)?.toDouble(),
        totalCustomers: stats['totalCustomers'] as int?,
        totalServices: stats['totalBills'] as int?,
      ));
    }

    return workersWithStats;
  }
}
