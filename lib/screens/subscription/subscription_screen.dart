import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/subscription_provider.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/app_drawer.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Subscription', showBackButton: false),
      drawer: const AppDrawer(),
      body: Consumer<SubscriptionProvider>(
        builder: (context, subscriptionProvider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Demo Mode Banner
                _buildDemoBanner(),

                const SizedBox(height: 24),

                // Current Plan Status
                _buildCurrentPlanCard(),

                const SizedBox(height: 24),

                // Plan Details
                _buildPlanDetails(),

                const SizedBox(height: 24),

                // Available Plans
                Text(
                  'Available Plans',
                  style: GoogleFonts.poppins(
                    color: BarberTheme.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'All features unlocked in demo mode',
                  style: GoogleFonts.poppins(
                    color: BarberTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),

                // Demo Plan Cards
                _buildDemoPlanCard(
                  name: 'Basic',
                  price: 'Rs 999',
                  features: [
                    'Customer Management',
                    'Udhaar Book',
                    'Basic Reports',
                    'Up to 500 Customers',
                  ],
                  color: 0xFF4CAF50,
                ),
                const SizedBox(height: 16),
                _buildDemoPlanCard(
                  name: 'Premium',
                  price: 'Rs 1,999',
                  features: [
                    'Everything in Basic',
                    'Advanced Reports',
                    'Staff Management',
                    'QR Payments',
                    'Unlimited Customers',
                    'Priority Support',
                  ],
                  color: 0xFF2196F3,
                  isPopular: true,
                ),
                const SizedBox(height: 16),
                _buildDemoPlanCard(
                  name: 'Premium Plus',
                  price: 'Rs 3,999',
                  features: [
                    'Everything in Premium',
                    'Multi-shop Support',
                    'API Access',
                    'Custom Branding',
                    '24/7 Support',
                    'Data Export',
                  ],
                  color: 0xFF9C27B0,
                ),

                const SizedBox(height: 32),

                // Demo Notice
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: BarberTheme.warningColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: BarberTheme.warningColor.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: BarberTheme.warningColor,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'This is a demo version. All premium features are unlocked for demonstration purposes.',
                          style: GoogleFonts.poppins(
                            color: BarberTheme.warningColor,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDemoBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            BarberTheme.accentColor.withOpacity(0.2),
            BarberTheme.accentColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: BarberTheme.accentColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: BarberTheme.accentColor.withOpacity(0.1),
            ),
            child: const Icon(
              Icons.developer_mode_rounded,
              color: BarberTheme.accentColor,
              size: 48,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Demo Mode - All Features Unlocked',
            style: GoogleFonts.poppins(
              color: BarberTheme.accentColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This is a demonstration version of The Barber app. All premium features are available to showcase the app\'s capabilities.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: BarberTheme.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentPlanCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            BarberTheme.successColor.withOpacity(0.2),
            BarberTheme.successColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: BarberTheme.successColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: BarberTheme.successColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: BarberTheme.successColor.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.verified_rounded,
                  color: BarberTheme.successColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'DEMO ACCESS',
                  style: GoogleFonts.poppins(
                    color: BarberTheme.successColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Premium Plan',
            style: GoogleFonts.poppins(
              color: BarberTheme.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: BarberTheme.cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  'Unlimited',
                  style: GoogleFonts.poppins(
                    color: BarberTheme.successColor,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Days Remaining',
                  style: GoogleFonts.poppins(
                    color: BarberTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Demo Mode - No expiration',
            style: GoogleFonts.poppins(
              color: BarberTheme.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanDetails() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: BarberTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Premium Features Included',
            style: GoogleFonts.poppins(
              color: BarberTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _buildFeatureItem('Customer Management', true),
          _buildFeatureItem('Udhaar Book', true),
          _buildFeatureItem('Billing & POS', true),
          _buildFeatureItem('Staff Management', true),
          _buildFeatureItem('Reports & Analytics', true),
          _buildFeatureItem('QR Payments', true),
          _buildFeatureItem('Unlimited Customers', true),
          _buildFeatureItem('Priority Support', true),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String feature, bool included) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            included ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: included
                ? BarberTheme.successColor
                : BarberTheme.textSecondary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              feature,
              style: GoogleFonts.poppins(
                color: included
                    ? BarberTheme.textPrimary
                    : BarberTheme.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDemoPlanCard({
    required String name,
    required String price,
    required List<String> features,
    required int color,
    bool isPopular = false,
  }) {
    final planColor = Color(color);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: BarberTheme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPopular
              ? BarberTheme.accentColor
              : planColor.withOpacity(0.3),
          width: isPopular ? 2 : 1,
        ),
        boxShadow: isPopular
            ? [
                BoxShadow(
                  color: BarberTheme.accentColor.withOpacity(0.15),
                  blurRadius: 20,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isPopular)
            Align(
              alignment: Alignment.topRight,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      BarberTheme.accentColor,
                      BarberTheme.accentColor.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'POPULAR',
                  style: GoogleFonts.poppins(
                    color: BarberTheme.primaryColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: planColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.stars_rounded, color: planColor, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                name,
                style: GoogleFonts.poppins(
                  color: BarberTheme.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: GoogleFonts.poppins(
                  color: BarberTheme.accentColor,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '/30 days',
                style: GoogleFonts.poppins(
                  color: BarberTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...features.map(
            (feature) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(
                    Icons.check_rounded,
                    color: BarberTheme.successColor,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      feature,
                      style: GoogleFonts.poppins(
                        color: BarberTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context as BuildContext).showSnackBar(
                  const SnackBar(
                    content: Text(
                      '✨ Demo Mode: All features are already unlocked!',
                    ),
                    backgroundColor: BarberTheme.successColor,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isPopular
                    ? BarberTheme.accentColor
                    : planColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'Selected in Demo',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
