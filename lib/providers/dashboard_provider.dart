import 'package:flutter/material.dart';
import '../models/customer_model.dart';
import '../models/bill_model.dart';
import '../models/udhaar_model.dart';
import '../models/visit_model.dart';
import '../services/customer_service.dart';
import '../services/bill_service.dart';
import '../services/udhaar_service.dart';
import '../services/visit_service.dart';

class DashboardProvider extends ChangeNotifier {
  final CustomerService _customerService = CustomerService();
  final BillService _billService = BillService();
  final UdhaarService _udhaarService = UdhaarService();
  final VisitService _visitService = VisitService();

  bool _isLoading = false;
  String? _error;

  // Dashboard stats
  double _todayEarnings = 0;
  int _todayCustomers = 0;
  int _todayBills = 0;
  double _pendingUdhaar = 0;
  int _totalServices = 0;
  double _monthlyEarnings = 0;
  double _weeklyEarnings = 0;

  List<CustomerModel> _recentCustomers = [];
  List<BillModel> _recentBills = [];
  List<VisitModel> _todayVisits = [];

  bool get isLoading => _isLoading;
  String? get error => _error;

  double get todayEarnings => _todayEarnings;
  int get todayCustomers => _todayCustomers;
  int get todayBills => _todayBills;
  double get pendingUdhaar => _pendingUdhaar;
  int get totalServices => _totalServices;
  double get monthlyEarnings => _monthlyEarnings;
  double get weeklyEarnings => _weeklyEarnings;

  List<CustomerModel> get recentCustomers => _recentCustomers;
  List<BillModel> get recentBills => _recentBills;
  List<VisitModel> get todayVisits => _todayVisits;

  Future<void> loadDashboardData() async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.wait([
        _loadTodayEarnings(),
        _loadTodayCustomers(),
        _loadPendingUdhaar(),
        _loadRecentCustomers(),
        _loadRecentBills(),
        _loadTodayVisits(),
        _loadMonthlyEarnings(),
        _loadWeeklyEarnings(),
      ]);
    } catch (e) {
      _error = 'Failed to load dashboard data';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadTodayEarnings() async {
    final bills = await _billService.getTodayBills();
    _todayEarnings = bills.fold(0, (sum, b) => sum + b.finalAmount);
    _todayBills = bills.length;
  }

  Future<void> _loadTodayCustomers() async {
    final bills = await _billService.getTodayBills();
    final customerIds = bills.map((b) => b.customerId).toSet();
    _todayCustomers = customerIds.length;
  }

  Future<void> _loadPendingUdhaar() async {
    final udhaars = await _udhaarService.getAllUdhaar();
    _pendingUdhaar = udhaars
        .where((u) => u.status != 'paid')
        .fold(0, (sum, u) => sum + (u.totalAmount - u.paidAmount));
  }

  Future<void> _loadRecentCustomers() async {
    _recentCustomers = await _customerService.getRecentCustomers(10);
  }

  Future<void> _loadRecentBills() async {
    _recentBills = await _billService.getRecentBills(10);
  }

  Future<void> _loadTodayVisits() async {
    _todayVisits = await _visitService.getTodayVisits();
    _totalServices = _todayVisits.fold(0, (sum, v) => sum + v.services.length);
  }

  Future<void> _loadMonthlyEarnings() async {
    final now = DateTime.now();
    final bills = await _billService.getMonthBills(now.year, now.month);
    _monthlyEarnings = bills.fold(0, (sum, b) => sum + b.finalAmount);
  }

  Future<void> _loadWeeklyEarnings() async {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    final bills = await _billService.getBillsFromDate(weekAgo);
    _weeklyEarnings = bills.fold(0, (sum, b) => sum + b.finalAmount);
  }

  // Get revenue trend data for charts
  Future<Map<String, double>> getWeeklyTrend() async {
    final Map<String, double> trend = {};
    final now = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateStr = '${date.day}/${date.month}';
      final bills =
          await _billService.getDayBills(date.year, date.month, date.day);
      trend[dateStr] = bills.fold(0, (sum, b) => sum + b.finalAmount);
    }

    return trend;
  }

  Future<Map<String, int>> getPopularServices() async {
    final visits = await _visitService.getMonthVisits(
      DateTime.now().year,
      DateTime.now().month,
    );

    final Map<String, int> serviceCount = {};
    for (var visit in visits) {
      for (var service in visit.services) {
        serviceCount[service] = (serviceCount[service] ?? 0) + 1;
      }
    }

    return serviceCount;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
