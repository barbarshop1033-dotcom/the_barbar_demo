import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/bill_provider.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/loading_widget.dart';
import '../../models/bill_model.dart';

class BillDetailScreen extends StatefulWidget {
  final int billId;

  const BillDetailScreen({super.key, required this.billId});

  @override
  State<BillDetailScreen> createState() => _BillDetailScreenState();
}

class _BillDetailScreenState extends State<BillDetailScreen> {
  BillModel? _bill;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBill();
  }

  Future<void> _loadBill() async {
    setState(() => _isLoading = true);
    final billProvider = context.read<BillProvider>();
    _bill = await billProvider.getBillById(widget.billId);
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Bill #${widget.billId}',
        actions: [
          if (_bill != null)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: BarberTheme.accentColor),
              color: BarberTheme.cardColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              onSelected: (value) => _handleMenuAction(value, context),
              itemBuilder: (context) => [
                if (_bill!.paymentStatus != 'paid')
                  PopupMenuItem(
                    value: 'mark_paid',
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle,
                            color: BarberTheme.successColor, size: 20),
                        const SizedBox(width: 8),
                        Text('Mark as Paid',
                            style: GoogleFonts.poppins(
                                color: BarberTheme.textPrimary)),
                      ],
                    ),
                  ),
                PopupMenuItem(
                  value: 'share',
                  child: Row(
                    children: [
                      const Icon(Icons.share,
                          color: BarberTheme.accentColor, size: 20),
                      const SizedBox(width: 8),
                      Text('Share Bill',
                          style: GoogleFonts.poppins(
                              color: BarberTheme.textPrimary)),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      const Icon(Icons.delete,
                          color: BarberTheme.dangerColor, size: 20),
                      const SizedBox(width: 8),
                      Text('Delete Bill',
                          style: GoogleFonts.poppins(
                              color: BarberTheme.dangerColor)),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'Loading bill details...')
          : _bill == null
              ? Center(
                  child: Text(
                    'Bill not found',
                    style:
                        GoogleFonts.poppins(color: BarberTheme.textSecondary),
                  ),
                )
              : _buildBillDetail(),
    );
  }

  Widget _buildBillDetail() {
    final currencyFormat = NumberFormat('#,##0');
    final bill = _bill!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bill Header
          _buildBillHeader(bill),
          const SizedBox(height: 20),

          // Customer & Worker Info
          _buildInfoSection(bill),
          const SizedBox(height: 20),

          // Services List
          _buildServicesList(bill, currencyFormat),
          const SizedBox(height: 20),

          // Totals
          _buildTotalsCard(bill, currencyFormat),
          const SizedBox(height: 20),

          // Payment Info
          _buildPaymentInfo(bill),

          if (bill.notes != null && bill.notes!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildNotesSection(bill),
          ],

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildBillHeader(BillModel bill) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            BarberTheme.accentColor.withOpacity(0.15),
            BarberTheme.accentColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: BarberTheme.accentColor.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bill #${bill.id}',
                    style: GoogleFonts.poppins(
                      color: BarberTheme.accentColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('dd MMMM yyyy').format(bill.createdAt),
                    style: GoogleFonts.poppins(
                      color: BarberTheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    DateFormat('hh:mm a').format(bill.createdAt),
                    style: GoogleFonts.poppins(
                      color: BarberTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              _buildStatusBadge(bill.paymentStatus),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Rs ${NumberFormat('#,##0').format(bill.finalAmount)}',
            style: GoogleFonts.poppins(
              color: BarberTheme.accentColor,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    IconData icon;

    switch (status) {
      case 'paid':
        color = BarberTheme.successColor;
        icon = Icons.check_circle_rounded;
        break;
      case 'partial':
        color = BarberTheme.warningColor;
        icon = Icons.pending_rounded;
        break;
      default:
        color = BarberTheme.dangerColor;
        icon = Icons.cancel_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 6),
          Text(
            status.toUpperCase(),
            style: GoogleFonts.poppins(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(BillModel bill) {
    return Row(
      children: [
        // Customer Info
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: BarberTheme.cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.person_rounded,
                        color: BarberTheme.accentColor, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Customer',
                      style: GoogleFonts.poppins(
                        color: BarberTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  bill.customerName ?? 'Customer #${bill.customerId}',
                  style: GoogleFonts.poppins(
                    color: BarberTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (bill.customerPhone != null)
                  Text(
                    bill.customerPhone!,
                    style: GoogleFonts.poppins(
                      color: BarberTheme.textSecondary,
                      fontSize: 13,
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Worker Info
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: BarberTheme.cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.badge_rounded,
                        color: BarberTheme.accentColor, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Barber',
                      style: GoogleFonts.poppins(
                        color: BarberTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  bill.workerName ?? 'Not Assigned',
                  style: GoogleFonts.poppins(
                    color: bill.workerName != null
                        ? BarberTheme.textPrimary
                        : BarberTheme.textSecondary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildServicesList(BillModel bill, NumberFormat currencyFormat) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BarberTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Services',
            style: GoogleFonts.poppins(
              color: BarberTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          if (bill.items.isEmpty)
            Text(
              'No services found',
              style: GoogleFonts.poppins(color: BarberTheme.textSecondary),
            )
          else
            ...bill.items.map((item) => Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: const BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                            color: BarberTheme.primaryColor, width: 0.5)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: BarberTheme.accentColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.content_cut,
                            color: BarberTheme.accentColor, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.serviceName,
                              style: GoogleFonts.poppins(
                                color: BarberTheme.textPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '${item.quantity}x Rs ${currencyFormat.format(item.price)}',
                              style: GoogleFonts.poppins(
                                color: BarberTheme.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'Rs ${currencyFormat.format(item.total)}',
                        style: GoogleFonts.poppins(
                          color: BarberTheme.accentColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )),
        ],
      ),
    );
  }

  Widget _buildTotalsCard(BillModel bill, NumberFormat currencyFormat) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BarberTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BarberTheme.accentColor.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          _buildTotalRow('Subtotal', bill.totalAmount, currencyFormat),
          if (bill.discount > 0)
            _buildTotalRow('Discount', -bill.discount, currencyFormat,
                color: BarberTheme.dangerColor),
          if (bill.tax > 0) _buildTotalRow('Tax', bill.tax, currencyFormat),
          const Divider(color: BarberTheme.primaryColor),
          _buildTotalRow('Total', bill.finalAmount, currencyFormat,
              isBold: true, color: BarberTheme.accentColor),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, double amount, NumberFormat format,
      {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              color: color ?? BarberTheme.textSecondary,
              fontSize: isBold ? 18 : 14,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          Text(
            'Rs ${format.format(amount.abs())}',
            style: GoogleFonts.poppins(
              color: color ?? BarberTheme.textPrimary,
              fontSize: isBold ? 20 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentInfo(BillModel bill) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BarberTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Details',
            style: GoogleFonts.poppins(
              color: BarberTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildPaymentDetailItem(
                'Method',
                bill.paymentMethod,
                _getPaymentMethodIcon(bill.paymentMethod),
              ),
              const SizedBox(width: 24),
              _buildPaymentDetailItem(
                'Status',
                bill.paymentStatus.toUpperCase(),
                _getPaymentStatusIcon(bill.paymentStatus),
              ),
            ],
          ),
          if (bill.paymentStatus != 'paid') ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _handleMarkAsPaid(context, bill),
                icon: const Icon(Icons.check_circle_outline),
                label: Text(
                  'Mark as Paid',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: BarberTheme.successColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentDetailItem(String label, String value, IconData icon) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, color: BarberTheme.accentColor, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  color: BarberTheme.textSecondary,
                  fontSize: 11,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  color: BarberTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection(BillModel bill) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BarberTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notes',
            style: GoogleFonts.poppins(
              color: BarberTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            bill.notes!,
            style: GoogleFonts.poppins(
              color: BarberTheme.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getPaymentMethodIcon(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return Icons.money_rounded;
      case 'jazzcash':
        return Icons.account_balance_wallet_rounded;
      case 'easypaisa':
        return Icons.account_balance_wallet_rounded;
      case 'card':
        return Icons.credit_card_rounded;
      default:
        return Icons.payment_rounded;
    }
  }

  IconData _getPaymentStatusIcon(String status) {
    switch (status) {
      case 'paid':
        return Icons.check_circle_rounded;
      case 'partial':
        return Icons.pending_rounded;
      default:
        return Icons.cancel_rounded;
    }
  }

  void _handleMenuAction(String action, BuildContext context) {
    switch (action) {
      case 'mark_paid':
        _handleMarkAsPaid(context, _bill!);
        break;
      case 'share':
        // Share bill logic
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Share feature coming soon'),
            backgroundColor: BarberTheme.accentColor,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        break;
      case 'delete':
        _handleDeleteBill(context);
        break;
    }
  }

  Future<void> _handleMarkAsPaid(BuildContext context, BillModel bill) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: BarberTheme.cardColor,
        title: Text('Mark as Paid',
            style: GoogleFonts.poppins(color: BarberTheme.textPrimary)),
        content: Text(
          'Are you sure you want to mark this bill as paid?',
          style: GoogleFonts.poppins(color: BarberTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel',
                style: GoogleFonts.poppins(color: BarberTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: BarberTheme.successColor),
            child: Text('Confirm',
                style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await context
          .read<BillProvider>()
          .updateBillPaymentStatus(bill.id!, 'paid');
      if (success && mounted) {
        await _loadBill();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Bill marked as paid'),
            backgroundColor: BarberTheme.successColor,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  Future<void> _handleDeleteBill(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: BarberTheme.cardColor,
        title: Text('Delete Bill',
            style: GoogleFonts.poppins(color: BarberTheme.dangerColor)),
        content: Text(
          'Are you sure you want to delete this bill? This action cannot be undone.',
          style: GoogleFonts.poppins(color: BarberTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel',
                style: GoogleFonts.poppins(color: BarberTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: BarberTheme.dangerColor),
            child:
                Text('Delete', style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await context.read<BillProvider>().deleteBill(_bill!.id!);
      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Bill deleted successfully'),
            backgroundColor: BarberTheme.dangerColor,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }
}
