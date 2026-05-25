import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';
import '../models/udhaar_model.dart';

class UdhaarCard extends StatelessWidget {
  final UdhaarModel udhaar;
  final VoidCallback? onTap;
  final VoidCallback? onAddPayment;
  final VoidCallback? onRemind;

  const UdhaarCard({
    super.key,
    required this.udhaar,
    this.onTap,
    this.onAddPayment,
    this.onRemind,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat('#,##0');
    final progress =
        udhaar.totalAmount > 0 ? udhaar.paidAmount / udhaar.totalAmount : 0.0;

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Customer Info
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _getStatusColor().withOpacity(0.1),
                          ),
                          child: Icon(
                            Icons.person_rounded,
                            color: _getStatusColor(),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                udhaar.customerName ??
                                    'Customer #${udhaar.customerId}',
                                style: GoogleFonts.poppins(
                                  color: BarberTheme.textPrimary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (udhaar.customerPhone != null)
                                Text(
                                  udhaar.customerPhone!,
                                  style: GoogleFonts.poppins(
                                    color: BarberTheme.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Status Badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor().withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getStatusColor().withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      udhaar.status.toUpperCase(),
                      style: GoogleFonts.poppins(
                        color: _getStatusColor(),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Amounts Row
              Row(
                children: [
                  // Total Amount
                  Expanded(
                    child: _buildAmountColumn(
                      'Total',
                      'Rs ${currencyFormat.format(udhaar.totalAmount)}',
                      BarberTheme.textPrimary,
                    ),
                  ),
                  // Paid Amount
                  Expanded(
                    child: _buildAmountColumn(
                      'Paid',
                      'Rs ${currencyFormat.format(udhaar.paidAmount)}',
                      BarberTheme.successColor,
                    ),
                  ),
                  // Remaining Amount
                  Expanded(
                    child: _buildAmountColumn(
                      'Remaining',
                      'Rs ${currencyFormat.format(udhaar.remainingAmount)}',
                      _getStatusColor(),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: BarberTheme.primaryColor,
                  valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor()),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${(progress * 100).toStringAsFixed(1)}% paid',
                style: GoogleFonts.poppins(
                  color: BarberTheme.textSecondary,
                  fontSize: 11,
                ),
              ),

              // Due Date and Actions
              if (udhaar.dueDate != null ||
                  onAddPayment != null ||
                  onRemind != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (udhaar.dueDate != null)
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_rounded,
                              color: BarberTheme.textSecondary,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Due: ${DateFormat('dd MMM yyyy').format(udhaar.dueDate!)}',
                              style: GoogleFonts.poppins(
                                color: BarberTheme.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (onRemind != null)
                      IconButton(
                        onPressed: onRemind,
                        icon: const Icon(
                          Icons.notifications_active_rounded,
                          color: BarberTheme.warningColor,
                          size: 20,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        tooltip: 'Send Reminder',
                      ),
                    const SizedBox(width: 8),
                    if (onAddPayment != null)
                      ElevatedButton.icon(
                        onPressed: onAddPayment,
                        icon: const Icon(Icons.add_rounded, size: 16),
                        label: Text(
                          'Add Payment',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: BarberTheme.accentColor,
                          foregroundColor: BarberTheme.primaryColor,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (udhaar.status) {
      case 'paid':
        return BarberTheme.successColor;
      case 'partial':
        return BarberTheme.warningColor;
      default:
        return BarberTheme.dangerColor;
    }
  }

  Widget _buildAmountColumn(String label, String amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: BarberTheme.textSecondary,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          amount,
          style: GoogleFonts.poppins(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
