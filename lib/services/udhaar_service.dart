import 'package:sqflite/sqflite.dart';
import '../models/udhaar_model.dart';
import 'database_service.dart';

class UdhaarService {
  // Get database instance
  Future<Database> get _db async => DatabaseService.database;

  // Get all udhaar entries with customer info
  Future<List<UdhaarModel>> getAllUdhaar() async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT u.*, c.name as customer_name, c.phone as customer_phone
      FROM udhaar u
      LEFT JOIN customers c ON u.customer_id = c.id
      ORDER BY u.updated_at DESC
    ''');
    return maps.map((map) => UdhaarModel.fromMap(map)).toList();
  }

  // Get udhaar by ID
  Future<UdhaarModel?> getUdhaarById(int id) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT u.*, c.name as customer_name, c.phone as customer_phone
      FROM udhaar u
      LEFT JOIN customers c ON u.customer_id = c.id
      WHERE u.id = ?
    ''', [id]);
    if (maps.isEmpty) return null;
    return UdhaarModel.fromMap(maps.first);
  }

  // Get udhaar payments
  Future<List<UdhaarPayment>> getUdhaarPayments(int udhaarId) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'udhaar_payments',
      where: 'udhaar_id = ?',
      whereArgs: [udhaarId],
      orderBy: 'payment_date DESC',
    );
    return maps.map((map) => UdhaarPayment.fromMap(map)).toList();
  }

  // Add new udhaar entry
  Future<int> addUdhaar(UdhaarModel udhaar) async {
    final db = await _db;
    return await db.insert('udhaar', udhaar.toMap());
  }

  // Update udhaar entry
  Future<bool> updateUdhaar(UdhaarModel udhaar) async {
    final db = await _db;
    final updated = udhaar.copyWith(updatedAt: DateTime.now());
    final count = await db.update(
      'udhaar',
      updated.toMap(),
      where: 'id = ?',
      whereArgs: [udhaar.id],
    );
    return count > 0;
  }

  // Delete udhaar entry
  Future<bool> deleteUdhaar(int id) async {
    final db = await _db;
    final count = await db.delete(
      'udhaar',
      where: 'id = ?',
      whereArgs: [id],
    );
    return count > 0;
  }

  // Add payment to udhaar
  Future<int> addPayment(UdhaarPayment payment) async {
    final db = await _db;
    final paymentId = await db.insert('udhaar_payments', payment.toMap());

    if (paymentId > 0) {
      // Update udhaar paid amount and status
      final udhaar = await getUdhaarById(payment.udhaarId);
      if (udhaar != null) {
        final newPaidAmount = udhaar.paidAmount + payment.amount;
        String newStatus = 'pending';

        if (newPaidAmount >= udhaar.totalAmount) {
          newStatus = 'paid';
        } else if (newPaidAmount > 0) {
          newStatus = 'partial';
        }

        await db.update(
          'udhaar',
          {
            'paid_amount': newPaidAmount,
            'status': newStatus,
            'updated_at': DateTime.now().toIso8601String(),
          },
          where: 'id = ?',
          whereArgs: [payment.udhaarId],
        );
      }
    }

    return paymentId;
  }

  // Delete payment
  Future<bool> deletePayment(int paymentId) async {
    final db = await _db;

    // Get payment details first
    final List<Map<String, dynamic>> paymentMaps = await db.query(
      'udhaar_payments',
      where: 'id = ?',
      whereArgs: [paymentId],
    );

    if (paymentMaps.isEmpty) return false;

    final payment = UdhaarPayment.fromMap(paymentMaps.first);

    // Delete the payment
    final count = await db.delete(
      'udhaar_payments',
      where: 'id = ?',
      whereArgs: [paymentId],
    );

    if (count > 0) {
      // Update udhaar paid amount
      final udhaar = await getUdhaarById(payment.udhaarId);
      if (udhaar != null) {
        final newPaidAmount =
            (udhaar.paidAmount - payment.amount).clamp(0.0, udhaar.totalAmount);
        String newStatus = 'pending';

        if (newPaidAmount <= 0) {
          newStatus = 'pending';
        } else if (newPaidAmount >= udhaar.totalAmount) {
          newStatus = 'paid';
        } else {
          newStatus = 'partial';
        }

        await db.update(
          'udhaar',
          {
            'paid_amount': newPaidAmount,
            'status': newStatus,
            'updated_at': DateTime.now().toIso8601String(),
          },
          where: 'id = ?',
          whereArgs: [payment.udhaarId],
        );
      }
    }

    return count > 0;
  }

  // Get customer udhaar entries
  Future<List<UdhaarModel>> getCustomerUdhaar(int customerId) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT u.*, c.name as customer_name, c.phone as customer_phone
      FROM udhaar u
      LEFT JOIN customers c ON u.customer_id = c.id
      WHERE u.customer_id = ?
      ORDER BY u.created_at DESC
    ''', [customerId]);
    return maps.map((map) => UdhaarModel.fromMap(map)).toList();
  }

  // Get pending udhaar entries
  Future<List<UdhaarModel>> getPendingUdhaar() async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT u.*, c.name as customer_name, c.phone as customer_phone
      FROM udhaar u
      LEFT JOIN customers c ON u.customer_id = c.id
      WHERE u.status != 'paid'
      ORDER BY u.due_date ASC
    ''');
    return maps.map((map) => UdhaarModel.fromMap(map)).toList();
  }

  // Get overdue udhaar entries
  Future<List<UdhaarModel>> getOverdueUdhaar() async {
    final db = await _db;
    final now = DateTime.now().toIso8601String();
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT u.*, c.name as customer_name, c.phone as customer_phone
      FROM udhaar u
      LEFT JOIN customers c ON u.customer_id = c.id
      WHERE u.status != 'paid' AND u.due_date IS NOT NULL AND u.due_date < ?
      ORDER BY u.due_date ASC
    ''', [now]);
    return maps.map((map) => UdhaarModel.fromMap(map)).toList();
  }

  // Get total pending amount
  Future<double> getTotalPendingAmount() async {
    final db = await _db;
    final result = await db.rawQuery(
        'SELECT SUM(total_amount - paid_amount) as total FROM udhaar WHERE status != ?',
        ['paid']);
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }
}
