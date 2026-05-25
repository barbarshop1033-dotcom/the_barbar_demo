import 'package:sqflite/sqflite.dart';
import '../models/service_model.dart';
import 'database_service.dart';

class ServiceManagementService {
  // Get database instance
  Future<Database> get _db async => DatabaseService.database;

  // Get all services
  Future<List<ServiceModel>> getAllServices() async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'services',
      orderBy: 'category ASC, name ASC',
    );
    return maps.map((map) => ServiceModel.fromMap(map)).toList();
  }

  // Get active services
  Future<List<ServiceModel>> getActiveServices() async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'services',
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'category ASC, name ASC',
    );
    return maps.map((map) => ServiceModel.fromMap(map)).toList();
  }

  // Get custom services (user-created)
  Future<List<ServiceModel>> getCustomServices() async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'services',
      where: 'is_custom = ?',
      whereArgs: [1],
      orderBy: 'name ASC',
    );
    return maps.map((map) => ServiceModel.fromMap(map)).toList();
  }

  // Get service by ID
  Future<ServiceModel?> getServiceById(int id) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'services',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return ServiceModel.fromMap(maps.first);
  }

  // Get services by category
  Future<List<ServiceModel>> getServicesByCategory(String category) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'services',
      where: 'category = ? AND is_active = ?',
      whereArgs: [category, 1],
      orderBy: 'name ASC',
    );
    return maps.map((map) => ServiceModel.fromMap(map)).toList();
  }

  // Add new service
  Future<int> addService(ServiceModel service) async {
    final db = await _db;
    return await db.insert('services', service.toMap());
  }

  // Update service
  Future<bool> updateService(ServiceModel service) async {
    final db = await _db;
    final updated = service.copyWith(updatedAt: DateTime.now());
    final count = await db.update(
      'services',
      updated.toMap(),
      where: 'id = ?',
      whereArgs: [service.id],
    );
    return count > 0;
  }

  // Delete service
  Future<bool> deleteService(int id) async {
    final db = await _db;
    // Check if service is default (not custom)
    final service = await getServiceById(id);
    if (service != null && !service.isCustom) {
      // Instead of deleting, just deactivate
      return await updateService(service.copyWith(isActive: false));
    }
    final count = await db.delete(
      'services',
      where: 'id = ?',
      whereArgs: [id],
    );
    return count > 0;
  }

  // Toggle service active status
  Future<bool> toggleServiceStatus(int id, bool isActive) async {
    final db = await _db;
    final count = await db.update(
      'services',
      {
        'is_active': isActive ? 1 : 0,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
    return count > 0;
  }

  // Get all categories
  Future<List<String>> getCategories() async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
        'SELECT DISTINCT category FROM services WHERE category IS NOT NULL ORDER BY category');
    return maps.map((map) => map['category'] as String).toList();
  }

  // Search services
  Future<List<ServiceModel>> searchServices(String query) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'services',
      where: 'name LIKE ? OR category LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'name ASC',
    );
    return maps.map((map) => ServiceModel.fromMap(map)).toList();
  }

  // Get popular services (most used in bills)
  Future<List<Map<String, dynamic>>> getPopularServices() async {
    final db = await _db;
    return await db.rawQuery('''
      SELECT s.id, s.name, s.category, COUNT(bi.id) as usage_count, 
             SUM(bi.total) as total_revenue
      FROM services s
      LEFT JOIN bill_items bi ON s.id = bi.service_id
      WHERE s.is_active = 1
      GROUP BY s.id
      ORDER BY usage_count DESC
      LIMIT 10
    ''');
  }

  // Bulk update prices
  Future<void> bulkUpdatePrices(Map<int, double> priceUpdates) async {
    final db = await _db;
    final batch = db.batch();
    final now = DateTime.now().toIso8601String();

    for (var entry in priceUpdates.entries) {
      batch.update(
        'services',
        {'price': entry.value, 'updated_at': now},
        where: 'id = ?',
        whereArgs: [entry.key],
      );
    }

    await batch.commit(noResult: true);
  }
}
