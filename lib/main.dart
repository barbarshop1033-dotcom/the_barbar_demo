import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/database_service.dart';
import 'services/demo_data_seeder.dart';
import 'app.dart';
import 'providers/customer_provider.dart';
import 'providers/service_provider.dart';
import 'providers/udhaar_provider.dart';
import 'providers/bill_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/worker_provider.dart';
import 'providers/visit_provider.dart';
import 'providers/expense_provider.dart';
import 'providers/subscription_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences
  await DatabaseService.initialize();

  // Seed demo data (only runs once)
  await DemoDataSeeder.seedIfNeeded();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SubscriptionProvider()),
        ChangeNotifierProvider(create: (_) => CustomerProvider()),
        ChangeNotifierProvider(create: (_) => ServiceProvider()),
        ChangeNotifierProvider(create: (_) => UdhaarProvider()),
        ChangeNotifierProvider(create: (_) => BillProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => WorkerProvider()),
        ChangeNotifierProvider(create: (_) => VisitProvider()),
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
      ],
      child: const BarberApp(),
    );
  }
}
