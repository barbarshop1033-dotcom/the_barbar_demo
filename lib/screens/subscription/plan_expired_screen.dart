import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/subscription_provider.dart';

class PlanExpiredScreen extends StatefulWidget {
  const PlanExpiredScreen({super.key});

  @override
  State<PlanExpiredScreen> createState() => _PlanExpiredScreenState();
}

class _PlanExpiredScreenState extends State<PlanExpiredScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                BarberTheme.primaryColor,
                BarberTheme.backgroundColor,
              ],
            ),
          ),
          child: SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(32),
                  child: Consumer<SubscriptionProvider>(
                    builder: (context, subscription, _) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),

                          // Expired Icon
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: BarberTheme.dangerColor.withOpacity(0.1),
                              border: Border.all(
                                color: BarberTheme.dangerColor.withOpacity(0.5),
                                width: 4,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      BarberTheme.dangerColor.withOpacity(0.2),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.cancel_rounded,
                              color: BarberTheme.dangerColor,
                              size: 64,
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Title
                          Text(
                            'Plan Expired',
                            style: GoogleFonts.playfairDisplay(
                              color: BarberTheme.dangerColor,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Plan Name
                          if (subscription.plan != null)
                            Text(
                              'Your ${subscription.plan!.toUpperCase()} plan has expired',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                color: BarberTheme.textSecondary,
                                fontSize: 18,
                              ),
                            ),

                          const SizedBox(height: 16),

                          // Expiry Info
                          if (subscription.endDate != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              decoration: BoxDecoration(
                                color: BarberTheme.dangerColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color:
                                      BarberTheme.dangerColor.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.event_busy_rounded,
                                    color: BarberTheme.dangerColor,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Expired on ${DateFormat('dd MMMM yyyy').format(subscription.endDate!)}',
                                    style: GoogleFonts.poppins(
                                      color: BarberTheme.dangerColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          const SizedBox(height: 24),

                          // Important Message
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  BarberTheme.successColor.withOpacity(0.15),
                                  BarberTheme.successColor.withOpacity(0.05),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color:
                                    BarberTheme.successColor.withOpacity(0.3),
                              ),
                            ),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.cloud_done_rounded,
                                  color: BarberTheme.successColor,
                                  size: 40,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Your Data is Safe!',
                                  style: GoogleFonts.poppins(
                                    color: BarberTheme.successColor,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'All your customers, bills, udhaar records, and settings are preserved. Subscribe again to regain access.',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    color: BarberTheme.textSecondary,
                                    fontSize: 14,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // What you get by renewing
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: BarberTheme.cardColor,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Renew to get back:',
                                  style: GoogleFonts.poppins(
                                    color: BarberTheme.textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _buildBenefitItem(
                                    Icons.check_circle_rounded,
                                    'Instant access to all your data',
                                    BarberTheme.successColor),
                                _buildBenefitItem(
                                    Icons.check_circle_rounded,
                                    'All premium features restored',
                                    BarberTheme.successColor),
                                _buildBenefitItem(
                                    Icons.check_circle_rounded,
                                    'New features and updates',
                                    BarberTheme.successColor),
                                _buildBenefitItem(
                                    Icons.check_circle_rounded,
                                    'Priority support',
                                    BarberTheme.successColor),
                                _buildBenefitItem(
                                    Icons.check_circle_rounded,
                                    'Continue where you left off',
                                    BarberTheme.successColor),
                              ],
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Renew Button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushReplacementNamed(
                                    context, '/subscription');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: BarberTheme.accentColor,
                                foregroundColor: BarberTheme.primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 8,
                                shadowColor:
                                    BarberTheme.accentColor.withOpacity(0.4),
                              ),
                              child: Text(
                                'Renew Subscription',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Compare Plans Button
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.pushReplacementNamed(
                                    context, '/subscription');
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: BarberTheme.accentColor,
                                side: const BorderSide(
                                    color: BarberTheme.accentColor),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Text(
                                'Compare Plans',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Plan Quick View
                          Row(
                            children: [
                              Expanded(
                                  child: _buildMiniPlanCard('Basic', 'Rs 999',
                                      '30 days', BarberTheme.successColor)),
                              const SizedBox(width: 12),
                              Expanded(
                                  child: _buildMiniPlanCard(
                                      'Premium',
                                      'Rs 1,499',
                                      '30 days',
                                      BarberTheme.accentColor)),
                              const SizedBox(width: 12),
                              Expanded(
                                  child: _buildMiniPlanCard('Pro', 'Rs 1,999',
                                      '30 days', BarberTheme.warningColor)),
                            ],
                          ),

                          const SizedBox(height: 32),

                          // Contact Support
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: BarberTheme.cardColor,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.support_agent_rounded,
                                    color: BarberTheme.accentColor, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Need help? Contact Support',
                                  style: GoogleFonts.poppins(
                                    color: BarberTheme.accentColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Sign Out
                          TextButton.icon(
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor: BarberTheme.cardColor,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16)),
                                  title: Text('Sign Out',
                                      style: GoogleFonts.poppins(
                                          color: BarberTheme.textPrimary)),
                                  content: Text(
                                    'Are you sure? You can sign in again anytime to restore your subscription.',
                                    style: GoogleFonts.poppins(
                                        color: BarberTheme.textSecondary),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: Text('Cancel',
                                          style: GoogleFonts.poppins(
                                              color:
                                                  BarberTheme.textSecondary)),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: Text('Sign Out',
                                          style: GoogleFonts.poppins(
                                              color: BarberTheme.dangerColor)),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                await context.read<AuthProvider>().signOut();
                                if (context.mounted) {
                                  Navigator.pushReplacementNamed(
                                      context, '/login');
                                }
                              }
                            },
                            icon: const Icon(Icons.logout_rounded,
                                color: BarberTheme.textSecondary, size: 18),
                            label: Text(
                              'Sign Out',
                              style: GoogleFonts.poppins(
                                  color: BarberTheme.textSecondary,
                                  fontSize: 14),
                            ),
                          ),

                          const SizedBox(height: 40),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitItem(IconData icon, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                color: BarberTheme.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniPlanCard(
      String name, String price, String duration, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: BarberTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            name,
            style: GoogleFonts.poppins(
              color: BarberTheme.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            price,
            style: GoogleFonts.poppins(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            duration,
            style: GoogleFonts.poppins(
              color: BarberTheme.textSecondary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
