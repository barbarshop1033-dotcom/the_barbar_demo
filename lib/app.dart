import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'config/routes.dart';
import 'providers/subscription_provider.dart';
import 'widgets/demo_badge.dart';

class BarberApp extends StatelessWidget {
  const BarberApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Barber - Demo',
      debugShowCheckedModeBanner: false,
      theme: BarberTheme.darkTheme,
      onGenerateRoute: AppRouter.generateRoute,
      initialRoute: AppRouter.dashboardRoute, // DIRECT TO DASHBOARD - NO LOGIN!
      builder: (context, child) {
        return Stack(
          children: [
            child!,
            // Small demo badge so viewers know it's a demo (non-intrusive)
            const Positioned(
              bottom: 8,
              right: 8,
              child: DemoBadge(),
            ),
          ],
        );
      },
    );
  }
}