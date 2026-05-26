import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/stats_card.dart';
import '../../widgets/quick_action_button.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('The Barber - Demo'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Consumer<DashboardProvider>(
        builder: (context, dashboard, _) {
          return RefreshIndicator(
            onRefresh: () async {
              await dashboard.loadDashboardData();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Demo Mode Banner (instead of subscription banner)
                  _buildDemoBanner(),
                  const SizedBox(height: 16),

                  // Today's Summary
                  Text(
                    "Today's Summary",
                    style: GoogleFonts.poppins(
                      color: BarberTheme.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: StatsCard(
                          title: 'Earnings',
                          value:
                              'Rs ${NumberFormat('#,##0').format(dashboard.todayEarnings)}',
                          icon: Icons.monetization_on,
                          color: BarberTheme.successColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatsCard(
                          title: 'Customers',
                          value: '${dashboard.todayCustomers}',
                          icon: Icons.people,
                          color: BarberTheme.accentColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: StatsCard(
                          title: 'Pending Udhaar',
                          value:
                              'Rs ${NumberFormat('#,##0').format(dashboard.pendingUdhaar)}',
                          icon: Icons.receipt_long,
                          color: BarberTheme.warningColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatsCard(
                          title: 'Services',
                          value: '${dashboard.totalServices}',
                          icon: Icons.content_cut,
                          color: BarberTheme.dangerColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Quick Actions
                  Text(
                    'Quick Actions',
                    style: GoogleFonts.poppins(
                      color: BarberTheme.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    children: [
                      QuickActionButton(
                        icon: Icons.person_add,
                        label: 'New Customer',
                        onTap: () => Navigator.pushNamed(context, '/customers'),
                      ),
                      QuickActionButton(
                        icon: Icons.receipt,
                        label: 'New Bill',
                        onTap: () => Navigator.pushNamed(context, '/billing'),
                      ),
                      QuickActionButton(
                        icon: Icons.book,
                        label: 'Udhaar',
                        onTap: () => Navigator.pushNamed(context, '/udhaar'),
                      ),
                      QuickActionButton(
                        icon: Icons.people,
                        label: 'Customers',
                        onTap: () => Navigator.pushNamed(context, '/customers'),
                      ),
                      QuickActionButton(
                        icon: Icons.qr_code,
                        label: 'QR Pay',
                        onTap: () =>
                            Navigator.pushNamed(context, '/qr-payment'),
                      ),
                      QuickActionButton(
                        icon: Icons.bar_chart,
                        label: 'Reports',
                        onTap: () => Navigator.pushNamed(context, '/reports'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Recent Customers
                  Text(
                    'Recent Customers',
                    style: GoogleFonts.poppins(
                      color: BarberTheme.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (dashboard.recentCustomers.isEmpty)
                    _buildEmptyState(
                      icon: Icons.people_outline,
                      message: 'No customers yet',
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: dashboard.recentCustomers.length,
                      itemBuilder: (context, index) {
                        final customer = dashboard.recentCustomers[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: BarberTheme.accentColor
                                  .withOpacity(0.2),
                              child: const Icon(
                                Icons.person,
                                color: BarberTheme.accentColor,
                              ),
                            ),
                            title: Text(
                              customer.name,
                              style: GoogleFonts.poppins(
                                color: BarberTheme.textPrimary,
                              ),
                            ),
                            subtitle: Text(
                              customer.phone,
                              style: GoogleFonts.poppins(
                                color: BarberTheme.textSecondary,
                              ),
                            ),
                            trailing: const Icon(
                              Icons.chevron_right,
                              color: BarberTheme.textSecondary,
                            ),
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/customers/detail',
                                arguments: {'customerId': customer.id},
                              );
                            },
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDemoBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            BarberTheme.accentColor.withOpacity(0.2),
            BarberTheme.accentColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BarberTheme.accentColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: BarberTheme.accentColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.desktop_mac_rounded,
              color: BarberTheme.accentColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Demo Mode',
                  style: GoogleFonts.poppins(
                    color: BarberTheme.accentColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Explore all features with pre-loaded demo data',
                  style: GoogleFonts.poppins(
                    color: BarberTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: BarberTheme.successColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'PREMIUM',
              style: GoogleFonts.poppins(
                color: BarberTheme.successColor,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({required IconData icon, required String message}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: BarberTheme.cardColor,
              ),
              child: Icon(icon, color: BarberTheme.textSecondary, size: 30),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: GoogleFonts.poppins(
                color: BarberTheme.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
