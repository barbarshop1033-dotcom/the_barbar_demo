import 'package:sqflite/sqflite.dart';
import '../models/visit_model.dart';
import 'database_service.dart';

class VisitService {
  // Get database instance
  Future<Database> get _db async => DatabaseService.database;

  // Get all visits with customer and worker info
  Future<List<VisitModel>> getAllVisits() async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT v.*, c.name as customer_name, c.phone as customer_phone,
             w.name as worker_name
      FROM visits v
      LEFT JOIN customers c ON v.customer_id = c.id
      LEFT JOIN workers w ON v.worker_id = w.id
      ORDER BY v.visit_date DESC
    ''');
    return maps.map((map) => VisitModel.fromMap(map)).toList();
  }

  // Get visit by ID
  Future<VisitModel?> getVisitById(int id) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT v.*, c.name as customer_name, c.phone as customer_phone,
             w.name as worker_name
      FROM visits v
      LEFT JOIN customers c ON v.customer_id = c.id
      LEFT JOIN workers w ON v.worker_id = w.id
      WHERE v.id = ?
    ''', [id]);
    if (maps.isEmpty) return null;
    return VisitModel.fromMap(maps.first);
  }

  // Get today's visits
  Future<List<VisitModel>> getTodayVisits() async {
    final db = await _db;
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day).toIso8601String();
    final endOfDay =
        DateTime(now.year, now.month, now.day, 23, 59, 59).toIso8601String();

    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT v.*, c.name as customer_name, c.phone as customer_phone,
             w.name as worker_name
      FROM visits v
      LEFT JOIN customers c ON v.customer_id = c.id
      LEFT JOIN workers w ON v.worker_id = w.id
      WHERE v.visit_date >= ? AND v.visit_date <= ?
      ORDER BY v.visit_date DESC
    ''', [startOfDay, endOfDay]);

    return maps.map((map) => VisitModel.fromMap(map)).toList();
  }

  // Get visits by date
  Future<List<VisitModel>> getVisitsByDate(DateTime date) async {
    final db = await _db;
    final startOfDay =
        DateTime(date.year, date.month, date.day).toIso8601String();
    final endOfDay =
        DateTime(date.year, date.month, date.day, 23, 59, 59).toIso8601String();

    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT v.*, c.name as customer_name, c.phone as customer_phone,
             w.name as worker_name
      FROM visits v
      LEFT JOIN customers c ON v.customer_id = c.id
      LEFT JOIN workers w ON v.worker_id = w.id
      WHERE v.visit_date >= ? AND v.visit_date <= ?
      ORDER BY v.visit_date DESC
    ''', [startOfDay, endOfDay]);

    return maps.map((map) => VisitModel.fromMap(map)).toList();
  }

  // Get month visits
  Future<List<VisitModel>> getMonthVisits(int year, int month) async {
    final db = await _db;
    final startOfMonth = DateTime(year, month, 1).toIso8601String();
    final endOfMonth =
        DateTime(year, month + 1, 0, 23, 59, 59).toIso8601String();

    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT v.*, c.name as customer_name, c.phone as customer_phone,
             w.name as worker_name
      FROM visits v
      LEFT JOIN customers c ON v.customer_id = c.id
      LEFT JOIN workers w ON v.worker_id = w.id
      WHERE v.visit_date >= ? AND v.visit_date <= ?
      ORDER BY v.visit_date DESC
    ''', [startOfMonth, endOfMonth]);

    return maps.map((map) => VisitModel.fromMap(map)).toList();
  }

  // Get customer visits
  Future<List<VisitModel>> getCustomerVisits(int customerId) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT v.*, c.name as customer_name, c.phone as customer_phone,
             w.name as worker_name
      FROM visits v
      LEFT JOIN customers c ON v.customer_id = c.id
      LEFT JOIN workers w ON v.worker_id = w.id
      WHERE v.customer_id = ?
      ORDER BY v.visit_date DESC
    ''', [customerId]);

    return maps.map((map) => VisitModel.fromMap(map)).toList();
  }

  // Get worker visits
  Future<List<VisitModel>> getWorkerVisits(int workerId) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT v.*, c.name as customer_name, c.phone as customer_phone,
             w.name as worker_name
      FROM visits v
      LEFT JOIN customers c ON v.customer_id = c.id
      LEFT JOIN workers w ON v.worker_id = w.id
      WHERE v.worker_id = ?
      ORDER BY v.visit_date DESC
    ''', [workerId]);

    return maps.map((map) => VisitModel.fromMap(map)).toList();
  }

  // Add new visit
  Future<int> addVisit(VisitModel visit) async {
    final db = await _db;
    final visitId = await db.insert('visits', visit.toMap());

    if (visitId > 0) {
      // Update customer's last visit and visit count
      await db.rawUpdate('''
        UPDATE customers 
        SET last_visit_date = ?,
            visit_count = visit_count + 1,
            total_spent = total_spent + ?,
            updated_at = ?
        WHERE id = ?
      ''', [
        visit.visitDate.toIso8601String(),
        visit.totalAmount,
        DateTime.now().toIso8601String(),
        visit.customerId
      ]);

      // Check if customer should be marked as regular
      final customer = await db.query(
        'customers',
        columns: ['visit_count', 'is_regular'],
        where: 'id = ?',
        whereArgs: [visit.customerId],
      );

      if (customer.isNotEmpty) {
        final visitCount = customer.first['visit_count'] as int;
        final isRegular = customer.first['is_regular'] as int;

        if (visitCount >= 5 && isRegular == 0) {
          await db.update(
            'customers',
            {'is_regular': 1},
            where: 'id = ?',
            whereArgs: [visit.customerId],
          );
        }
      }
    }

    return visitId;
  }

  // Update visit
  Future<bool> updateVisit(VisitModel visit) async {
    final db = await _db;
    // Get old visit to calculate difference
    final oldVisit = await getVisitById(visit.id!);

    final count = await db.update(
      'visits',
      visit.toMap(),
      where: 'id = ?',
      whereArgs: [visit.id],
    );

    if (count > 0 && oldVisit != null) {
      // Update customer total spent if amount changed
      final amountDiff = visit.totalAmount - oldVisit.totalAmount;
      if (amountDiff != 0) {
        await db.rawUpdate('''
          UPDATE customers 
          SET total_spent = MAX(0, total_spent + ?),
              updated_at = ?
          WHERE id = ?
        ''', [amountDiff, DateTime.now().toIso8601String(), visit.customerId]);
      }
    }

    return count > 0;
  }

  // Delete visit
  Future<bool> deleteVisit(int id) async {
    final db = await _db;
    final visit = await getVisitById(id);

    if (visit == null) return false;

    final count = await db.delete(
      'visits',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (count > 0) {
      // Update customer stats
      await db.rawUpdate('''
        UPDATE customers 
        SET total_spent = MAX(0, total_spent - ?),
            visit_count = MAX(0, visit_count - 1),
            updated_at = ?
        WHERE id = ?
      ''', [
        visit.totalAmount,
        DateTime.now().toIso8601String(),
        visit.customerId
      ]);
    }

    return count > 0;
  }

  // Get upcoming visits (for today and future)
  Future<List<VisitModel>> getUpcomingVisits() async {
    final db = await _db;
    final now = DateTime.now().toIso8601String();

    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT v.*, c.name as customer_name, c.phone as customer_phone,
             w.name as worker_name
      FROM visits v
      LEFT JOIN customers c ON v.customer_id = c.id
      LEFT JOIN workers w ON v.worker_id = w.id
      WHERE v.visit_date >= ?
      ORDER BY v.visit_date ASC
    ''', [now]);

    return maps.map((map) => VisitModel.fromMap(map)).toList();
  }

  // Get popular services from visits
  Future<List<Map<String, dynamic>>> getPopularServicesFromVisits(
      int limit) async {
    final allVisits = await getAllVisits();
    final Map<String, int> serviceCount = {};

    for (var visit in allVisits) {
      for (var service in visit.services) {
        serviceCount[service] = (serviceCount[service] ?? 0) + 1;
      }
    }

    final sortedServices = serviceCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedServices
        .take(limit)
        .map((e) => {
              'service': e.key,
              'count': e.value,
            })
        .toList();
  }
}
