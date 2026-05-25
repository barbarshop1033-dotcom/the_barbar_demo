import 'package:flutter/material.dart';
import '../models/expense_model.dart';
import '../services/expense_service.dart';

class ExpenseProvider extends ChangeNotifier {
  final ExpenseService _expenseService = ExpenseService();

  List<ExpenseModel> _expenses = [];
  bool _isLoading = false;
  String? _error;
  String _categoryFilter = 'All';
  String _periodFilter = 'All'; // 'All', 'Today', 'This Week', 'This Month'

  List<ExpenseModel> get expenses {
    List<ExpenseModel> filtered = List.from(_expenses);

    // Apply category filter
    if (_categoryFilter != 'All') {
      filtered = filtered.where((e) => e.category == _categoryFilter).toList();
    }

    // Apply period filter
    final now = DateTime.now();
    switch (_periodFilter) {
      case 'Today':
        filtered = filtered.where((e) {
          return e.expenseDate.year == now.year &&
              e.expenseDate.month == now.month &&
              e.expenseDate.day == now.day;
        }).toList();
        break;
      case 'This Week':
        final weekAgo = now.subtract(const Duration(days: 7));
        filtered =
            filtered.where((e) => e.expenseDate.isAfter(weekAgo)).toList();
        break;
      case 'This Month':
        filtered = filtered.where((e) {
          return e.expenseDate.year == now.year &&
              e.expenseDate.month == now.month;
        }).toList();
        break;
    }

    // Sort by date (newest first)
    filtered.sort((a, b) => b.expenseDate.compareTo(a.expenseDate));

    return filtered;
  }

  List<ExpenseModel> get allExpenses => _expenses;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get categoryFilter => _categoryFilter;
  String get periodFilter => _periodFilter;

  double get totalExpenses => _expenses.fold(0, (sum, e) => sum + e.amount);
  double get todayExpenses {
    final now = DateTime.now();
    return _expenses
        .where((e) =>
            e.expenseDate.year == now.year &&
            e.expenseDate.month == now.month &&
            e.expenseDate.day == now.day)
        .fold(0, (sum, e) => sum + e.amount);
  }

  double get monthExpenses {
    final now = DateTime.now();
    return _expenses
        .where((e) =>
            e.expenseDate.year == now.year && e.expenseDate.month == now.month)
        .fold(0, (sum, e) => sum + e.amount);
  }

  List<String> get categories {
    final cats = _expenses.map((e) => e.category).toSet().toList();
    cats.sort();
    return ['All', ...cats];
  }

  Future<void> loadExpenses() async {
    _isLoading = true;
    notifyListeners();

    try {
      _expenses = await _expenseService.getAllExpenses();
    } catch (e) {
      _error = 'Failed to load expenses';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addExpense(ExpenseModel expense) async {
    try {
      final id = await _expenseService.addExpense(expense);
      if (id > 0) {
        _expenses.add(expense.copyWith(id: id));
        notifyListeners();
        return true;
      }
    } catch (e) {
      _error = 'Failed to add expense';
      notifyListeners();
    }
    return false;
  }

  Future<bool> updateExpense(ExpenseModel expense) async {
    try {
      final updated = await _expenseService.updateExpense(expense);
      if (updated) {
        final index = _expenses.indexWhere((e) => e.id == expense.id);
        if (index != -1) {
          _expenses[index] = expense;
        }
        notifyListeners();
        return true;
      }
    } catch (e) {
      _error = 'Failed to update expense';
      notifyListeners();
    }
    return false;
  }

  Future<bool> deleteExpense(int id) async {
    try {
      final deleted = await _expenseService.deleteExpense(id);
      if (deleted) {
        _expenses.removeWhere((e) => e.id == id);
        notifyListeners();
        return true;
      }
    } catch (e) {
      _error = 'Failed to delete expense';
      notifyListeners();
    }
    return false;
  }

  Map<String, double> getExpensesByCategory() {
    final Map<String, double> categoryExpenses = {};
    for (var expense in _expenses) {
      categoryExpenses[expense.category] =
          (categoryExpenses[expense.category] ?? 0) + expense.amount;
    }
    return categoryExpenses;
  }

  Map<String, double> getExpensesByDay(int days) {
    final Map<String, double> dailyExpenses = {};
    final now = DateTime.now();

    for (int i = days - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateStr = '${date.day}/${date.month}';
      final dayExpenses = _expenses.where((e) {
        return e.expenseDate.year == date.year &&
            e.expenseDate.month == date.month &&
            e.expenseDate.day == date.day;
      });
      dailyExpenses[dateStr] = dayExpenses.fold(0, (sum, e) => sum + e.amount);
    }

    return dailyExpenses;
  }

  void setCategoryFilter(String category) {
    _categoryFilter = category;
    notifyListeners();
  }

  void setPeriodFilter(String period) {
    _periodFilter = period;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
