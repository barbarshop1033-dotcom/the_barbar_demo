import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/subscription_provider.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/loading_widget.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SubscriptionProvider>().checkSubscription();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Subscription', showBackButton: false),
      drawer: const AppDrawer(),
      body: Consumer<SubscriptionProvider>(
        builder: (context, subscriptionProvider, _) {
          if (subscriptionProvider.isLoading) {
            return const LoadingWidget(message: 'Loading subscription...');
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Current Plan Status
                _buildCurrentPlanCard(subscriptionProvider),

                const SizedBox(height: 24),

                // Plan Details (if active)
                if (subscriptionProvider.isTrial ||
                    subscriptionProvider.isActive)
                  _buildPlanDetails(subscriptionProvider),

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
                  'Contact administrator to activate a plan',
                  style: GoogleFonts.poppins(
                    color: BarberTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),

                // Admin notice
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: BarberTheme.warningColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: BarberTheme.warningColor.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_rounded,
                        color: BarberTheme.warningColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Plan activation is managed by the administrator. Please contact admin to subscribe.',
                          style: GoogleFonts.poppins(
                            color: BarberTheme.warningColor,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Plan Cards
                _buildPlanCard(
                  planKey: 'basic',
                  planData: subscriptionProvider.availablePlans['basic']!,
                  isPopular: false,
                  subscriptionProvider: subscriptionProvider,
                ),
                const SizedBox(height: 16),
                _buildPlanCard(
                  planKey: 'premium',
                  planData: subscriptionProvider.availablePlans['premium']!,
                  isPopular: true,
                  subscriptionProvider: subscriptionProvider,
                ),
                const SizedBox(height: 16),
                _buildPlanCard(
                  planKey: 'premium_plus',
                  planData:
                      subscriptionProvider.availablePlans['premium_plus']!,
                  isPopular: false,
                  subscriptionProvider: subscriptionProvider,
                ),

                const SizedBox(height: 32),

                // Cancel Subscription (if active)
                if (subscriptionProvider.isActive)
                  _buildCancelSubscription(subscriptionProvider),

                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCurrentPlanCard(SubscriptionProvider provider) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (provider.isTrial) {
      statusColor = BarberTheme.warningColor;
      statusText = 'Free Trial';
      statusIcon = Icons.timer_rounded;
    } else if (provider.isActive) {
      statusColor = BarberTheme.successColor;
      statusText = 'Active';
      statusIcon = Icons.verified_rounded;
    } else if (provider.isTrialExpired) {
      statusColor = BarberTheme.dangerColor;
      statusText = 'Trial Expired';
      statusIcon = Icons.timer_off_rounded;
    } else if (provider.isPlanExpired) {
      statusColor = BarberTheme.dangerColor;
      statusText = 'Plan Expired';
      statusIcon = Icons.cancel_rounded;
    } else {
      statusColor = BarberTheme.textSecondary;
      statusText = 'Unknown';
      statusIcon = Icons.help_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [statusColor.withOpacity(0.2), statusColor.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: statusColor.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(statusIcon, color: statusColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  statusText.toUpperCase(),
                  style: GoogleFonts.poppins(
                    color: statusColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Plan Name
          if (provider.isActive && provider.plan != null)
            Text(
              provider.planDetails?['name'] ?? provider.plan!.toUpperCase(),
              style: GoogleFonts.poppins(
                color: BarberTheme.textPrimary,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

          if (provider.isTrial)
            Text(
              '7 Days Trial',
              style: GoogleFonts.poppins(
                color: BarberTheme.textPrimary,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

          const SizedBox(height: 12),

          // Remaining Days
          if (provider.remainingDays > 0) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: BarberTheme.cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Text(
                        '${provider.remainingDays}',
                        style: GoogleFonts.poppins(
                          color: statusColor,
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
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: provider.isTrial
                    ? 1 - (provider.remainingDays / 7)
                    : 1 - (provider.remainingDays / 30),
                backgroundColor: BarberTheme.primaryColor,
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                minHeight: 8,
              ),
            ),
          ],

          // Expired Message
          if (provider.isExpired) ...[
            const SizedBox(height: 8),
            Text(
              'Your access has expired. Contact admin to activate a plan.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: BarberTheme.textSecondary,
                fontSize: 14,
              ),
            ),
          ],

          // End Date
          if (provider.endDate != null) ...[
            const SizedBox(height: 12),
            Text(
              '${provider.isTrial ? "Trial" : "Plan"} ends: ${DateFormat('dd MMMM yyyy').format(provider.endDate!)}',
              style: GoogleFonts.poppins(
                color: BarberTheme.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlanDetails(SubscriptionProvider provider) {
    if (provider.planDetails == null) {
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
              'Trial Features',
              style: GoogleFonts.poppins(
                color: BarberTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            _buildFeatureItem('Full access to all features', true),
            _buildFeatureItem('Customer Management', true),
            _buildFeatureItem('Udhaar Book', true),
            _buildFeatureItem('Billing & POS', true),
            _buildFeatureItem('Staff Management', true),
            _buildFeatureItem('Reports & Analytics', true),
            _buildFeatureItem('QR Payments', true),
            _buildFeatureItem('7 days validity', true),
          ],
        ),
      );
    }

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
            'Plan Features',
            style: GoogleFonts.poppins(
              color: BarberTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...provider.planDetails!['features'].map<Widget>((feature) {
            return _buildFeatureItem(feature.toString(), true);
          }).toList(),
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

  Widget _buildPlanCard({
    required String planKey,
    required Map<String, dynamic> planData,
    required bool isPopular,
    required SubscriptionProvider subscriptionProvider,
  }) {
    final isCurrentPlan =
        subscriptionProvider.plan == planKey && subscriptionProvider.isActive;
    final color = Color(planData['color'] as int);
    final features = planData['features'] as List<String>;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: BarberTheme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPopular ? BarberTheme.accentColor : color.withOpacity(0.3),
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
          // Popular Badge
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

          // Plan Name
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.stars_rounded, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                planData['name'] as String,
                style: GoogleFonts.poppins(
                  color: BarberTheme.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Price
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                planData['pricePerMonth'] as String,
                style: GoogleFonts.poppins(
                  color: BarberTheme.accentColor,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '/${planData['duration']}',
                style: GoogleFonts.poppins(
                  color: BarberTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Features
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

          // FIXED: Action Button - DISABLED (Admin only activation)
          SizedBox(
            width: double.infinity,
            height: 48,
            child: isCurrentPlan
                ? ElevatedButton(
                    onPressed: null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: BarberTheme.successColor.withOpacity(
                        0.2,
                      ),
                      foregroundColor: BarberTheme.successColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Current Plan',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                : ElevatedButton.icon(
                    onPressed: () {
                      // SHOW MESSAGE - Manual activation only by admin
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                            '⚠️ Plan activation is managed by the administrator only.\nPlease contact admin to subscribe.',
                          ),
                          backgroundColor: BarberTheme.warningColor,
                          duration: const Duration(seconds: 5),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.admin_panel_settings_rounded,
                      size: 18,
                    ),
                    label: Text(
                      'Contact Admin',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isPopular
                          ? BarberTheme.accentColor
                          : color,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCancelSubscription(SubscriptionProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BarberTheme.dangerColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BarberTheme.dangerColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cancel Subscription',
            style: GoogleFonts.poppins(
              color: BarberTheme.dangerColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'You will lose access to premium features at the end of your billing period.',
            style: GoogleFonts.poppins(
              color: BarberTheme.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: BarberTheme.cardColor,
                  title: Text(
                    'Cancel Subscription',
                    style: GoogleFonts.poppins(color: BarberTheme.dangerColor),
                  ),
                  content: Text(
                    'Are you sure? Your data will not be lost.',
                    style: GoogleFonts.poppins(
                      color: BarberTheme.textSecondary,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(
                        'No',
                        style: GoogleFonts.poppins(
                          color: BarberTheme.textSecondary,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: BarberTheme.dangerColor,
                      ),
                      child: Text(
                        'Yes, Cancel',
                        style: GoogleFonts.poppins(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await provider.cancelSubscription();
              }
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: BarberTheme.dangerColor,
              side: const BorderSide(color: BarberTheme.dangerColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Cancel Subscription',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
