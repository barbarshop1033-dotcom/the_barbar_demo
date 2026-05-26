import '../models/bill_model.dart';
import 'database_service.dart';

class BillService {
  // Get all bills
  Future<List<BillModel>> getAllBills() async {
    final bills = await DatabaseService.getAll(DatabaseService.keyBills);
    final customers = await DatabaseService.getAll(
      DatabaseService.keyCustomers,
    );
    final workers = await DatabaseService.getAll(DatabaseService.keyWorkers);

    return bills.map((bill) {
      final customer = customers.firstWhere(
        (c) => c['id'] == bill['customer_id'],
        orElse: () => {},
      );
      final worker = workers.firstWhere(
        (w) => w['id'] == bill['worker_id'],
        orElse: () => {},
      );
      return BillModel.fromMap({
        ...bill,
        'customer_name': customer['name'],
        'customer_phone': customer['phone'],
        'worker_name': worker['name'],
      });
    }).toList();
  }

  // Get bill by ID
  Future<BillModel?> getBillById(int id) async {
    final bills = await DatabaseService.getAll(DatabaseService.keyBills);
    final bill = bills.firstWhere((b) => b['id'] == id, orElse: () => {});
    if (bill.isEmpty) return null;

    final customers = await DatabaseService.getAll(
      DatabaseService.keyCustomers,
    );
    final workers = await DatabaseService.getAll(DatabaseService.keyWorkers);
    final customer = customers.firstWhere(
      (c) => c['id'] == bill['customer_id'],
      orElse: () => {},
    );
    final worker = workers.firstWhere(
      (w) => w['id'] == bill['worker_id'],
      orElse: () => {},
    );

    return BillModel.fromMap({
      ...bill,
      'customer_name': customer['name'],
      'customer_phone': customer['phone'],
      'worker_name': worker['name'],
    });
  }

  // Get bill items
  Future<List<BillItem>> getBillItems(int billId) async {
    final items = await DatabaseService.getAll(DatabaseService.keyBillItems);
    return items
        .where((item) => item['bill_id'] == billId)
        .map((item) => BillItem.fromMap(item))
        .toList();
  }

  // Create new bill
  Future<int?> createBill(BillModel bill) async {
    final now = DateTime.now().toIso8601String();
    final billMap = {
      'customer_id': bill.customerId,
      'worker_id': bill.workerId,
      'total_amount': bill.totalAmount,
      'discount': bill.discount,
      'tax': bill.tax,
      'final_amount': bill.finalAmount,
      'payment_method': bill.paymentMethod,
      'payment_status': bill.paymentStatus,
      'notes': bill.notes,
      'created_at': now,
    };

    final billId = await DatabaseService.insert(
      DatabaseService.keyBills,
      billMap,
    );

    if (billId > 0) {
      // Update customer total spent
      await _updateCustomerSpent(bill.customerId, bill.finalAmount);
    }

    return billId;
  }

  // Add bill item
  Future<int> addBillItem(BillItem item) async {
    return await DatabaseService.insert(
      DatabaseService.keyBillItems,
      item.toMap(),
    );
  }

  // Update bill payment status
  Future<bool> updatePaymentStatus(int billId, String status) async {
    final result = await DatabaseService.update(
      DatabaseService.keyBills,
      billId,
      {'payment_status': status},
    );
    return result > 0;
  }

  // Delete bill
  Future<bool> deleteBill(int id) async {
    // First get bill to adjust customer spent
    final bill = await getBillById(id);
    if (bill != null && bill.paymentStatus == 'paid') {
      await _updateCustomerSpent(bill.customerId, -bill.finalAmount);
    }

    // Delete bill items
    final items = await DatabaseService.getAll(DatabaseService.keyBillItems);
    for (var item in items) {
      if (item['bill_id'] == id) {
        await DatabaseService.delete(DatabaseService.keyBillItems, item['id']);
      }
    }

    // Delete bill
    final result = await DatabaseService.delete(DatabaseService.keyBills, id);
    return result > 0;
  }

  // Get today's bills
  Future<List<BillModel>> getTodayBills() async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final bills = await getAllBills();
    return bills.where((b) {
      final billDate = b.createdAt.toIso8601String().substring(0, 10);
      return billDate == today;
    }).toList();
  }

  // Get bills from date
  Future<List<BillModel>> getBillsFromDate(DateTime date) async {
    final bills = await getAllBills();
    return bills.where((b) => b.createdAt.isAfter(date)).toList();
  }

  // Get day bills
  Future<List<BillModel>> getDayBills(int year, int month, int day) async {
    final bills = await getAllBills();
    return bills.where((b) {
      return b.createdAt.year == year &&
          b.createdAt.month == month &&
          b.createdAt.day == day;
    }).toList();
  }

  // Get month bills
  Future<List<BillModel>> getMonthBills(int year, int month) async {
    final bills = await getAllBills();
    return bills.where((b) {
      return b.createdAt.year == year && b.createdAt.month == month;
    }).toList();
  }

  // Get recent bills
  Future<List<BillModel>> getRecentBills(int limit) async {
    final bills = await getAllBills();
    bills.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return bills.take(limit).toList();
  }

  // Get customer bills
  Future<List<BillModel>> getCustomerBills(int customerId) async {
    final bills = await getAllBills();
    return bills.where((b) => b.customerId == customerId).toList();
  }

  // Get worker bills
  Future<List<BillModel>> getWorkerBills(int workerId) async {
    final bills = await getAllBills();
    return bills.where((b) => b.workerId == workerId).toList();
  }

  // Helper: Update customer spent
  Future<void> _updateCustomerSpent(int customerId, double amount) async {
    final customers = await DatabaseService.getAll(
      DatabaseService.keyCustomers,
    );
    final customer = customers.firstWhere(
      (c) => c['id'] == customerId,
      orElse: () => {},
    );
    if (customer.isNotEmpty) {
      final currentSpent = (customer['total_spent'] as num?)?.toDouble() ?? 0.0;
      final newSpent = currentSpent + amount;
      await DatabaseService.update(DatabaseService.keyCustomers, customerId, {
        'total_spent': newSpent > 0 ? newSpent : 0.0,
      });
    }
  }
}
