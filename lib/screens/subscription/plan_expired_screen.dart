import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';

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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),

                      // Info Icon (instead of expired)
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: BarberTheme.accentColor.withOpacity(0.1),
                          border: Border.all(
                            color: BarberTheme.accentColor.withOpacity(0.5),
                            width: 4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: BarberTheme.accentColor.withOpacity(0.2),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.desktop_mac_outlined,
                          color: BarberTheme.accentColor,
                          size: 64,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Title
                      Text(
                        'Demo Mode',
                        style: GoogleFonts.playfairDisplay(
                          color: BarberTheme.accentColor,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Message
                      Text(
                        'This is a demonstration version with all features unlocked. No subscription needed.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: BarberTheme.textSecondary,
                          fontSize: 18,
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
                            color: BarberTheme.successColor.withOpacity(0.3),
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
                              'All Features Available!',
                              style: GoogleFonts.poppins(
                                color: BarberTheme.successColor,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Customer Management, Billing, Udhaar, Reports, QR Payments - Everything is fully functional in demo mode.',
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

                      // Features Container
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
                              'Premium Features Included:',
                              style: GoogleFonts.poppins(
                                color: BarberTheme.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildFeatureItem(
                                Icons.check_circle_rounded,
                                'Complete Customer Management',
                                BarberTheme.successColor),
                            _buildFeatureItem(
                                Icons.check_circle_rounded,
                                'Udhaar Book & Tracking',
                                BarberTheme.successColor),
                            _buildFeatureItem(
                                Icons.check_circle_rounded,
                                'Billing & POS System',
                                BarberTheme.successColor),
                            _buildFeatureItem(
                                Icons.check_circle_rounded,
                                'Staff Management',
                                BarberTheme.successColor),
                            _buildFeatureItem(
                                Icons.check_circle_rounded,
                                'Reports & Analytics',
                                BarberTheme.successColor),
                            _buildFeatureItem(
                                Icons.check_circle_rounded,
                                'QR Payment System',
                                BarberTheme.successColor),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Go to Dashboard Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(
                                context, '/dashboard');
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
                            'Go to Dashboard',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text, Color color) {
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
}