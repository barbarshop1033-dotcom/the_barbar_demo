import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static Database? _database;
  static final DatabaseService instance = DatabaseService._internal();

  DatabaseService._internal();

  static Future<void> initialize() async {
    if (_database != null) return;
    _database = await _initDatabase();
  }

  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'barber_shop.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createTables,
      onUpgrade: _onUpgrade,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  static Future<void> _createTables(Database db, int version) async {
    // Create customers table
    await db.execute('''
      CREATE TABLE customers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT NOT NULL UNIQUE,
        photo_path TEXT,
        notes TEXT,
        favorite_hairstyle TEXT,
        preferred_worker TEXT,
        is_regular INTEGER DEFAULT 0,
        allergy_notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        total_spent REAL DEFAULT 0.0,
        last_visit_date TEXT,
        visit_count INTEGER DEFAULT 0
      )
    ''');

    // Create services table
    await db.execute('''
      CREATE TABLE services (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        price REAL NOT NULL,
        duration INTEGER NOT NULL,
        category TEXT,
        is_active INTEGER DEFAULT 1,
        is_custom INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Create udhaar table
    await db.execute('''
      CREATE TABLE udhaar (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customer_id INTEGER NOT NULL,
        total_amount REAL NOT NULL,
        paid_amount REAL DEFAULT 0.0,
        due_date TEXT,
        status TEXT DEFAULT 'pending',
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE
      )
    ''');

    // Create udhaar_payments table
    await db.execute('''
      CREATE TABLE udhaar_payments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        udhaar_id INTEGER NOT NULL,
        amount REAL NOT NULL,
        payment_date TEXT NOT NULL,
        payment_method TEXT,
        notes TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (udhaar_id) REFERENCES udhaar(id) ON DELETE CASCADE
      )
    ''');

    // Create workers table
    await db.execute('''
      CREATE TABLE workers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT,
        role TEXT DEFAULT 'Barber',
        commission_percentage REAL DEFAULT 0.0,
        is_active INTEGER DEFAULT 1,
        join_date TEXT NOT NULL,
        notes TEXT,
        photo_path TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Create bills table
    await db.execute('''
      CREATE TABLE bills (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customer_id INTEGER NOT NULL,
        worker_id INTEGER,
        total_amount REAL NOT NULL,
        discount REAL DEFAULT 0.0,
        tax REAL DEFAULT 0.0,
        final_amount REAL NOT NULL,
        payment_method TEXT DEFAULT 'Cash',
        payment_status TEXT DEFAULT 'paid',
        notes TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE,
        FOREIGN KEY (worker_id) REFERENCES workers(id) ON DELETE SET NULL
      )
    ''');

    // Create bill_items table
    await db.execute('''
      CREATE TABLE bill_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        bill_id INTEGER NOT NULL,
        service_id INTEGER NOT NULL,
        service_name TEXT NOT NULL,
        price REAL NOT NULL,
        quantity INTEGER DEFAULT 1,
        total REAL NOT NULL,
        FOREIGN KEY (bill_id) REFERENCES bills(id) ON DELETE CASCADE
      )
    ''');

    // Create visits table
    await db.execute('''
      CREATE TABLE visits (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customer_id INTEGER NOT NULL,
        worker_id INTEGER,
        visit_date TEXT NOT NULL,
        services TEXT NOT NULL,
        service_ids TEXT NOT NULL,
        total_amount REAL NOT NULL,
        payment_status TEXT DEFAULT 'paid',
        payment_method TEXT,
        notes TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE,
        FOREIGN KEY (worker_id) REFERENCES workers(id) ON DELETE SET NULL
      )
    ''');

    // Create expenses table
    await db.execute('''
      CREATE TABLE expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category TEXT NOT NULL,
        amount REAL NOT NULL,
        description TEXT,
        expense_date TEXT NOT NULL,
        payment_method TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT
      )
    ''');

    // Create shop_settings table
    await db.execute('''
      CREATE TABLE shop_settings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        shop_name TEXT,
        owner_name TEXT,
        phone TEXT,
        address TEXT,
        email TEXT,
        currency TEXT DEFAULT 'PKR',
        working_hours TEXT,
        qr_jazzcash TEXT,
        qr_easypaisa TEXT,
        qr_bank TEXT,
        logo_path TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Insert default services
    final now = DateTime.now().toIso8601String();
    await db.execute('''
      INSERT INTO services (name, price, duration, category, is_custom, created_at, updated_at)
      VALUES 
        ('Haircut', 500, 30, 'Hair', 0, '$now', '$now'),
        ('Beard Trim', 300, 15, 'Beard', 0, '$now', '$now'),
        ('Facial', 800, 45, 'Skin Care', 0, '$now', '$now'),
        ('Hair Coloring', 1500, 60, 'Hair', 0, '$now', '$now'),
        ('Massage', 1000, 45, 'Body', 0, '$now', '$now'),
        ('Hair Wash', 200, 10, 'Hair', 0, '$now', '$now'),
        ('Head Massage', 400, 20, 'Body', 0, '$now', '$now'),
        ('Face Mask', 600, 25, 'Skin Care', 0, '$now', '$now')
    ''');

    // Insert default shop settings
    await db.execute('''
      INSERT INTO shop_settings (currency, created_at, updated_at)
      VALUES ('PKR', '$now', '$now')
    ''');
  }

  static Future<void> _onUpgrade(
      Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add any new columns or tables for version 2
      await db.execute(
          'ALTER TABLE customers ADD COLUMN visit_count INTEGER DEFAULT 0');
    }
  }

  static Database get database {
    if (_database == null) {
      throw Exception(
          'Database not initialized. Call DatabaseService.initialize() first.');
    }
    return _database!;
  }

  // Helper method to close database
  static Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
