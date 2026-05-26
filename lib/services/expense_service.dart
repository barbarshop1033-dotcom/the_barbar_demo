import '../models/expense_model.dart';
import 'database_service.dart';

class ExpenseService {
  // Get all expenses
  Future<List<ExpenseModel>> getAllExpenses() async {
    final maps = await DatabaseService.getAll(DatabaseService.keyExpenses);
    maps.sort(
      (a, b) => (b['expense_date'] ?? '').compareTo(a['expense_date'] ?? ''),
    );
    return maps.map((map) => ExpenseModel.fromMap(map)).toList();
  }

  // Get expense by ID
  Future<ExpenseModel?> getExpenseById(int id) async {
    final maps = await DatabaseService.getAll(DatabaseService.keyExpenses);
    final map = maps.firstWhere((e) => e['id'] == id, orElse: () => {});
    if (map.isEmpty) return null;
    return ExpenseModel.fromMap(map);
  }

  // Add expense
  Future<int> addExpense(ExpenseModel expense) async {
    final now = DateTime.now().toIso8601String();
    final expenseMap = {
      ...expense.toMap(),
      'created_at': now,
      'updated_at': now,
    };
    expenseMap.remove('id');
    return await DatabaseService.insert(
      DatabaseService.keyExpenses,
      expenseMap,
    );
  }

  // Update expense
  Future<bool> updateExpense(ExpenseModel expense) async {
    final updatedMap = {
      ...expense.toMap(),
      'updated_at': DateTime.now().toIso8601String(),
    };
    final result = await DatabaseService.update(
      DatabaseService.keyExpenses,
      expense.id!,
      updatedMap,
    );
    return result > 0;
  }

  // Delete expense
  Future<bool> deleteExpense(int id) async {
    final result = await DatabaseService.delete(
      DatabaseService.keyExpenses,
      id,
    );
    return result > 0;
  }

  // Get expenses by category
  Future<List<ExpenseModel>> getExpensesByCategory(String category) async {
    final expenses = await getAllExpenses();
    return expenses.where((e) => e.category == category).toList();
  }

  // Get expenses by date range
  Future<List<ExpenseModel>> getExpensesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final expenses = await getAllExpenses();
    return expenses.where((e) {
      return e.expenseDate.isAfter(startDate) &&
          e.expenseDate.isBefore(endDate);
    }).toList();
  }

  // Get today's expenses
  Future<List<ExpenseModel>> getTodayExpenses() async {
    final expenses = await getAllExpenses();
    final today = DateTime.now();
    return expenses.where((e) {
      return e.expenseDate.year == today.year &&
          e.expenseDate.month == today.month &&
          e.expenseDate.day == today.day;
    }).toList();
  }

  // Get month expenses
  Future<List<ExpenseModel>> getMonthExpenses(int year, int month) async {
    final expenses = await getAllExpenses();
    return expenses.where((e) {
      return e.expenseDate.year == year && e.expenseDate.month == month;
    }).toList();
  }

  // Get total expenses
  Future<double> getTotalExpenses({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    var expenses = await getAllExpenses();
    if (startDate != null && endDate != null) {
      expenses = expenses.where((e) {
        return e.expenseDate.isAfter(startDate) &&
            e.expenseDate.isBefore(endDate);
      }).toList();
    }
    // FIXED: Replace fold with for loop
    double total = 0.0;
    for (var e in expenses) {
      total += e.amount;
    }
    return total;
  }

  // Get categories
  Future<List<String>> getCategories() async {
    final expenses = await getAllExpenses();
    final categories = expenses.map((e) => e.category).toSet().toList();
    categories.sort();
    return categories;
  }

  // Search expenses
  Future<List<ExpenseModel>> searchExpenses(String query) async {
    final expenses = await getAllExpenses();
    final lowerQuery = query.toLowerCase();
    return expenses.where((e) {
      return e.category.toLowerCase().contains(lowerQuery) ||
          (e.description?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  // Get expense summary by category
  Future<Map<String, double>> getExpenseSummaryByCategory(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final expenses = await getExpensesByDateRange(startDate, endDate);
    final Map<String, double> summary = {};
    for (var expense in expenses) {
      summary[expense.category] =
          (summary[expense.category] ?? 0) + expense.amount;
    }
    return summary;
  }

  // Get daily expense totals
  Future<Map<String, double>> getDailyExpenseTotals(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final expenses = await getExpensesByDateRange(startDate, endDate);
    final Map<String, double> dailyTotals = {};
    for (var expense in expenses) {
      final dateStr = '${expense.expenseDate.day}/${expense.expenseDate.month}';
      dailyTotals[dateStr] = (dailyTotals[dateStr] ?? 0) + expense.amount;
    }
    return dailyTotals;
  }

  // Get expense stats
  Future<Map<String, dynamic>> getExpenseStats({int months = 12}) async {
    final startDate = DateTime.now().subtract(Duration(days: months * 30));
    final expenses = await getExpensesByDateRange(startDate, DateTime.now());

    // FIXED: Replace fold with for loop
    double totalAmount = 0.0;
    for (var e in expenses) {
      totalAmount += e.amount;
    }

    final avgAmount = expenses.isEmpty ? 0 : totalAmount / expenses.length;

    // FIXED: Replace reduce with explicit loop
    double maxAmount = 0.0;
    double minAmount = 0.0;
    if (expenses.isNotEmpty) {
      maxAmount = expenses[0].amount;
      minAmount = expenses[0].amount;
      for (var e in expenses) {
        if (e.amount > maxAmount) maxAmount = e.amount;
        if (e.amount < minAmount) minAmount = e.amount;
      }
    }

    return {
      'totalCount': expenses.length,
      'totalAmount': totalAmount,
      'averageAmount': avgAmount,
      'maxAmount': maxAmount,
      'minAmount': minAmount,
    };
  }
}
