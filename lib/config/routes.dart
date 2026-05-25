import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
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
import '../screens/subscription/trial_expired_screen.dart';
import '../screens/subscription/plan_expired_screen.dart';
import '../screens/qr_payment/qr_payment_screen.dart';

class AppRouter {
  static const String splashRoute = '/';
  static const String loginRoute = '/login';
  static const String signupRoute = '/signup';
  static const String dashboardRoute = '/dashboard';
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
  static const String trialExpiredRoute = '/trial-expired';
  static const String planExpiredRoute = '/plan-expired';
  static const String qrPaymentRoute = '/qr-payment';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splashRoute:
        return _buildRoute(const SplashScreen());
      case loginRoute:
        return _buildRoute(const LoginScreen());
      case signupRoute:
        return _buildRoute(const SignupScreen());
      case dashboardRoute:
        return _buildRoute(const DashboardScreen());
      case customersListRoute:
        return _buildRoute(const CustomersListScreen());
      case customerDetailRoute:
        final args = settings.arguments as Map<String, dynamic>;
        return _buildRoute(
            CustomerDetailScreen(customerId: args['customerId']));
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
      case trialExpiredRoute:
        return _buildRoute(const TrialExpiredScreen());
      case planExpiredRoute:
        return _buildRoute(const PlanExpiredScreen());
      case qrPaymentRoute:
        return _buildRoute(const QrPaymentScreen());
      default:
        return _buildRoute(const SplashScreen());
    }
  }

  static MaterialPageRoute _buildRoute(Widget screen) {
    return MaterialPageRoute(builder: (_) => screen);
  }
}
