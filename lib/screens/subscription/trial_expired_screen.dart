import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';

class TrialExpiredScreen extends StatefulWidget {
  const TrialExpiredScreen({super.key});

  @override
  State<TrialExpiredScreen> createState() => _TrialExpiredScreenState();
}

class _TrialExpiredScreenState extends State<TrialExpiredScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
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
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [BarberTheme.primaryColor, BarberTheme.backgroundColor],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Demo Icon
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
                          'Welcome to The Barber Demo! All premium features are unlocked for you to explore.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: BarberTheme.textSecondary,
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Data Safe Message
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: BarberTheme.successColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: BarberTheme.successColor.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.shield_rounded,
                                color: BarberTheme.successColor,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Demo data is pre-loaded for you',
                                style: GoogleFonts.poppins(
                                  color: BarberTheme.successColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Features Included
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
                                'What you can do:',
                                style: GoogleFonts.poppins(
                                  color: BarberTheme.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _buildFeatureItem('✓ Customer Management'),
                              _buildFeatureItem('✓ Udhaar Book & Tracking'),
                              _buildFeatureItem('✓ Billing & POS System'),
                              _buildFeatureItem('✓ Staff Management'),
                              _buildFeatureItem('✓ Reports & Analytics'),
                              _buildFeatureItem('✓ QR Payment System'),
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
                                context,
                                '/dashboard',
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: BarberTheme.accentColor,
                              foregroundColor: BarberTheme.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 8,
                              shadowColor: BarberTheme.accentColor.withOpacity(
                                0.4,
                              ),
                            ),
                            child: Text(
                              'Enter Demo',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String feature) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: BarberTheme.successColor,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            feature,
            style: GoogleFonts.poppins(
              color: BarberTheme.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
