import 'package:shared_preferences/shared_preferences.dart';
import 'database_service.dart';

class DemoDataSeeder {
  static const String _seedKey = 'demo_data_seeded_v5';

  static Future<void> seedIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final alreadySeeded = prefs.getBool(_seedKey) ?? false;

    if (alreadySeeded) {
      print('Demo data already seeded');
      return;
    }

    print('Seeding demo data...');
    await _seedAllData();
    await prefs.setBool(_seedKey, true);
    print('Demo data seeded successfully!');
  }

  static Future<void> _seedAllData() async {
    final now = DateTime.now().toIso8601String();

    // ========== 1. SEED SERVICES ==========
    final services = [
      {
        'id': 1,
        'name': 'Haircut',
        'price': 500,
        'duration': 30,
        'category': 'Hair',
        'is_active': 1,
        'is_custom': 0,
        'created_at': now,
        'updated_at': now,
      },
      {
        'id': 2,
        'name': 'Beard Trim',
        'price': 300,
        'duration': 15,
        'category': 'Beard',
        'is_active': 1,
        'is_custom': 0,
        'created_at': now,
        'updated_at': now,
      },
      {
        'id': 3,
        'name': 'Facial',
        'price': 800,
        'duration': 45,
        'category': 'Skin Care',
        'is_active': 1,
        'is_custom': 0,
        'created_at': now,
        'updated_at': now,
      },
      {
        'id': 4,
        'name': 'Hair Coloring',
        'price': 1500,
        'duration': 60,
        'category': 'Hair',
        'is_active': 1,
        'is_custom': 0,
        'created_at': now,
        'updated_at': now,
      },
      {
        'id': 5,
        'name': 'Massage',
        'price': 1000,
        'duration': 45,
        'category': 'Body',
        'is_active': 1,
        'is_custom': 0,
        'created_at': now,
        'updated_at': now,
      },
      {
        'id': 6,
        'name': 'Hair Wash',
        'price': 200,
        'duration': 10,
        'category': 'Hair',
        'is_active': 1,
        'is_custom': 0,
        'created_at': now,
        'updated_at': now,
      },
    ];
    await DatabaseService.saveAll(DatabaseService.keyServices, services);

    // ========== 2. SEED WORKERS ==========
    final workers = [
      {
        'id': 1,
        'name': 'Ali Raza',
        'phone': '03001234567',
        'role': 'Senior Barber',
        'commission_percentage': 40.0,
        'is_active': 1,
        'join_date': DateTime.now()
            .subtract(const Duration(days: 180))
            .toIso8601String(),
        'notes': 'Expert in fade haircuts',
        'created_at': now,
        'updated_at': now,
      },
      {
        'id': 2,
        'name': 'Bilal Ahmed',
        'phone': '03007654321',
        'role': 'Barber',
        'commission_percentage': 35.0,
        'is_active': 1,
        'join_date': DateTime.now()
            .subtract(const Duration(days: 120))
            .toIso8601String(),
        'notes': 'Specializes in beard styling',
        'created_at': now,
        'updated_at': now,
      },
      {
        'id': 3,
        'name': 'Rizwan Malik',
        'phone': '03009876543',
        'role': 'Junior Barber',
        'commission_percentage': 30.0,
        'is_active': 1,
        'join_date': DateTime.now()
            .subtract(const Duration(days: 60))
            .toIso8601String(),
        'notes': 'Learning advanced techniques',
        'created_at': now,
        'updated_at': now,
      },
    ];
    await DatabaseService.saveAll(DatabaseService.keyWorkers, workers);

    // ========== 3. SEED CUSTOMERS ==========
    final customers = [
      {
        'id': 1,
        'name': 'Ahmed Khan',
        'phone': '03001112222',
        'notes': 'Regular customer',
        'favorite_hairstyle': 'Taper Fade',
        'preferred_worker': 'Ali Raza',
        'is_regular': 1,
        'created_at': now,
        'updated_at': now,
        'total_spent': 12500.0,
        'visit_count': 12,
        'last_visit_date': DateTime.now()
            .subtract(const Duration(days: 3))
            .toIso8601String(),
      },
      {
        'id': 2,
        'name': 'Sara Ahmed',
        'phone': '03002223333',
        'notes': 'Loves hair coloring',
        'favorite_hairstyle': 'Balayage',
        'preferred_worker': 'Bilal Ahmed',
        'is_regular': 1,
        'created_at': now,
        'updated_at': now,
        'total_spent': 8750.0,
        'visit_count': 8,
        'last_visit_date': DateTime.now()
            .subtract(const Duration(days: 10))
            .toIso8601String(),
      },
      {
        'id': 3,
        'name': 'Usman Malik',
        'phone': '03003334444',
        'notes': 'VIP customer',
        'favorite_hairstyle': 'Classic Cut',
        'preferred_worker': 'Ali Raza',
        'is_regular': 1,
        'created_at': now,
        'updated_at': now,
        'total_spent': 23400.0,
        'visit_count': 15,
        'last_visit_date': DateTime.now()
            .subtract(const Duration(days: 2))
            .toIso8601String(),
      },
      {
        'id': 4,
        'name': 'Fatima Riaz',
        'phone': '03004445555',
        'notes': 'Allergic to products',
        'favorite_hairstyle': 'Layer Cut',
        'preferred_worker': 'Rizwan Malik',
        'is_regular': 0,
        'created_at': now,
        'updated_at': now,
        'total_spent': 3200.0,
        'visit_count': 3,
        'last_visit_date': DateTime.now()
            .subtract(const Duration(days: 15))
            .toIso8601String(),
      },
      {
        'id': 5,
        'name': 'Hassan Shah',
        'phone': '03005556666',
        'notes': 'Weekly customer',
        'favorite_hairstyle': 'Skin Fade',
        'preferred_worker': 'Bilal Ahmed',
        'is_regular': 1,
        'created_at': now,
        'updated_at': now,
        'total_spent': 15600.0,
        'visit_count': 18,
        'last_visit_date': DateTime.now()
            .subtract(const Duration(days: 5))
            .toIso8601String(),
      },
    ];
    await DatabaseService.saveAll(DatabaseService.keyCustomers, customers);

    // ========== 4. SEED BILLS ==========
    final bills = [
      {
        'id': 1,
        'customer_id': 1,
        'worker_id': 1,
        'total_amount': 800,
        'discount': 0,
        'tax': 0,
        'final_amount': 800,
        'payment_method': 'Cash',
        'payment_status': 'paid',
        'notes': 'Regular customer',
        'created_at': DateTime.now()
            .subtract(const Duration(days: 2))
            .toIso8601String(),
      },
      {
        'id': 2,
        'customer_id': 2,
        'worker_id': 2,
        'total_amount': 1700,
        'discount': 100,
        'tax': 0,
        'final_amount': 1600,
        'payment_method': 'JazzCash',
        'payment_status': 'paid',
        'notes': 'Color touch-up',
        'created_at': DateTime.now()
            .subtract(const Duration(days: 5))
            .toIso8601String(),
      },
      {
        'id': 3,
        'customer_id': 3,
        'worker_id': 1,
        'total_amount': 2800,
        'discount': 200,
        'tax': 0,
        'final_amount': 2600,
        'payment_method': 'EasyPaisa',
        'payment_status': 'paid',
        'notes': 'VIP service',
        'created_at': DateTime.now()
            .subtract(const Duration(days: 1))
            .toIso8601String(),
      },
      {
        'id': 4,
        'customer_id': 4,
        'worker_id': 3,
        'total_amount': 800,
        'discount': 0,
        'tax': 0,
        'final_amount': 800,
        'payment_method': 'Cash',
        'payment_status': 'paid',
        'notes': 'First facial',
        'created_at': DateTime.now()
            .subtract(const Duration(days: 10))
            .toIso8601String(),
      },
      {
        'id': 5,
        'customer_id': 5,
        'worker_id': 2,
        'total_amount': 1800,
        'discount': 150,
        'tax': 0,
        'final_amount': 1650,
        'payment_method': 'Cash',
        'payment_status': 'paid',
        'notes': 'Weekly visit',
        'created_at': DateTime.now()
            .subtract(const Duration(days: 3))
            .toIso8601String(),
      },
    ];
    await DatabaseService.saveAll(DatabaseService.keyBills, bills);

    // ========== 5. SEED BILL ITEMS ==========
    final billItems = [
      {
        'id': 1,
        'bill_id': 1,
        'service_id': 1,
        'service_name': 'Haircut',
        'price': 500,
        'quantity': 1,
        'total': 500,
      },
      {
        'id': 2,
        'bill_id': 1,
        'service_id': 2,
        'service_name': 'Beard Trim',
        'price': 300,
        'quantity': 1,
        'total': 300,
      },
      {
        'id': 3,
        'bill_id': 2,
        'service_id': 4,
        'service_name': 'Hair Coloring',
        'price': 1500,
        'quantity': 1,
        'total': 1500,
      },
      {
        'id': 4,
        'bill_id': 2,
        'service_id': 6,
        'service_name': 'Hair Wash',
        'price': 200,
        'quantity': 1,
        'total': 200,
      },
      {
        'id': 5,
        'bill_id': 3,
        'service_id': 1,
        'service_name': 'Haircut',
        'price': 500,
        'quantity': 1,
        'total': 500,
      },
      {
        'id': 6,
        'bill_id': 3,
        'service_id': 2,
        'service_name': 'Beard Trim',
        'price': 300,
        'quantity': 1,
        'total': 300,
      },
      {
        'id': 7,
        'bill_id': 3,
        'service_id': 3,
        'service_name': 'Facial',
        'price': 800,
        'quantity': 1,
        'total': 800,
      },
      {
        'id': 8,
        'bill_id': 3,
        'service_id': 5,
        'service_name': 'Massage',
        'price': 1000,
        'quantity': 1,
        'total': 1000,
      },
      {
        'id': 9,
        'bill_id': 5,
        'service_id': 1,
        'service_name': 'Haircut',
        'price': 500,
        'quantity': 1,
        'total': 500,
      },
      {
        'id': 10,
        'bill_id': 5,
        'service_id': 2,
        'service_name': 'Beard Trim',
        'price': 300,
        'quantity': 1,
        'total': 300,
      },
      {
        'id': 11,
        'bill_id': 5,
        'service_id': 5,
        'service_name': 'Massage',
        'price': 1000,
        'quantity': 1,
        'total': 1000,
      },
    ];
    await DatabaseService.saveAll(DatabaseService.keyBillItems, billItems);

    // ========== 6. SEED UDHAAR ==========
    final udhaar = [
      {
        'id': 1,
        'customer_id': 2,
        'total_amount': 2000,
        'paid_amount': 500,
        'due_date': DateTime.now()
            .add(const Duration(days: 15))
            .toIso8601String(),
        'status': 'pending',
        'notes': 'Hair coloring service',
        'created_at': now,
        'updated_at': now,
      },
    ];
    await DatabaseService.saveAll(DatabaseService.keyUdhaar, udhaar);

    // ========== 7. SEED UDHAAR PAYMENTS ==========
    final udhaarPayments = [
      {
        'id': 1,
        'udhaar_id': 1,
        'amount': 500,
        'payment_date': DateTime.now()
            .subtract(const Duration(days: 2))
            .toIso8601String(),
        'payment_method': 'Cash',
        'notes': 'First payment',
        'created_at': now,
      },
    ];
    await DatabaseService.saveAll(
      DatabaseService.keyUdhaarPayments,
      udhaarPayments,
    );

    // ========== 8. SEED VISITS ==========
    final visits = [
      {
        'id': 1,
        'customer_id': 1,
        'worker_id': 1,
        'visit_date': DateTime.now()
            .subtract(const Duration(days: 2))
            .toIso8601String(),
        'services': 'Haircut, Beard Trim',
        'service_ids': '1,2',
        'total_amount': 800,
        'payment_status': 'paid',
        'payment_method': 'Cash',
        'notes': 'Regular haircut',
        'created_at': now,
      },
      {
        'id': 2,
        'customer_id': 2,
        'worker_id': 2,
        'visit_date': DateTime.now()
            .subtract(const Duration(days: 5))
            .toIso8601String(),
        'services': 'Hair Coloring',
        'service_ids': '4',
        'total_amount': 1700,
        'payment_status': 'paid',
        'payment_method': 'JazzCash',
        'notes': 'Color touch-up',
        'created_at': now,
      },
      {
        'id': 3,
        'customer_id': 3,
        'worker_id': 1,
        'visit_date': DateTime.now()
            .subtract(const Duration(days: 1))
            .toIso8601String(),
        'services': 'Haircut, Beard Trim, Facial, Massage',
        'service_ids': '1,2,3,5',
        'total_amount': 2600,
        'payment_status': 'paid',
        'payment_method': 'EasyPaisa',
        'notes': 'VIP service',
        'created_at': now,
      },
    ];
    await DatabaseService.saveAll(DatabaseService.keyVisits, visits);

    // ========== 9. SEED EXPENSES ==========
    final expenses = [
      {
        'id': 1,
        'category': 'Rent',
        'amount': 50000,
        'description': 'Monthly shop rent',
        'expense_date': DateTime.now()
            .subtract(const Duration(days: 5))
            .toIso8601String(),
        'payment_method': 'Bank Transfer',
        'created_at': now,
        'updated_at': now,
      },
      {
        'id': 2,
        'category': 'Utilities',
        'amount': 8500,
        'description': 'Electricity bill',
        'expense_date': DateTime.now()
            .subtract(const Duration(days: 10))
            .toIso8601String(),
        'payment_method': 'Bank Transfer',
        'created_at': now,
        'updated_at': now,
      },
      {
        'id': 3,
        'category': 'Supplies',
        'amount': 12000,
        'description': 'Hair products',
        'expense_date': DateTime.now()
            .subtract(const Duration(days: 3))
            .toIso8601String(),
        'payment_method': 'Cash',
        'created_at': now,
        'updated_at': now,
      },
    ];
    await DatabaseService.saveAll(DatabaseService.keyExpenses, expenses);

    // ========== 10. SEED SHOP SETTINGS ==========
    final shopSettings = [
      {
        'id': 1,
        'shop_name': 'The Barber Demo',
        'owner_name': 'Demo Owner',
        'phone': '03001234567',
        'address': '123 Main Street',
        'email': 'demo@thebarber.com',
        'currency': 'PKR',
        'working_hours': 'Mon-Sat: 10AM-9PM',
        'created_at': now,
        'updated_at': now,
      },
    ];
    await DatabaseService.saveAll(
      DatabaseService.keyShopSettings,
      shopSettings,
    );

    print('Demo data seeding completed!');
  }
}
