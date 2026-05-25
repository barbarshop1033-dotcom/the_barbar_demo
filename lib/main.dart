import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:the_barbar/firebase_options.dart';
import 'app.dart';
import 'providers/auth_provider.dart';
import 'providers/subscription_provider.dart';
import 'providers/customer_provider.dart';
import 'providers/service_provider.dart';
import 'providers/udhaar_provider.dart';
import 'providers/bill_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/worker_provider.dart';
import 'providers/visit_provider.dart';
import 'providers/expense_provider.dart';
import 'services/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase for Authentication & Subscription
  await Firebase.initializeApp(options: kIsWeb ? firebaseOptions : null);

  // Initialize Local SQLite Database
  await DatabaseService.initialize();

  // Run the app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Authentication Provider (loaded first)
        ChangeNotifierProvider(create: (_) => AuthProvider()),

        // Subscription Provider (lazy: false ensures immediate initialization)
        // This is important for checking trial/plan expiration on app start
        ChangeNotifierProvider(
          create: (_) => SubscriptionProvider(),
          lazy: false,
        ),

        // Business Logic Providers
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
