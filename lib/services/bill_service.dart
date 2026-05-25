import 'package:sqflite/sqflite.dart';
import '../models/bill_model.dart';
import 'database_service.dart';

class BillService {
  // Get database instance
  Future<Database> get _db async => DatabaseService.database;

  // Get all bills with customer and worker info
  Future<List<BillModel>> getAllBills() async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT b.*, c.name as customer_name, c.phone as customer_phone,
             w.name as worker_name
      FROM bills b
      LEFT JOIN customers c ON b.customer_id = c.id
      LEFT JOIN workers w ON b.worker_id = w.id
      ORDER BY b.created_at DESC
    ''');
    return maps.map((map) => BillModel.fromMap(map)).toList();
  }

  // Get bill by ID
  Future<BillModel?> getBillById(int id) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT b.*, c.name as customer_name, c.phone as customer_phone,
             w.name as worker_name
      FROM bills b
      LEFT JOIN customers c ON b.customer_id = c.id
      LEFT JOIN workers w ON b.worker_id = w.id
      WHERE b.id = ?
    ''',
      [id],
    );
    if (maps.isEmpty) return null;
    return BillModel.fromMap(maps.first);
  }

  // Get bill items
  Future<List<BillItem>> getBillItems(int billId) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'bill_items',
      where: 'bill_id = ?',
      whereArgs: [billId],
    );
    return maps.map((map) => BillItem.fromMap(map)).toList();
  }

  // FIXED: Create new bill - ONLY inserts the bill, not items
  Future<int?> createBill(BillModel bill) async {
    final db = await _db;

    return await db.transaction<int>((txn) async {
      // Insert bill only (items inserted separately by BillProvider)
      final billId = await txn.insert('bills', {
        'customer_id': bill.customerId,
        'worker_id': bill.workerId,
        'total_amount': bill.totalAmount,
        'discount': bill.discount,
        'tax': bill.tax,
        'final_amount': bill.finalAmount,
        'payment_method': bill.paymentMethod,
        'payment_status': bill.paymentStatus,
        'notes': bill.notes,
        'created_at': DateTime.now().toIso8601String(),
      });

      if (billId > 0) {
        // Update customer total spent and last visit
        await txn.rawUpdate(
          '''
          UPDATE customers 
          SET total_spent = total_spent + ?,
              last_visit_date = ?,
              visit_count = visit_count + 1,
              updated_at = ?
          WHERE id = ?
        ''',
          [
            bill.finalAmount,
            DateTime.now().toIso8601String(),
            DateTime.now().toIso8601String(),
            bill.customerId,
          ],
        );

        // Update customer regular status if needed
        final customer = await txn.query(
          'customers',
          columns: ['visit_count', 'is_regular'],
          where: 'id = ?',
          whereArgs: [bill.customerId],
        );

        if (customer.isNotEmpty) {
          final visitCount = customer.first['visit_count'] as int;
          final isRegular = customer.first['is_regular'] as int;

          if (visitCount >= 5 && isRegular == 0) {
            await txn.update(
              'customers',
              {'is_regular': 1},
              where: 'id = ?',
              whereArgs: [bill.customerId],
            );
          }
        }
      }

      return billId;
    });
  }

  // Add bill item
  Future<int> addBillItem(BillItem item) async {
    final db = await _db;
    return await db.insert('bill_items', {
      'bill_id': item.billId,
      'service_id': item.serviceId,
      'service_name': item.serviceName,
      'price': item.price,
      'quantity': item.quantity,
      'total': item.total,
    });
  }

  // Update bill payment status
  Future<bool> updatePaymentStatus(int billId, String status) async {
    final db = await _db;
    final count = await db.update(
      'bills',
      {'payment_status': status},
      where: 'id = ?',
      whereArgs: [billId],
    );
    return count > 0;
  }

  // Delete bill
  Future<bool> deleteBill(int id) async {
    final db = await _db;
    final bill = await getBillById(id);
    if (bill == null) return false;

    return await db.transaction<bool>((txn) async {
      await txn.delete('bill_items', where: 'bill_id = ?', whereArgs: [id]);
      final count = await txn.delete('bills', where: 'id = ?', whereArgs: [id]);

      if (count > 0 && bill.paymentStatus == 'paid') {
        await txn.rawUpdate(
          '''
          UPDATE customers 
          SET total_spent = MAX(0, total_spent - ?),
              visit_count = MAX(0, visit_count - 1),
              updated_at = ?
          WHERE id = ?
        ''',
          [bill.finalAmount, DateTime.now().toIso8601String(), bill.customerId],
        );
      }
      return count > 0;
    });
  }

  // Get today's bills
  Future<List<BillModel>> getTodayBills() async {
    final db = await _db;
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day).toIso8601String();
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT b.*, c.name as customer_name, c.phone as customer_phone,
             w.name as worker_name
      FROM bills b
      LEFT JOIN customers c ON b.customer_id = c.id
      LEFT JOIN workers w ON b.worker_id = w.id
      WHERE b.created_at >= ?
      ORDER BY b.created_at DESC
    ''',
      [startOfDay],
    );
    return maps.map((map) => BillModel.fromMap(map)).toList();
  }

  // Get bills from specific date
  Future<List<BillModel>> getBillsFromDate(DateTime date) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT b.*, c.name as customer_name, c.phone as customer_phone,
             w.name as worker_name
      FROM bills b
      LEFT JOIN customers c ON b.customer_id = c.id
      LEFT JOIN workers w ON b.worker_id = w.id
      WHERE b.created_at >= ?
      ORDER BY b.created_at DESC
    ''',
      [date.toIso8601String()],
    );
    return maps.map((map) => BillModel.fromMap(map)).toList();
  }

  // Get day bills
  Future<List<BillModel>> getDayBills(int year, int month, int day) async {
    final db = await _db;
    final startOfDay = DateTime(year, month, day).toIso8601String();
    final endOfDay = DateTime(year, month, day, 23, 59, 59).toIso8601String();
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT b.*, c.name as customer_name, c.phone as customer_phone,
             w.name as worker_name
      FROM bills b
      LEFT JOIN customers c ON b.customer_id = c.id
      LEFT JOIN workers w ON b.worker_id = w.id
      WHERE b.created_at >= ? AND b.created_at <= ?
      ORDER BY b.created_at DESC
    ''',
      [startOfDay, endOfDay],
    );
    return maps.map((map) => BillModel.fromMap(map)).toList();
  }

  // Get month bills
  Future<List<BillModel>> getMonthBills(int year, int month) async {
    final db = await _db;
    final startOfMonth = DateTime(year, month, 1).toIso8601String();
    final endOfMonth = DateTime(
      year,
      month + 1,
      0,
      23,
      59,
      59,
    ).toIso8601String();
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT b.*, c.name as customer_name, c.phone as customer_phone,
             w.name as worker_name
      FROM bills b
      LEFT JOIN customers c ON b.customer_id = c.id
      LEFT JOIN workers w ON b.worker_id = w.id
      WHERE b.created_at >= ? AND b.created_at <= ?
      ORDER BY b.created_at DESC
    ''',
      [startOfMonth, endOfMonth],
    );
    return maps.map((map) => BillModel.fromMap(map)).toList();
  }

  // Get recent bills
  Future<List<BillModel>> getRecentBills(int limit) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT b.*, c.name as customer_name, c.phone as customer_phone,
             w.name as worker_name
      FROM bills b
      LEFT JOIN customers c ON b.customer_id = c.id
      LEFT JOIN workers w ON b.worker_id = w.id
      ORDER BY b.created_at DESC
      LIMIT ?
    ''',
      [limit],
    );
    return maps.map((map) => BillModel.fromMap(map)).toList();
  }

  // Get customer bills
  Future<List<BillModel>> getCustomerBills(int customerId) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT b.*, c.name as customer_name, c.phone as customer_phone,
             w.name as worker_name
      FROM bills b
      LEFT JOIN customers c ON b.customer_id = c.id
      LEFT JOIN workers w ON b.worker_id = w.id
      WHERE b.customer_id = ?
      ORDER BY b.created_at DESC
    ''',
      [customerId],
    );
    return maps.map((map) => BillModel.fromMap(map)).toList();
  }

  // Get worker bills
  Future<List<BillModel>> getWorkerBills(int workerId) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT b.*, c.name as customer_name, c.phone as customer_phone,
             w.name as worker_name
      FROM bills b
      LEFT JOIN customers c ON b.customer_id = c.id
      LEFT JOIN workers w ON b.worker_id = w.id
      WHERE b.worker_id = ?
      ORDER BY b.created_at DESC
    ''',
      [workerId],
    );
    return maps.map((map) => BillModel.fromMap(map)).toList();
  }

  // Get daily earnings summary
  Future<double> getDailyEarnings(DateTime date) async {
    final db = await _db;
    final startOfDay = DateTime(
      date.year,
      date.month,
      date.day,
    ).toIso8601String();
    final endOfDay = DateTime(
      date.year,
      date.month,
      date.day,
      23,
      59,
      59,
    ).toIso8601String();
    final result = await db.rawQuery(
      '''
      SELECT SUM(final_amount) as total 
      FROM bills 
      WHERE created_at >= ? AND created_at <= ? AND payment_status = 'paid'
    ''',
      [startOfDay, endOfDay],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  // Get revenue by payment method
  Future<Map<String, double>> getRevenueByPaymentMethod(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await _db;
    final result = await db.rawQuery(
      '''
      SELECT payment_method, SUM(final_amount) as total
      FROM bills
      WHERE created_at >= ? AND created_at <= ? AND payment_status = 'paid'
      GROUP BY payment_method
    ''',
      [startDate.toIso8601String(), endDate.toIso8601String()],
    );
    final Map<String, double> revenue = {};
    for (var row in result) {
      final method = row['payment_method'] as String? ?? 'Cash';
      revenue[method] = (row['total'] as num?)?.toDouble() ?? 0.0;
    }
    return revenue;
  }
}
