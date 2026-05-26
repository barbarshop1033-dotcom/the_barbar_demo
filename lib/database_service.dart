import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DatabaseService {
  static SharedPreferences? _prefs;
  static bool _isInitialized = false;

  // Public keys for other services
  static const String keyCustomers = 'demo_customers';
  static const String keyServices = 'demo_services';
  static const String keyWorkers = 'demo_workers';
  static const String keyBills = 'demo_bills';
  static const String keyBillItems = 'demo_bill_items';
  static const String keyUdhaar = 'demo_udhaar';
  static const String keyUdhaarPayments = 'demo_udhaar_payments';
  static const String keyVisits = 'demo_visits';
  static const String keyExpenses = 'demo_expenses';
  static const String keyShopSettings = 'demo_shop_settings';

  static Future<void> initialize() async {
    if (_isInitialized) return;
    _prefs = await SharedPreferences.getInstance();
    _isInitialized = true;
  }

  static SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception(
        'DatabaseService not initialized. Call initialize() first.',
      );
    }
    return _prefs!;
  }

  // ========== GENERIC CRUD OPERATIONS ==========

  static Future<List<Map<String, dynamic>>> getAll(String key) async {
    final jsonString = prefs.getString(key);
    if (jsonString == null) return [];
    final List<dynamic> list = jsonDecode(jsonString);
    return list.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  static Future<void> saveAll(
    String key,
    List<Map<String, dynamic>> data,
  ) async {
    await prefs.setString(key, jsonEncode(data));
  }

  static Future<int> insert(String key, Map<String, dynamic> data) async {
    final items = await getAll(key);
    final newId = items.isEmpty ? 1 : (items.last['id'] as int) + 1;
    final newItem = {...data, 'id': newId};
    items.add(newItem);
    await saveAll(key, items);
    return newId;
  }

  static Future<int> update(
    String key,
    int id,
    Map<String, dynamic> data,
  ) async {
    final items = await getAll(key);
    final index = items.indexWhere((item) => item['id'] == id);
    if (index != -1) {
      items[index] = {...items[index], ...data, 'id': id};
      await saveAll(key, items);
      return 1;
    }
    return 0;
  }

  static Future<int> delete(String key, int id) async {
    final items = await getAll(key);
    final index = items.indexWhere((item) => item['id'] == id);
    if (index != -1) {
      items.removeAt(index);
      await saveAll(key, items);
      return 1;
    }
    return 0;
  }

  static Future<Map<String, dynamic>?> getById(String key, int id) async {
    final items = await getAll(key);
    try {
      return items.firstWhere((item) => item['id'] == id);
    } catch (e) {
      return null;
    }
  }
}
