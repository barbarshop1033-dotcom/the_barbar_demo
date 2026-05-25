import 'package:flutter/material.dart';
import '../models/bill_model.dart';
import '../services/bill_service.dart';

class BillProvider extends ChangeNotifier {
  final BillService _billService = BillService();

  List<BillModel> _bills = [];
  bool _isLoading = false;
  String? _error;
  String _paymentFilter = 'all'; // 'all', 'paid', 'unpaid', 'partial'

  List<BillModel> get bills {
    if (_paymentFilter != 'all') {
      return _bills.where((b) => b.paymentStatus == _paymentFilter).toList();
    }
    return _bills;
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  String get paymentFilter => _paymentFilter;

  // Today's stats
  List<BillModel> get todayBills {
    final now = DateTime.now();
    return _bills.where((b) {
      return b.createdAt.year == now.year &&
          b.createdAt.month == now.month &&
          b.createdAt.day == now.day;
    }).toList();
  }

  double get todayEarnings =>
      todayBills.fold(0, (sum, b) => sum + b.finalAmount);
  int get todayBillCount => todayBills.length;

  // Weekly stats
  List<BillModel> get weekBills {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    return _bills.where((b) => b.createdAt.isAfter(weekAgo)).toList();
  }

  double get weekEarnings => weekBills.fold(0, (sum, b) => sum + b.finalAmount);

  // Monthly stats
  List<BillModel> get monthBills {
    final now = DateTime.now();
    return _bills.where((b) {
      return b.createdAt.year == now.year && b.createdAt.month == now.month;
    }).toList();
  }

  double get monthEarnings =>
      monthBills.fold(0, (sum, b) => sum + b.finalAmount);

  Future<void> loadBills() async {
    _isLoading = true;
    notifyListeners();

    try {
      _bills = await _billService.getAllBills();
      _error = null;
    } catch (e) {
      _error = 'Failed to load bills';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<BillModel?> getBillById(int id) async {
    try {
      final bill = await _billService.getBillById(id);
      if (bill != null) {
        final items = await _billService.getBillItems(id);
        return bill.copyWith(items: items);
      }
      return null;
    } catch (e) {
      _error = 'Failed to load bill';
      notifyListeners();
      return null;
    }
  }

  Future<List<BillModel>> getCustomerBills(int customerId) async {
    try {
      return await _billService.getCustomerBills(customerId);
    } catch (e) {
      _error = 'Failed to load customer bills';
      notifyListeners();
      return [];
    }
  }

  Future<int?> createBill(BillModel bill) async {
    try {
      _error = null;

      // Validate required fields
      if (bill.customerId <= 0) {
        _error = 'Invalid customer selected';
        notifyListeners();
        return null;
      }

      if (bill.items.isEmpty) {
        _error = 'No services selected';
        notifyListeners();
        return null;
      }

      // Create the bill in database
      final billId = await _billService.createBill(bill);

      if (billId != null && billId > 0) {
        // Insert bill items with the correct bill ID
        for (var item in bill.items) {
          await _billService.addBillItem(item.copyWith(billId: billId));
        }

        // Reload bills to refresh the list
        await loadBills();

        return billId;
      } else {
        _error = 'Failed to create bill - no ID returned';
        notifyListeners();
        return null;
      }
    } catch (e) {
      _error = 'Failed to create bill: ${e.toString()}';
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateBillPaymentStatus(int billId, String status) async {
    try {
      final updated = await _billService.updatePaymentStatus(billId, status);
      if (updated) {
        final index = _bills.indexWhere((b) => b.id == billId);
        if (index != -1) {
          _bills[index] = _bills[index].copyWith(paymentStatus: status);
        }
        _error = null;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _error = 'Failed to update payment status';
      notifyListeners();
    }
    return false;
  }

  Future<bool> deleteBill(int id) async {
    try {
      final deleted = await _billService.deleteBill(id);
      if (deleted) {
        _bills.removeWhere((b) => b.id == id);
        _error = null;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _error = 'Failed to delete bill';
      notifyListeners();
    }
    return false;
  }

  void setPaymentFilter(String filter) {
    _paymentFilter = filter;
    notifyListeners();
  }

  Map<String, double> getDailyEarnings(int days) {
    final Map<String, double> earnings = {};
    final now = DateTime.now();

    for (int i = days - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateStr = '${date.day}/${date.month}';
      final dayBills = _bills.where((b) {
        return b.createdAt.year == date.year &&
            b.createdAt.month == date.month &&
            b.createdAt.day == date.day;
      });
      earnings[dateStr] = dayBills.fold(0, (sum, b) => sum + b.finalAmount);
    }

    return earnings;
  }

  Map<String, double> getMonthlyEarnings(int months) {
    final Map<String, double> earnings = {};
    final now = DateTime.now();

    for (int i = months - 1; i >= 0; i--) {
      final date = DateTime(now.year, now.month - i, 1);
      final monthStr = '${date.month}/${date.year}';
      final monthBills = _bills.where((b) {
        return b.createdAt.year == date.year && b.createdAt.month == date.month;
      });
      earnings[monthStr] = monthBills.fold(0, (sum, b) => sum + b.finalAmount);
    }

    return earnings;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
