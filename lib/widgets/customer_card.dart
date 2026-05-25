import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';
import '../models/customer_model.dart';

class CustomerCard extends StatelessWidget {
  final CustomerModel customer;
  final VoidCallback? onTap;
  final VoidCallback? onCall;
  final VoidCallback? onMessage;

  const CustomerCard({
    super.key,
    required this.customer,
    this.onTap,
    this.onCall,
    this.onMessage,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat('#,##0');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Customer Avatar
              Stack(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: BarberTheme.accentColor.withOpacity(0.1),
                      border: Border.all(
                        color: BarberTheme.accentColor.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: customer.photoPath != null
                        ? ClipOval(
                            child: Image.asset(
                              customer.photoPath!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                Icons.person,
                                color: BarberTheme.accentColor,
                                size: 28,
                              ),
                            ),
                          )
                        : const Icon(
                            Icons.person,
                            color: BarberTheme.accentColor,
                            size: 28,
                          ),
                  ),
                  // Regular Customer Star
                  if (customer.isRegular)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: BarberTheme.accentColor,
                        ),
                        child: const Icon(
                          Icons.star_rounded,
                          color: BarberTheme.primaryColor,
                          size: 12,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),

              // Customer Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            customer.name,
                            style: GoogleFonts.poppins(
                              color: BarberTheme.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (customer.preferredWorker != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: BarberTheme.accentColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              customer.preferredWorker!,
                              style: GoogleFonts.poppins(
                                color: BarberTheme.accentColor,
                                fontSize: 10,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      customer.phone,
                      style: GoogleFonts.poppins(
                        color: BarberTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        // Total Spent
                        _buildInfoChip(
                          Icons.monetization_on_outlined,
                          'Rs ${currencyFormat.format(customer.totalSpent)}',
                          BarberTheme.successColor,
                        ),
                        const SizedBox(width: 8),
                        // Visit Count
                        _buildInfoChip(
                          Icons.calendar_today,
                          '${customer.visitCount} visits',
                          BarberTheme.accentColor,
                        ),
                      ],
                    ),
                    if (customer.lastVisitDate != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Last visit: ${DateFormat('dd MMM yyyy').format(customer.lastVisitDate!)}',
                        style: GoogleFonts.poppins(
                          color: BarberTheme.textSecondary.withOpacity(0.7),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Action Buttons
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (onCall != null)
                    IconButton(
                      onPressed: onCall,
                      icon: const Icon(
                        Icons.call_rounded,
                        color: BarberTheme.successColor,
                        size: 22,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  const SizedBox(height: 8),
                  if (onMessage != null)
                    IconButton(
                      onPressed: onMessage,
                      icon: const Icon(
                        Icons.message_rounded,
                        color: BarberTheme.accentColor,
                        size: 22,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  const SizedBox(height: 8),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: BarberTheme.textSecondary,
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
