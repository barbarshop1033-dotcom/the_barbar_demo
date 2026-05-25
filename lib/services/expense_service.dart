import 'package:sqflite/sqflite.dart';
import '../models/expense_model.dart';
import 'database_service.dart';

class ExpenseService {
  // Get database instance
  Future<Database> get _db async => DatabaseService.database;

  // Get all expenses
  Future<List<ExpenseModel>> getAllExpenses() async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'expenses',
      orderBy: 'expense_date DESC',
    );
    return maps.map((map) => ExpenseModel.fromMap(map)).toList();
  }

  // Get expense by ID
  Future<ExpenseModel?> getExpenseById(int id) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return ExpenseModel.fromMap(maps.first);
  }

  // Add new expense
  Future<int> addExpense(ExpenseModel expense) async {
    final db = await _db;
    return await db.insert('expenses', expense.toMap());
  }

  // Update expense
  Future<bool> updateExpense(ExpenseModel expense) async {
    final db = await _db;
    final updated = expense.copyWith(updatedAt: DateTime.now());
    final count = await db.update(
      'expenses',
      updated.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
    return count > 0;
  }

  // Delete expense
  Future<bool> deleteExpense(int id) async {
    final db = await _db;
    final count = await db.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
    return count > 0;
  }

  // Get expenses by category
  Future<List<ExpenseModel>> getExpensesByCategory(String category) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'expenses',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'expense_date DESC',
    );
    return maps.map((map) => ExpenseModel.fromMap(map)).toList();
  }

  // Get expenses by date range
  Future<List<ExpenseModel>> getExpensesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'expenses',
      where: 'expense_date >= ? AND expense_date <= ?',
      whereArgs: [
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ],
      orderBy: 'expense_date DESC',
    );
    return maps.map((map) => ExpenseModel.fromMap(map)).toList();
  }

  // Get today's expenses
  Future<List<ExpenseModel>> getTodayExpenses() async {
    final now = DateTime.now();
    return await getExpensesByDateRange(
      DateTime(now.year, now.month, now.day),
      DateTime(now.year, now.month, now.day, 23, 59, 59),
    );
  }

  // Get month expenses
  Future<List<ExpenseModel>> getMonthExpenses(int year, int month) async {
    return await getExpensesByDateRange(
      DateTime(year, month, 1),
      DateTime(year, month + 1, 0, 23, 59, 59),
    );
  }

  // Get total expenses by category for a period
  Future<Map<String, double>> getExpenseSummaryByCategory(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await _db;
    final result = await db.rawQuery('''
      SELECT category, SUM(amount) as total
      FROM expenses
      WHERE expense_date >= ? AND expense_date <= ?
      GROUP BY category
      ORDER BY total DESC
    ''', [startDate.toIso8601String(), endDate.toIso8601String()]);

    final Map<String, double> summary = {};
    for (var row in result) {
      summary[row['category'] as String] = (row['total'] as num).toDouble();
    }
    return summary;
  }

  // Get daily expense totals for a period
  Future<Map<String, double>> getDailyExpenseTotals(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await _db;
    final result = await db.rawQuery('''
      SELECT expense_date, SUM(amount) as total
      FROM expenses
      WHERE expense_date >= ? AND expense_date <= ?
      GROUP BY expense_date
      ORDER BY expense_date ASC
    ''', [startDate.toIso8601String(), endDate.toIso8601String()]);

    final Map<String, double> dailyTotals = {};
    for (var row in result) {
      final date = DateTime.parse(row['expense_date'] as String);
      final dateStr = '${date.day}/${date.month}';
      dailyTotals[dateStr] = (row['total'] as num).toDouble();
    }
    return dailyTotals;
  }

  // Get total expenses amount
  Future<double> getTotalExpenses(
      {DateTime? startDate, DateTime? endDate}) async {
    final db = await _db;

    if (startDate != null && endDate != null) {
      final result = await db.rawQuery('''
        SELECT SUM(amount) as total
        FROM expenses
        WHERE expense_date >= ? AND expense_date <= ?
      ''', [startDate.toIso8601String(), endDate.toIso8601String()]);
      return (result.first['total'] as num?)?.toDouble() ?? 0.0;
    } else {
      final result =
          await db.rawQuery('SELECT SUM(amount) as total FROM expenses');
      return (result.first['total'] as num?)?.toDouble() ?? 0.0;
    }
  }

  // Get all expense categories used
  Future<List<String>> getCategories() async {
    final db = await _db;
    final result = await db
        .rawQuery('SELECT DISTINCT category FROM expenses ORDER BY category');
    return result.map((row) => row['category'] as String).toList();
  }

  // Search expenses by description
  Future<List<ExpenseModel>> searchExpenses(String query) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'expenses',
      where: 'description LIKE ? OR category LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'expense_date DESC',
    );
    return maps.map((map) => ExpenseModel.fromMap(map)).toList();
  }

  // Get expense statistics
  Future<Map<String, dynamic>> getExpenseStats({int months = 12}) async {
    final db = await _db;
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month - months + 1, 1);

    final stats = await db.rawQuery('''
      SELECT 
        COUNT(*) as total_count,
        SUM(amount) as total_amount,
        AVG(amount) as average_amount,
        MAX(amount) as max_amount,
        MIN(amount) as min_amount
      FROM expenses
      WHERE expense_date >= ?
    ''', [startDate.toIso8601String()]);

    if (stats.isEmpty) {
      return {
        'totalCount': 0,
        'totalAmount': 0.0,
        'averageAmount': 0.0,
        'maxAmount': 0.0,
        'minAmount': 0.0,
      };
    }

    final row = stats.first;
    return {
      'totalCount': row['total_count'] ?? 0,
      'totalAmount': (row['total_amount'] as num?)?.toDouble() ?? 0.0,
      'averageAmount': (row['average_amount'] as num?)?.toDouble() ?? 0.0,
      'maxAmount': (row['max_amount'] as num?)?.toDouble() ?? 0.0,
      'minAmount': (row['min_amount'] as num?)?.toDouble() ?? 0.0,
    };
  }
}
