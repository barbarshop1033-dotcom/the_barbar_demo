import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';
import '../providers/subscription_provider.dart';
import '../providers/customer_provider.dart';
import '../providers/udhaar_provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final subscription = context.watch<SubscriptionProvider>();

    return Drawer(
      backgroundColor: BarberTheme.surfaceColor,
      child: SafeArea(
        child: Column(
          children: [
            // Header with Shop Info
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [BarberTheme.primaryColor, BarberTheme.surfaceColor],
                ),
                border: Border(
                  bottom: BorderSide(
                    color: BarberTheme.accentColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                children: [
                  // Shop Logo/Avatar
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: BarberTheme.accentColor,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: BarberTheme.accentColor.withOpacity(0.2),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/machiene_icon.png',
                        width: 40,
                        height: 40,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: BarberTheme.accentColor.withOpacity(0.1),
                          child: const Icon(
                            Icons.store,
                            color: BarberTheme.accentColor,
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Shop Name
                  Text(
                    auth.shopName,
                    style: GoogleFonts.playfairDisplay(
                      color: BarberTheme.accentColor,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Owner Name
                  Text(
                    auth.ownerName,
                    style: GoogleFonts.poppins(
                      color: BarberTheme.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Email
                  Text(
                    auth.shopEmail,
                    style: GoogleFonts.poppins(
                      color: BarberTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Subscription Status Badge
                  _buildSubscriptionBadge(subscription),
                ],
              ),
            ),

            // Menu Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _buildDrawerItem(
                    icon: Icons.dashboard_rounded,
                    title: 'Dashboard',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushReplacementNamed(context, '/dashboard');
                    },
                  ),
                  const Divider(
                    indent: 16,
                    endIndent: 16,
                    color: BarberTheme.cardColor,
                  ),
                  _buildSectionHeader('Management'),
                  _buildDrawerItem(
                    icon: Icons.people_rounded,
                    title: 'Customers',
                    badge:
                        '${context.watch<CustomerProvider>().totalCustomers}',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/customers');
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.receipt_long_rounded,
                    title: 'Billing',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/billing');
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.book_rounded,
                    title: 'Udhaar Book',
                    badge: context.watch<UdhaarProvider>().pendingCount > 0
                        ? '${context.watch<UdhaarProvider>().pendingCount}'
                        : null,
                    badgeColor: BarberTheme.dangerColor,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/udhaar');
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.assignment_rounded,
                    title: 'Visits',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/visits');
                    },
                  ),
                  const Divider(
                    indent: 16,
                    endIndent: 16,
                    color: BarberTheme.cardColor,
                  ),
                  _buildSectionHeader('Setup'),
                  _buildDrawerItem(
                    icon: Icons.content_cut_rounded,
                    title: 'Services',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/services');
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.badge_rounded,
                    title: 'Workers',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/workers');
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.money_off_rounded,
                    title: 'Expenses',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/expenses');
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.qr_code_rounded,
                    title: 'QR Payments',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/qr-payment');
                    },
                  ),
                  const Divider(
                    indent: 16,
                    endIndent: 16,
                    color: BarberTheme.cardColor,
                  ),
                  _buildSectionHeader('Analytics'),
                  _buildDrawerItem(
                    icon: Icons.bar_chart_rounded,
                    title: 'Reports',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/reports');
                    },
                  ),
                  const Divider(
                    indent: 16,
                    endIndent: 16,
                    color: BarberTheme.cardColor,
                  ),
                  _buildDrawerItem(
                    icon: Icons.stars_rounded,
                    title: 'Subscription',
                    trailing: subscription.isTrial
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: BarberTheme.warningColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'TRIAL',
                              style: GoogleFonts.poppins(
                                color: BarberTheme.warningColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        : null,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/subscription');
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.settings_rounded,
                    title: 'Settings',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/settings');
                    },
                  ),
                ],
              ),
            ),

            // Logout Button
            Padding(
              padding: const EdgeInsets.all(16),
              child: InkWell(
                onTap: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: BarberTheme.cardColor,
                      title: Text(
                        'Sign Out',
                        style: GoogleFonts.poppins(
                          color: BarberTheme.textPrimary,
                        ),
                      ),
                      content: Text(
                        'Are you sure you want to sign out?',
                        style: GoogleFonts.poppins(
                          color: BarberTheme.textSecondary,
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.poppins(
                              color: BarberTheme.textSecondary,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text(
                            'Sign Out',
                            style: GoogleFonts.poppins(
                              color: BarberTheme.dangerColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    await auth.signOut();
                    if (context.mounted) {
                      Navigator.pushReplacementNamed(context, '/login');
                    }
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 20,
                  ),
                  decoration: BoxDecoration(
                    color: BarberTheme.dangerColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: BarberTheme.dangerColor.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.logout_rounded,
                        color: BarberTheme.dangerColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Sign Out',
                        style: GoogleFonts.poppins(
                          color: BarberTheme.dangerColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Version
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'v1.0.0 - The Barber',
                style: GoogleFonts.poppins(
                  color: BarberTheme.textSecondary.withOpacity(0.5),
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionBadge(SubscriptionProvider subscription) {
    if (subscription.isTrial) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: BarberTheme.warningColor.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: BarberTheme.warningColor.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.timer, color: BarberTheme.warningColor, size: 14),
            const SizedBox(width: 6),
            Text(
              'Trial: ${subscription.remainingDays}d left',
              style: GoogleFonts.poppins(
                color: BarberTheme.warningColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    } else if (subscription.isActive) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: BarberTheme.successColor.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: BarberTheme.successColor.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.verified,
              color: BarberTheme.successColor,
              size: 14,
            ),
            const SizedBox(width: 6),
            Text(
              '${subscription.plan?.toUpperCase() ?? "ACTIVE"}',
              style: GoogleFonts.poppins(
                color: BarberTheme.successColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.poppins(
          color: BarberTheme.accentColor.withOpacity(0.7),
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    String? badge,
    Color? badgeColor,
    Widget? trailing,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: BarberTheme.accentColor.withOpacity(0.1),
        highlightColor: BarberTheme.accentColor.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: BarberTheme.accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: BarberTheme.accentColor, size: 20),
            ),
            title: Text(
              title,
              style: GoogleFonts.poppins(
                color: BarberTheme.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing:
                trailing ??
                (badge != null
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: (badgeColor ?? BarberTheme.dangerColor)
                              .withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          badge,
                          style: GoogleFonts.poppins(
                            color: badgeColor ?? BarberTheme.dangerColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : null),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }
}

// Add these imports at the top
