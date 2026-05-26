import '../models/customer_model.dart';
import 'database_service.dart';

class CustomerService {
  // Get all customers
  Future<List<CustomerModel>> getAllCustomers() async {
    final maps = await DatabaseService.getAll(DatabaseService.keyCustomers);
    return maps.map((map) => CustomerModel.fromMap(map)).toList();
  }

  // Get customer by ID
  Future<CustomerModel?> getCustomerById(int id) async {
    final maps = await DatabaseService.getAll(DatabaseService.keyCustomers);
    final map = maps.cast<Map<String, dynamic>?>().firstWhere(
      (item) => item?['id'] == id,
      orElse: () => null,
    );
    if (map == null) return null;
    return CustomerModel.fromMap(map);
  }

  // Get customer by phone number
  Future<CustomerModel?> getCustomerByPhone(String phone) async {
    final maps = await DatabaseService.getAll(DatabaseService.keyCustomers);
    final map = maps.cast<Map<String, dynamic>?>().firstWhere(
      (item) => item?['phone'] == phone,
      orElse: () => null,
    );
    if (map == null) return null;
    return CustomerModel.fromMap(map);
  }

  // Add new customer
  Future<int> addCustomer(CustomerModel customer) async {
    final now = DateTime.now().toIso8601String();
    final customerMap = {
      ...customer.toMap(),
      'id': null,
      'created_at': now,
      'updated_at': now,
      'total_spent': customer.totalSpent,
      'visit_count': customer.visitCount,
      'last_visit_date': customer.lastVisitDate?.toIso8601String(),
      'is_regular': customer.isRegular ? 1 : 0,
    };
    customerMap.remove('id');
    return await DatabaseService.insert(
      DatabaseService.keyCustomers,
      customerMap,
    );
  }

  // Update customer
  Future<bool> updateCustomer(CustomerModel customer) async {
    final updatedMap = {
      ...customer.toMap(),
      'updated_at': DateTime.now().toIso8601String(),
    };
    final result = await DatabaseService.update(
      DatabaseService.keyCustomers,
      customer.id!,
      updatedMap,
    );
    return result > 0;
  }

  // Delete customer
  Future<bool> deleteCustomer(int id) async {
    final result = await DatabaseService.delete(
      DatabaseService.keyCustomers,
      id,
    );
    return result > 0;
  }

  // Search customers
  Future<List<CustomerModel>> searchCustomers(String query) async {
    final maps = await DatabaseService.getAll(DatabaseService.keyCustomers);
    final filtered = maps.where((customer) {
      final name = customer['name']?.toString().toLowerCase() ?? '';
      final phone = customer['phone']?.toString().toLowerCase() ?? '';
      final searchQuery = query.toLowerCase();
      return name.contains(searchQuery) || phone.contains(searchQuery);
    }).toList();
    return filtered.map((map) => CustomerModel.fromMap(map)).toList();
  }

  // Get recent customers
  Future<List<CustomerModel>> getRecentCustomers(int limit) async {
    final maps = await DatabaseService.getAll(DatabaseService.keyCustomers);
    maps.sort(
      (a, b) => (b['updated_at'] ?? '').compareTo(a['updated_at'] ?? ''),
    );
    final recent = maps.take(limit).toList();
    return recent.map((map) => CustomerModel.fromMap(map)).toList();
  }

  // Get regular customers
  Future<List<CustomerModel>> getRegularCustomers() async {
    final maps = await DatabaseService.getAll(DatabaseService.keyCustomers);
    final regular = maps.where((c) => c['is_regular'] == 1).toList();
    regular.sort(
      (a, b) => (b['visit_count'] as int).compareTo(a['visit_count'] as int),
    );
    return regular.map((map) => CustomerModel.fromMap(map)).toList();
  }

  // Get top spending customers
  Future<List<CustomerModel>> getTopSpendingCustomers(int limit) async {
    final maps = await DatabaseService.getAll(DatabaseService.keyCustomers);
    maps.sort(
      (a, b) => (b['total_spent'] as num).compareTo(a['total_spent'] as num),
    );
    final top = maps.take(limit).toList();
    return top.map((map) => CustomerModel.fromMap(map)).toList();
  }

  // Update customer visit stats
  Future<void> updateCustomerVisit(int customerId, double amount) async {
    final customer = await getCustomerById(customerId);
    if (customer == null) return;

    final newTotalSpent = customer.totalSpent + amount;
    final newVisitCount = customer.visitCount + 1;
    final isRegular = newVisitCount >= 5;

    await DatabaseService.update(DatabaseService.keyCustomers, customerId, {
      'total_spent': newTotalSpent,
      'visit_count': newVisitCount,
      'last_visit_date': DateTime.now().toIso8601String(),
      'is_regular': isRegular
          ? 1
          : customer.isRegular
          ? 1
          : 0,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  // Get total customers count
  Future<int> getCustomerCount() async {
    final maps = await DatabaseService.getAll(DatabaseService.keyCustomers);
    return maps.length;
  }

  // Get inactive customers
  Future<List<CustomerModel>> getInactiveCustomers(int days) async {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    final maps = await DatabaseService.getAll(DatabaseService.keyCustomers);
    final inactive = maps.where((c) {
      final lastVisit = c['last_visit_date'];
      if (lastVisit == null) return true;
      return DateTime.parse(lastVisit).isBefore(cutoffDate);
    }).toList();
    return inactive.map((map) => CustomerModel.fromMap(map)).toList();
  }
}
