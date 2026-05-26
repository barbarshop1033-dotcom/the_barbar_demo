import 'package:flutter/material.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/customers/customers_list_screen.dart';
import '../screens/customers/customer_detail_screen.dart';
import '../screens/udhaar/udhaar_list_screen.dart';
import '../screens/udhaar/udhaar_detail_screen.dart';
import '../screens/billing/billing_screen.dart';
import '../screens/billing/bill_detail_screen.dart';
import '../screens/services/services_screen.dart';
import '../screens/workers/workers_list_screen.dart';
import '../screens/workers/worker_detail_screen.dart';
import '../screens/visits/visits_list_screen.dart';
import '../screens/visits/new_visit_screen.dart';
import '../screens/expenses/expenses_screen.dart';
import '../screens/reports/reports_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/subscription/subscription_screen.dart';
import '../screens/qr_payment/qr_payment_screen.dart';

class AppRouter {
  // NO SPLASH SCREEN - Direct to dashboard
  static const String dashboardRoute = '/';
  static const String customersListRoute = '/customers';
  static const String customerDetailRoute = '/customers/detail';
  static const String udhaarListRoute = '/udhaar';
  static const String udhaarDetailRoute = '/udhaar/detail';
  static const String billingRoute = '/billing';
  static const String billDetailRoute = '/billing/detail';
  static const String servicesRoute = '/services';
  static const String workersListRoute = '/workers';
  static const String workerDetailRoute = '/workers/detail';
  static const String visitsListRoute = '/visits';
  static const String newVisitRoute = '/visits/new';
  static const String expensesRoute = '/expenses';
  static const String reportsRoute = '/reports';
  static const String settingsRoute = '/settings';
  static const String subscriptionRoute = '/subscription';
  static const String qrPaymentRoute = '/qr-payment';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case dashboardRoute:
        return _buildRoute(const DashboardScreen());
      case customersListRoute:
        return _buildRoute(const CustomersListScreen());
      case customerDetailRoute:
        final args = settings.arguments as Map<String, dynamic>;
        return _buildRoute(
          CustomerDetailScreen(customerId: args['customerId']),
        );
      case udhaarListRoute:
        return _buildRoute(const UdhaarListScreen());
      case udhaarDetailRoute:
        final args = settings.arguments as Map<String, dynamic>;
        return _buildRoute(UdhaarDetailScreen(udhaarId: args['udhaarId']));
      case billingRoute:
        return _buildRoute(const BillingScreen());
      case billDetailRoute:
        final args = settings.arguments as Map<String, dynamic>;
        return _buildRoute(BillDetailScreen(billId: args['billId']));
      case servicesRoute:
        return _buildRoute(const ServicesScreen());
      case workersListRoute:
        return _buildRoute(const WorkersListScreen());
      case workerDetailRoute:
        final args = settings.arguments as Map<String, dynamic>;
        return _buildRoute(WorkerDetailScreen(workerId: args['workerId']));
      case visitsListRoute:
        return _buildRoute(const VisitsListScreen());
      case newVisitRoute:
        return _buildRoute(const NewVisitScreen());
      case expensesRoute:
        return _buildRoute(const ExpensesScreen());
      case reportsRoute:
        return _buildRoute(const ReportsScreen());
      case settingsRoute:
        return _buildRoute(const SettingsScreen());
      case subscriptionRoute:
        return _buildRoute(const SubscriptionScreen());
      case qrPaymentRoute:
        return _buildRoute(const QrPaymentScreen());
      default:
        return _buildRoute(const DashboardScreen());
    }
  }

  static MaterialPageRoute _buildRoute(Widget screen) {
    return MaterialPageRoute(builder: (_) => screen);
  }
}
