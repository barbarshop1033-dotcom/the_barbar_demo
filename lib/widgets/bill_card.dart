import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';
import '../models/bill_model.dart';

class BillCard extends StatelessWidget {
  final BillModel bill;
  final VoidCallback? onTap;
  final bool compact;

  const BillCard({
    super.key,
    required this.bill,
    this.onTap,
    this.compact = false,
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
          child: Column(
            children: [
              // Header Row
              Row(
                children: [
                  // Bill Number & Date
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bill #${bill.id}',
                          style: GoogleFonts.poppins(
                            color: BarberTheme.accentColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          DateFormat('dd MMM yyyy, hh:mm a')
                              .format(bill.createdAt),
                          style: GoogleFonts.poppins(
                            color: BarberTheme.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Payment Status
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getPaymentStatusColor().withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getPaymentStatusColor().withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getPaymentStatusIcon(),
                          color: _getPaymentStatusColor(),
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          bill.paymentStatus.toUpperCase(),
                          style: GoogleFonts.poppins(
                            color: _getPaymentStatusColor(),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              if (!compact) ...[
                // Customer Info
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: BarberTheme.accentColor.withOpacity(0.1),
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: BarberTheme.accentColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bill.customerName ?? 'Customer #${bill.customerId}',
                            style: GoogleFonts.poppins(
                              color: BarberTheme.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (bill.customerPhone != null)
                            Text(
                              bill.customerPhone!,
                              style: GoogleFonts.poppins(
                                color: BarberTheme.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),
                const Divider(color: BarberTheme.cardColor),
                const SizedBox(height: 8),

                // Bill Items Preview
                if (bill.items.isNotEmpty)
                  ...bill.items.take(3).map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${item.quantity}x ${item.serviceName}',
                                style: GoogleFonts.poppins(
                                  color: BarberTheme.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            Text(
                              'Rs ${currencyFormat.format(item.total)}',
                              style: GoogleFonts.poppins(
                                color: BarberTheme.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      )),

                if (bill.items.length > 3)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '+${bill.items.length - 3} more services',
                      style: GoogleFonts.poppins(
                        color: BarberTheme.accentColor,
                        fontSize: 11,
                      ),
                    ),
                  ),

                const Divider(color: BarberTheme.cardColor),
              ],

              // Total Amount
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Amount',
                    style: GoogleFonts.poppins(
                      color: BarberTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Rs ${currencyFormat.format(bill.finalAmount)}',
                        style: GoogleFonts.poppins(
                          color: BarberTheme.accentColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (bill.discount > 0)
                        Text(
                          'Discount: Rs ${currencyFormat.format(bill.discount)}',
                          style: GoogleFonts.poppins(
                            color: BarberTheme.successColor,
                            fontSize: 11,
                          ),
                        ),
                    ],
                  ),
                ],
              ),

              // Payment Method
              if (!compact) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      _getPaymentMethodIcon(),
                      color: BarberTheme.textSecondary,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      bill.paymentMethod,
                      style: GoogleFonts.poppins(
                        color: BarberTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    if (bill.workerName != null) ...[
                      const SizedBox(width: 16),
                      const Icon(
                        Icons.person_outline_rounded,
                        color: BarberTheme.textSecondary,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        bill.workerName!,
                        style: GoogleFonts.poppins(
                          color: BarberTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getPaymentStatusColor() {
    switch (bill.paymentStatus) {
      case 'paid':
        return BarberTheme.successColor;
      case 'partial':
        return BarberTheme.warningColor;
      default:
        return BarberTheme.dangerColor;
    }
  }

  IconData _getPaymentStatusIcon() {
    switch (bill.paymentStatus) {
      case 'paid':
        return Icons.check_circle_rounded;
      case 'partial':
        return Icons.pending_rounded;
      default:
        return Icons.cancel_rounded;
    }
  }

  IconData _getPaymentMethodIcon() {
    switch (bill.paymentMethod.toLowerCase()) {
      case 'cash':
        return Icons.money_rounded;
      case 'jazzcash':
      case 'easypaisa':
        return Icons.account_balance_wallet_rounded;
      case 'card':
        return Icons.credit_card_rounded;
      default:
        return Icons.payment_rounded;
    }
  }
}
