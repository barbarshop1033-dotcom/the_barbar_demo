import 'package:sqflite/sqflite.dart';
import '../models/customer_model.dart';
import 'database_service.dart';

class CustomerService {
  final DatabaseService _databaseService = DatabaseService.instance;

  // Get database instance
  Future<Database> get _db async => DatabaseService.database;

  // Get all customers
  Future<List<CustomerModel>> getAllCustomers() async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'customers',
      orderBy: 'updated_at DESC',
    );
    return maps.map((map) => CustomerModel.fromMap(map)).toList();
  }

  // Get customer by ID
  Future<CustomerModel?> getCustomerById(int id) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'customers',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return CustomerModel.fromMap(maps.first);
  }

  // Get customer by phone number
  Future<CustomerModel?> getCustomerByPhone(String phone) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'customers',
      where: 'phone = ?',
      whereArgs: [phone],
    );
    if (maps.isEmpty) return null;
    return CustomerModel.fromMap(maps.first);
  }

  // Add new customer
  Future<int> addCustomer(CustomerModel customer) async {
    final db = await _db;
    return await db.insert('customers', customer.toMap());
  }

  // Update customer
  Future<bool> updateCustomer(CustomerModel customer) async {
    final db = await _db;
    final updated = customer.copyWith(updatedAt: DateTime.now());
    final count = await db.update(
      'customers',
      updated.toMap(),
      where: 'id = ?',
      whereArgs: [customer.id],
    );
    return count > 0;
  }

  // Delete customer
  Future<bool> deleteCustomer(int id) async {
    final db = await _db;
    final count = await db.delete(
      'customers',
      where: 'id = ?',
      whereArgs: [id],
    );
    return count > 0;
  }

  // Search customers by name or phone
  Future<List<CustomerModel>> searchCustomers(String query) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'customers',
      where: 'name LIKE ? OR phone LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'name ASC',
    );
    return maps.map((map) => CustomerModel.fromMap(map)).toList();
  }

  // Get recent customers
  Future<List<CustomerModel>> getRecentCustomers(int limit) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'customers',
      orderBy: 'updated_at DESC',
      limit: limit,
    );
    return maps.map((map) => CustomerModel.fromMap(map)).toList();
  }

  // Get regular customers
  Future<List<CustomerModel>> getRegularCustomers() async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'customers',
      where: 'is_regular = ?',
      whereArgs: [1],
      orderBy: 'visit_count DESC',
    );
    return maps.map((map) => CustomerModel.fromMap(map)).toList();
  }

  // Get top spending customers
  Future<List<CustomerModel>> getTopSpendingCustomers(int limit) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'customers',
      orderBy: 'total_spent DESC',
      limit: limit,
    );
    return maps.map((map) => CustomerModel.fromMap(map)).toList();
  }

  // Update customer visit stats
  Future<void> updateCustomerVisit(int customerId, double amount) async {
    final db = await _db;
    await db.execute('''
      UPDATE customers 
      SET total_spent = total_spent + ?, 
          visit_count = visit_count + 1,
          last_visit_date = ?,
          updated_at = ?
      WHERE id = ?
    ''', [
      amount,
      DateTime.now().toIso8601String(),
      DateTime.now().toIso8601String(),
      customerId
    ]);

    // Check if customer should be marked as regular (more than 5 visits)
    final customer = await getCustomerById(customerId);
    if (customer != null && customer.visitCount >= 5 && !customer.isRegular) {
      await db.update(
        'customers',
        {'is_regular': 1, 'updated_at': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [customerId],
      );
    }
  }

  // Get total customers count
  Future<int> getCustomerCount() async {
    final db = await _db;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM customers');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Get customers who haven't visited in a while
  Future<List<CustomerModel>> getInactiveCustomers(int days) async {
    final db = await _db;
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    final List<Map<String, dynamic>> maps = await db.query(
      'customers',
      where: 'last_visit_date IS NULL OR last_visit_date < ?',
      whereArgs: [cutoffDate.toIso8601String()],
      orderBy: 'last_visit_date ASC',
    );
    return maps.map((map) => CustomerModel.fromMap(map)).toList();
  }
}
