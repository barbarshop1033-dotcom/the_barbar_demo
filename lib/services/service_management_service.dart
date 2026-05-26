import '../models/service_model.dart';
import 'database_service.dart';

class ServiceManagementService {
  // Get all services
  Future<List<ServiceModel>> getAllServices() async {
    final maps = await DatabaseService.getAll(DatabaseService.keyServices);
    maps.sort((a, b) => (a['category'] ?? '').compareTo(b['category'] ?? ''));
    return maps.map((map) => ServiceModel.fromMap(map)).toList();
  }

  // Get active services
  Future<List<ServiceModel>> getActiveServices() async {
    final services = await getAllServices();
    return services.where((s) => s.isActive).toList();
  }

  // Get custom services
  Future<List<ServiceModel>> getCustomServices() async {
    final services = await getAllServices();
    return services.where((s) => s.isCustom).toList();
  }

  // Get service by ID
  Future<ServiceModel?> getServiceById(int id) async {
    final services = await getAllServices();
    return services.firstWhere(
      (s) => s.id == id,
      orElse: () => throw Exception('Service not found'),
    );
  }

  // Get services by category
  Future<List<ServiceModel>> getServicesByCategory(String category) async {
    final services = await getAllServices();
    return services.where((s) => s.category == category && s.isActive).toList();
  }

  // Add service
  Future<int> addService(ServiceModel service) async {
    final now = DateTime.now().toIso8601String();
    final serviceMap = {
      ...service.toMap(),
      'created_at': now,
      'updated_at': now,
    };
    serviceMap.remove('id');
    return await DatabaseService.insert(
      DatabaseService.keyServices,
      serviceMap,
    );
  }

  // Update service
  Future<bool> updateService(ServiceModel service) async {
    final updatedMap = {
      ...service.toMap(),
      'updated_at': DateTime.now().toIso8601String(),
    };
    final result = await DatabaseService.update(
      DatabaseService.keyServices,
      service.id!,
      updatedMap,
    );
    return result > 0;
  }

  // Delete service
  Future<bool> deleteService(int id) async {
    final service = await getServiceById(id);
    if (service != null && !service.isCustom) {
      // Deactivate instead of delete for default services
      return await updateService(service.copyWith(isActive: false));
    }
    final result = await DatabaseService.delete(
      DatabaseService.keyServices,
      id,
    );
    return result > 0;
  }

  // Toggle service status
  Future<bool> toggleServiceStatus(int id, bool isActive) async {
    return await updateService(
      (await getServiceById(id))!.copyWith(isActive: isActive),
    );
  }

  // Get categories
  Future<List<String>> getCategories() async {
    final services = await getAllServices();
    final categories = services
        .map((s) => s.category)
        .where((c) => c != null)
        .cast<String>()
        .toSet()
        .toList();
    categories.sort();
    return categories;
  }

  // Search services
  Future<List<ServiceModel>> searchServices(String query) async {
    final services = await getAllServices();
    final lowerQuery = query.toLowerCase();
    return services.where((s) {
      return s.name.toLowerCase().contains(lowerQuery) ||
          (s.category?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  // Get popular services
  Future<List<Map<String, dynamic>>> getPopularServices() async {
    final bills = await DatabaseService.getAll(DatabaseService.keyBills);
    final items = await DatabaseService.getAll(DatabaseService.keyBillItems);
    final services = await getAllServices();

    final Map<int, int> serviceCount = {};
    for (var item in items) {
      final serviceId = item['service_id'] as int;
      serviceCount[serviceId] = (serviceCount[serviceId] ?? 0) + 1;
    }

    final List<Map<String, dynamic>> popular = [];
    for (var service in services) {
      final count = serviceCount[service.id] ?? 0;
      if (count > 0) {
        popular.add({
          'id': service.id,
          'name': service.name,
          'category': service.category,
          'usage_count': count,
          'total_revenue': count * service.price,
        });
      }
    }

    popular.sort(
      (a, b) => (b['usage_count'] as int).compareTo(a['usage_count'] as int),
    );
    return popular.take(10).toList();
  }

  // Bulk update prices
  Future<void> bulkUpdatePrices(Map<int, double> priceUpdates) async {
    for (var entry in priceUpdates.entries) {
      final service = await getServiceById(entry.key);
      if (service != null) {
        await updateService(service.copyWith(price: entry.value));
      }
    }
  }
}
