import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme.dart';
import '../../providers/udhaar_provider.dart';
import 'udhaar_list_screen.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/loading_widget.dart';
import '../../models/udhaar_model.dart';

class UdhaarDetailScreen extends StatefulWidget {
  final int udhaarId;

  const UdhaarDetailScreen({super.key, required this.udhaarId});

  @override
  State<UdhaarDetailScreen> createState() => _UdhaarDetailScreenState();
}

class _UdhaarDetailScreenState extends State<UdhaarDetailScreen> {
  UdhaarModel? _udhaar;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUdhaar();
  }

  Future<void> _loadUdhaar() async {
    setState(() => _isLoading = true);
    final udhaarProvider = context.read<UdhaarProvider>();
    _udhaar = await udhaarProvider.getUdhaarById(widget.udhaarId);
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Udhaar Details',
        actions: [
          if (_udhaar != null)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: BarberTheme.accentColor),
              color: BarberTheme.cardColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              onSelected: (value) => _handleMenuAction(value, context),
              itemBuilder: (context) => [
                if (_udhaar!.status != 'paid')
                  PopupMenuItem(
                    value: 'add_payment',
                    child: Row(
                      children: [
                        const Icon(Icons.add_rounded,
                            color: BarberTheme.successColor, size: 20),
                        const SizedBox(width: 8),
                        Text('Add Payment',
                            style: GoogleFonts.poppins(
                                color: BarberTheme.textPrimary)),
                      ],
                    ),
                  ),
                PopupMenuItem(
                  value: 'remind',
                  child: Row(
                    children: [
                      const Icon(Icons.notifications_rounded,
                          color: BarberTheme.warningColor, size: 20),
                      const SizedBox(width: 8),
                      Text('Send Reminder',
                          style: GoogleFonts.poppins(
                              color: BarberTheme.textPrimary)),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      const Icon(Icons.delete_rounded,
                          color: BarberTheme.dangerColor, size: 20),
                      const SizedBox(width: 8),
                      Text('Delete',
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
          ? const LoadingWidget(message: 'Loading udhaar details...')
          : _udhaar == null
              ? Center(
                  child: Text(
                    'Udhaar entry not found',
                    style:
                        GoogleFonts.poppins(color: BarberTheme.textSecondary),
                  ),
                )
              : _buildUdhaarDetail(),
    );
  }

  Widget _buildUdhaarDetail() {
    final currencyFormat = NumberFormat('#,##0');
    final udhaar = _udhaar!;
    final progress =
        udhaar.totalAmount > 0 ? udhaar.paidAmount / udhaar.totalAmount : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Header Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _getStatusColor().withOpacity(0.2),
                  _getStatusColor().withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _getStatusColor().withOpacity(0.3)),
            ),
            child: Column(
              children: [
                // Status Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _getStatusColor().withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: _getStatusColor().withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_getStatusIcon(),
                          color: _getStatusColor(), size: 20),
                      const SizedBox(width: 8),
                      Text(
                        udhaar.status.toUpperCase(),
                        style: GoogleFonts.poppins(
                          color: _getStatusColor(),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Remaining Amount
                Text(
                  'Rs ${currencyFormat.format(udhaar.remainingAmount)}',
                  style: GoogleFonts.poppins(
                    color: _getStatusColor(),
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Remaining',
                  style: GoogleFonts.poppins(
                    color: BarberTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 20),

                // Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: BarberTheme.primaryColor,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(_getStatusColor()),
                    minHeight: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${(progress * 100).toStringAsFixed(1)}% Paid',
                  style: GoogleFonts.poppins(
                    color: BarberTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Customer Info Card
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
                  'Customer',
                  style: GoogleFonts.poppins(
                    color: BarberTheme.accentColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: BarberTheme.accentColor.withOpacity(0.1),
                      ),
                      child: const Icon(Icons.person_rounded,
                          color: BarberTheme.accentColor, size: 28),
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
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (udhaar.customerPhone != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              udhaar.customerPhone!,
                              style: GoogleFonts.poppins(
                                color: BarberTheme.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (udhaar.customerPhone != null) ...[
                      IconButton(
                        onPressed: () => _makeCall(udhaar.customerPhone!),
                        icon: const Icon(Icons.call_rounded,
                            color: BarberTheme.successColor),
                      ),
                      IconButton(
                        onPressed: () => _sendWhatsApp(udhaar.customerPhone!),
                        icon: const Icon(Icons.message_rounded,
                            color: BarberTheme.accentColor),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Amount Details Card
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
                  'Amount Details',
                  style: GoogleFonts.poppins(
                    color: BarberTheme.accentColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                _buildAmountRow('Total Amount', udhaar.totalAmount,
                    BarberTheme.textPrimary, currencyFormat),
                const SizedBox(height: 12),
                _buildAmountRow('Paid Amount', udhaar.paidAmount,
                    BarberTheme.successColor, currencyFormat),
                const Divider(color: BarberTheme.primaryColor, height: 24),
                _buildAmountRow('Remaining', udhaar.remainingAmount,
                    _getStatusColor(), currencyFormat,
                    isBold: true),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Date Info
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
                  'Dates',
                  style: GoogleFonts.poppins(
                    color: BarberTheme.accentColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                _buildDateRow('Created', udhaar.createdAt),
                if (udhaar.dueDate != null) ...[
                  const SizedBox(height: 8),
                  _buildDateRow('Due Date', udhaar.dueDate!, isDue: true),
                ],
                const SizedBox(height: 8),
                _buildDateRow('Last Updated', udhaar.updatedAt),
              ],
            ),
          ),

          // Notes
          if (udhaar.notes != null && udhaar.notes!.isNotEmpty) ...[
            const SizedBox(height: 16),
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
                    'Notes',
                    style: GoogleFonts.poppins(
                      color: BarberTheme.accentColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    udhaar.notes!,
                    style: GoogleFonts.poppins(
                      color: BarberTheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Payment History
          Text(
            'Payment History',
            style: GoogleFonts.poppins(
              color: BarberTheme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          if (udhaar.payments.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: BarberTheme.cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.receipt_long_rounded,
                        color: BarberTheme.textSecondary.withOpacity(0.5),
                        size: 40),
                    const SizedBox(height: 8),
                    Text(
                      'No payments yet',
                      style: GoogleFonts.poppins(
                          color: BarberTheme.textSecondary, fontSize: 14),
                    ),
                  ],
                ),
              ),
            )
          else
            ...udhaar.payments
                .map((payment) => _buildPaymentCard(payment, currencyFormat)),

          // Add Payment Button
          if (udhaar.status != 'paid') ...[
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () => _showAddPaymentDialog(context),
                icon: const Icon(Icons.add_rounded),
                label: Text(
                  'Add Payment',
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: BarberTheme.successColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildAmountRow(
      String label, double amount, Color color, NumberFormat format,
      {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: BarberTheme.textSecondary,
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        Text(
          'Rs ${format.format(amount)}',
          style: GoogleFonts.poppins(
            color: color,
            fontSize: isBold ? 22 : 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildDateRow(String label, DateTime date, {bool isDue = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: BarberTheme.textSecondary,
            fontSize: 13,
          ),
        ),
        Text(
          DateFormat('dd MMMM yyyy, hh:mm a').format(date),
          style: GoogleFonts.poppins(
            color: isDue && date.isBefore(DateTime.now())
                ? BarberTheme.dangerColor
                : BarberTheme.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentCard(UdhaarPayment payment, NumberFormat format) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BarberTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: BarberTheme.successColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: BarberTheme.successColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.check_rounded,
                color: BarberTheme.successColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rs ${format.format(payment.amount)}',
                  style: GoogleFonts.poppins(
                    color: BarberTheme.successColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('dd MMM yyyy, hh:mm a')
                      .format(payment.paymentDate),
                  style: GoogleFonts.poppins(
                      color: BarberTheme.textSecondary, fontSize: 12),
                ),
                if (payment.paymentMethod != null)
                  Text(
                    payment.paymentMethod!,
                    style: GoogleFonts.poppins(
                        color: BarberTheme.textSecondary, fontSize: 11),
                  ),
              ],
            ),
          ),
          if (payment.notes != null && payment.notes!.isNotEmpty)
            IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: BarberTheme.cardColor,
                    title: Text('Notes',
                        style: GoogleFonts.poppins(
                            color: BarberTheme.textPrimary)),
                    content: Text(payment.notes!,
                        style: GoogleFonts.poppins(
                            color: BarberTheme.textSecondary)),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Close',
                            style: GoogleFonts.poppins(
                                color: BarberTheme.accentColor)),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.notes_rounded,
                  color: BarberTheme.accentColor, size: 18),
            ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert,
                color: BarberTheme.textSecondary, size: 18),
            color: BarberTheme.cardColor,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: (value) {
              if (value == 'delete') {
                _deletePayment(payment);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(Icons.delete,
                        color: BarberTheme.dangerColor, size: 18),
                    const SizedBox(width: 8),
                    Text('Delete Payment',
                        style: GoogleFonts.poppins(
                            color: BarberTheme.dangerColor)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (_udhaar!.status) {
      case 'paid':
        return BarberTheme.successColor;
      case 'partial':
        return BarberTheme.warningColor;
      default:
        return BarberTheme.dangerColor;
    }
  }

  IconData _getStatusIcon() {
    switch (_udhaar!.status) {
      case 'paid':
        return Icons.check_circle_rounded;
      case 'partial':
        return Icons.pending_rounded;
      default:
        return Icons.error_rounded;
    }
  }

  Future<void> _makeCall(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    final Uri launchUri = Uri(scheme: 'tel', path: cleanPhone);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  Future<void> _sendWhatsApp(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    final currencyFormat = NumberFormat('#,##0');
    final message =
        'Reminder: Your pending payment of Rs ${currencyFormat.format(_udhaar!.remainingAmount)} is due. '
        'Total: Rs ${currencyFormat.format(_udhaar!.totalAmount)}, Paid: Rs ${currencyFormat.format(_udhaar!.paidAmount)}. - The Barber';
    final Uri launchUri = Uri.parse(
        'https://wa.me/$cleanPhone?text=${Uri.encodeComponent(message)}');
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri, mode: LaunchMode.externalApplication);
    }
  }

  void _handleMenuAction(String action, BuildContext context) {
    switch (action) {
      case 'add_payment':
        _showAddPaymentDialog(context);
        break;
      case 'remind':
        if (_udhaar!.customerPhone != null) {
          _sendWhatsApp(_udhaar!.customerPhone!);
        }
        break;
      case 'delete':
        _deleteUdhaar(context);
        break;
    }
  }

  void _showAddPaymentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddPaymentDialog(udhaar: _udhaar!),
    ).then((_) {
      _loadUdhaar();
    });
  }

  Future<void> _deleteUdhaar(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: BarberTheme.cardColor,
        title: Text('Delete Udhaar',
            style: GoogleFonts.poppins(color: BarberTheme.dangerColor)),
        content: Text(
          'Delete this udhaar entry and all payment history?',
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
      final success =
          await context.read<UdhaarProvider>().deleteUdhaar(_udhaar!.id!);
      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Udhaar entry deleted'),
            backgroundColor: BarberTheme.dangerColor,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  Future<void> _deletePayment(UdhaarPayment payment) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: BarberTheme.cardColor,
        title: Text('Delete Payment',
            style: GoogleFonts.poppins(color: BarberTheme.dangerColor)),
        content: Text(
          'Delete this payment of Rs ${NumberFormat('#,##0').format(payment.amount)}?',
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

    if (confirm == true && payment.id != null) {
      final success =
          await context.read<UdhaarProvider>().deleteUdhaar(payment.id!);
      if (success) {
        _loadUdhaar();
      }
    }
  }
}

// Import for AddPaymentDialog
