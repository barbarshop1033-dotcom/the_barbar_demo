import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme.dart';
import '../../providers/udhaar_provider.dart';
import '../../providers/customer_provider.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/udhaar_card.dart';
import '../../models/udhaar_model.dart';
import '../../models/customer_model.dart';

class UdhaarListScreen extends StatefulWidget {
  const UdhaarListScreen({super.key});

  @override
  State<UdhaarListScreen> createState() => _UdhaarListScreenState();
}

class _UdhaarListScreenState extends State<UdhaarListScreen> {
  final _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UdhaarProvider>().loadUdhaarEntries();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: _isSearching ? '' : 'Udhaar Book',
        showBackButton: false,
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search_rounded,
              color: BarberTheme.accentColor,
            ),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  context.read<UdhaarProvider>().setSearchQuery('');
                }
              });
            },
          ),
          if (!_isSearching)
            PopupMenuButton<String>(
              icon: const Icon(Icons.filter_list_rounded,
                  color: BarberTheme.accentColor),
              color: BarberTheme.cardColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              onSelected: (value) {
                context.read<UdhaarProvider>().setStatusFilter(value);
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'all',
                  child: Row(
                    children: [
                      const Icon(Icons.list_rounded,
                          color: BarberTheme.accentColor, size: 20),
                      const SizedBox(width: 8),
                      Text('All',
                          style: GoogleFonts.poppins(
                              color: BarberTheme.textPrimary)),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'pending',
                  child: Row(
                    children: [
                      const Icon(Icons.pending_rounded,
                          color: BarberTheme.dangerColor, size: 20),
                      const SizedBox(width: 8),
                      Text('Pending',
                          style: GoogleFonts.poppins(
                              color: BarberTheme.textPrimary)),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'partial',
                  child: Row(
                    children: [
                      const Icon(Icons.pending_actions_rounded,
                          color: BarberTheme.warningColor, size: 20),
                      const SizedBox(width: 8),
                      Text('Partial',
                          style: GoogleFonts.poppins(
                              color: BarberTheme.textPrimary)),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'paid',
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded,
                          color: BarberTheme.successColor, size: 20),
                      const SizedBox(width: 8),
                      Text('Paid',
                          style: GoogleFonts.poppins(
                              color: BarberTheme.textPrimary)),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      drawer: const AppDrawer(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddUdhaarDialog(context),
        backgroundColor: BarberTheme.accentColor,
        foregroundColor: BarberTheme.primaryColor,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          'Add Udhaar',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          if (_isSearching)
            Container(
              padding: const EdgeInsets.all(16),
              color: BarberTheme.primaryColor,
              child: TextField(
                controller: _searchController,
                autofocus: true,
                style: GoogleFonts.poppins(color: BarberTheme.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Search by customer name or phone...',
                  hintStyle:
                      GoogleFonts.poppins(color: BarberTheme.textSecondary),
                  prefixIcon:
                      const Icon(Icons.search, color: BarberTheme.accentColor),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear,
                              color: BarberTheme.textSecondary),
                          onPressed: () {
                            _searchController.clear();
                            context.read<UdhaarProvider>().setSearchQuery('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: BarberTheme.surfaceColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (query) {
                  context.read<UdhaarProvider>().setSearchQuery(query);
                  setState(() {});
                },
              ),
            ),

          // Summary Bar
          _buildSummaryBar(),

          // Filter Chips
          _buildFilterChips(),

          // Udhaar List
          Expanded(
            child: Consumer<UdhaarProvider>(
              builder: (context, udhaarProvider, _) {
                if (udhaarProvider.isLoading) {
                  return const LoadingWidget(
                      message: 'Loading udhaar entries...');
                }

                if (udhaarProvider.udhaarEntries.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.book_rounded,
                    title: 'No Udhaar Entries',
                    message: _isSearching
                        ? 'No entries match your search'
                        : 'Track customer credit and pending payments',
                    actionLabel: _isSearching ? null : 'Add Udhaar Entry',
                    onAction: _isSearching
                        ? null
                        : () => _showAddUdhaarDialog(context),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => udhaarProvider.loadUdhaarEntries(),
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 100),
                    itemCount: udhaarProvider.udhaarEntries.length,
                    itemBuilder: (context, index) {
                      final udhaar = udhaarProvider.udhaarEntries[index];
                      return UdhaarCard(
                        udhaar: udhaar,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/udhaar/detail',
                            arguments: {'udhaarId': udhaar.id},
                          ).then((_) {
                            udhaarProvider.loadUdhaarEntries();
                          });
                        },
                        onAddPayment: () =>
                            _showAddPaymentDialog(context, udhaar),
                        onRemind: () => _sendWhatsAppReminder(udhaar),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryBar() {
    return Consumer<UdhaarProvider>(
      builder: (context, provider, _) {
        final currencyFormat = NumberFormat('#,##0');

        return Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                BarberTheme.warningColor.withOpacity(0.15),
                BarberTheme.warningColor.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border:
                Border.all(color: BarberTheme.warningColor.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Total Udhaar',
                  'Rs ${currencyFormat.format(provider.totalUdhaar)}',
                  Icons.receipt_long_rounded,
                  BarberTheme.warningColor,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: BarberTheme.warningColor.withOpacity(0.3),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Total Paid',
                  'Rs ${currencyFormat.format(provider.totalPaid)}',
                  Icons.check_circle_rounded,
                  BarberTheme.successColor,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: BarberTheme.warningColor.withOpacity(0.3),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Remaining',
                  'Rs ${currencyFormat.format(provider.totalRemaining)}',
                  Icons.pending_rounded,
                  BarberTheme.dangerColor,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            color: BarberTheme.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            color: BarberTheme.textSecondary,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    return Consumer<UdhaarProvider>(
      builder: (context, provider, _) {
        final filters = [
          {'label': 'All', 'value': 'all'},
          {'label': 'Pending', 'value': 'pending'},
          {'label': 'Partial', 'value': 'partial'},
          {'label': 'Paid', 'value': 'paid'},
        ];

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: filters.map((filter) {
              final isSelected = provider.statusFilter == filter['value'];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(
                    filter['label']!,
                    style: GoogleFonts.poppins(
                      color: isSelected
                          ? BarberTheme.primaryColor
                          : BarberTheme.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (_) => provider.setStatusFilter(filter['value']!),
                  selectedColor: BarberTheme.accentColor,
                  backgroundColor: BarberTheme.cardColor,
                  checkmarkColor: BarberTheme.primaryColor,
                  side: BorderSide(
                    color: isSelected
                        ? BarberTheme.accentColor
                        : BarberTheme.cardColor,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Future<void> _sendWhatsAppReminder(UdhaarModel udhaar) async {
    final phone = udhaar.customerPhone?.replaceAll(RegExp(r'\D'), '') ?? '';
    if (phone.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('No phone number available'),
            backgroundColor: BarberTheme.dangerColor,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
      return;
    }

    final currencyFormat = NumberFormat('#,##0');
    final message =
        'Reminder: Your pending payment of Rs ${currencyFormat.format(udhaar.remainingAmount)} is due. '
        'Total: Rs ${currencyFormat.format(udhaar.totalAmount)}, Paid: Rs ${currencyFormat.format(udhaar.paidAmount)}. '
        'Please clear at your earliest convenience. - The Barber';

    final Uri launchUri =
        Uri.parse('https://wa.me/$phone?text=${Uri.encodeComponent(message)}');

    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri, mode: LaunchMode.externalApplication);
    }
  }

  void _showAddUdhaarDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddUdhaarDialog(),
    ).then((_) {
      context.read<UdhaarProvider>().loadUdhaarEntries();
    });
  }

  void _showAddPaymentDialog(BuildContext context, UdhaarModel udhaar) {
    showDialog(
      context: context,
      builder: (context) => AddPaymentDialog(udhaar: udhaar),
    ).then((_) {
      context.read<UdhaarProvider>().loadUdhaarEntries();
    });
  }
}

class AddUdhaarDialog extends StatefulWidget {
  const AddUdhaarDialog({super.key});

  @override
  State<AddUdhaarDialog> createState() => _AddUdhaarDialogState();
}

class _AddUdhaarDialogState extends State<AddUdhaarDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  CustomerModel? _selectedCustomer;
  DateTime? _dueDate;
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        decoration: BoxDecoration(
          color: BarberTheme.surfaceColor,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: BarberTheme.primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: BarberTheme.warningColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.book_rounded,
                        color: BarberTheme.warningColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Add Udhaar Entry',
                      style: GoogleFonts.playfairDisplay(
                        color: BarberTheme.accentColor,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close,
                        color: BarberTheme.textSecondary),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Customer Selection
                      Text(
                        'Customer',
                        style: GoogleFonts.poppins(
                          color: BarberTheme.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => _showCustomerPicker(context),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: BarberTheme.cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color:
                                    BarberTheme.accentColor.withOpacity(0.2)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color:
                                      BarberTheme.accentColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.person_rounded,
                                    color: BarberTheme.accentColor),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _selectedCustomer != null
                                    ? Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _selectedCustomer!.name,
                                            style: GoogleFonts.poppins(
                                              color: BarberTheme.textPrimary,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            _selectedCustomer!.phone,
                                            style: GoogleFonts.poppins(
                                              color: BarberTheme.textSecondary,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      )
                                    : Text(
                                        'Select Customer',
                                        style: GoogleFonts.poppins(
                                            color: BarberTheme.textSecondary),
                                      ),
                              ),
                              const Icon(Icons.chevron_right,
                                  color: BarberTheme.textSecondary),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Amount Field
                      TextFormField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        style: GoogleFonts.poppins(
                          color: BarberTheme.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Total Amount *',
                          prefixText: 'Rs ',
                          prefixIcon: const Icon(Icons.monetization_on_rounded,
                              color: BarberTheme.accentColor),
                          labelStyle: GoogleFonts.poppins(
                              color: BarberTheme.textSecondary),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty)
                            return 'Amount is required';
                          if (double.tryParse(v) == null ||
                              double.parse(v) <= 0)
                            return 'Valid amount required';
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Due Date
                      Text(
                        'Due Date (Optional)',
                        style: GoogleFonts.poppins(
                          color: BarberTheme.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate:
                                DateTime.now().add(const Duration(days: 7)),
                            firstDate: DateTime.now(),
                            lastDate:
                                DateTime.now().add(const Duration(days: 365)),
                            builder: (context, child) => Theme(
                              data: ThemeData.dark().copyWith(
                                colorScheme: const ColorScheme.dark(
                                  primary: BarberTheme.accentColor,
                                ),
                              ),
                              child: child!,
                            ),
                          );
                          if (date != null) setState(() => _dueDate = date);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: BarberTheme.cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color:
                                    BarberTheme.accentColor.withOpacity(0.2)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today_rounded,
                                  color: BarberTheme.accentColor),
                              const SizedBox(width: 12),
                              Text(
                                _dueDate != null
                                    ? DateFormat('dd MMMM yyyy')
                                        .format(_dueDate!)
                                    : 'Select due date',
                                style: GoogleFonts.poppins(
                                  color: _dueDate != null
                                      ? BarberTheme.textPrimary
                                      : BarberTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Notes
                      TextFormField(
                        controller: _notesController,
                        maxLines: 2,
                        style:
                            GoogleFonts.poppins(color: BarberTheme.textPrimary),
                        decoration: InputDecoration(
                          labelText: 'Notes (Optional)',
                          prefixIcon: const Icon(Icons.notes_rounded,
                              color: BarberTheme.accentColor),
                          labelStyle: GoogleFonts.poppins(
                              color: BarberTheme.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Button
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: BarberTheme.primaryColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () => _saveUdhaar(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BarberTheme.accentColor,
                    foregroundColor: BarberTheme.primaryColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                BarberTheme.primaryColor),
                          ),
                        )
                      : Text(
                          'Save Udhaar Entry',
                          style: GoogleFonts.poppins(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showCustomerPicker(BuildContext context) async {
    final customers = context.read<CustomerProvider>().allCustomers;

    final result = await showDialog<CustomerModel>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: BarberTheme.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 500),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Customer',
                style: GoogleFonts.poppins(
                  color: BarberTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: customers.length,
                  itemBuilder: (context, index) {
                    final customer = customers[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            BarberTheme.accentColor.withOpacity(0.2),
                        child: const Icon(Icons.person,
                            color: BarberTheme.accentColor),
                      ),
                      title: Text(customer.name,
                          style: GoogleFonts.poppins(
                              color: BarberTheme.textPrimary)),
                      subtitle: Text(customer.phone,
                          style: GoogleFonts.poppins(
                              color: BarberTheme.textSecondary)),
                      onTap: () => Navigator.pop(context, customer),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (result != null) {
      setState(() => _selectedCustomer = result);
    }
  }

  Future<void> _saveUdhaar(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a customer'),
          backgroundColor: BarberTheme.warningColor,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final udhaar = UdhaarModel(
      customerId: _selectedCustomer!.id!,
      customerName: _selectedCustomer!.name,
      customerPhone: _selectedCustomer!.phone,
      totalAmount: double.parse(_amountController.text),
      paidAmount: 0,
      dueDate: _dueDate,
      status: 'pending',
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
    );

    final success = await context.read<UdhaarProvider>().addUdhaar(udhaar);

    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Udhaar entry added'),
          backgroundColor: BarberTheme.successColor,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }
}

class AddPaymentDialog extends StatefulWidget {
  final UdhaarModel udhaar;

  const AddPaymentDialog({super.key, required this.udhaar});

  @override
  State<AddPaymentDialog> createState() => _AddPaymentDialogState();
}

class _AddPaymentDialogState extends State<AddPaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  String _paymentMethod = 'Cash';
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat('#,##0');

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        decoration: BoxDecoration(
          color: BarberTheme.surfaceColor,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: BarberTheme.primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: BarberTheme.successColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.payments_rounded,
                        color: BarberTheme.successColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add Payment',
                          style: GoogleFonts.playfairDisplay(
                            color: BarberTheme.accentColor,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Remaining: Rs ${currencyFormat.format(widget.udhaar.remainingAmount)}',
                          style: GoogleFonts.poppins(
                            color: BarberTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close,
                        color: BarberTheme.textSecondary),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        style: GoogleFonts.poppins(
                          color: BarberTheme.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Amount *',
                          prefixText: 'Rs ',
                          prefixIcon: const Icon(Icons.monetization_on_rounded,
                              color: BarberTheme.accentColor),
                          labelStyle: GoogleFonts.poppins(
                              color: BarberTheme.textSecondary),
                          helperText:
                              'Max: Rs ${currencyFormat.format(widget.udhaar.remainingAmount)}',
                          helperStyle: GoogleFonts.poppins(
                              color: BarberTheme.textSecondary, fontSize: 11),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Required';
                          final amount = double.tryParse(v);
                          if (amount == null || amount <= 0)
                            return 'Valid amount required';
                          if (amount > widget.udhaar.remainingAmount)
                            return 'Exceeds remaining amount';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _paymentMethod,
                        dropdownColor: BarberTheme.cardColor,
                        style:
                            GoogleFonts.poppins(color: BarberTheme.textPrimary),
                        decoration: InputDecoration(
                          labelText: 'Payment Method',
                          prefixIcon: const Icon(Icons.payment_rounded,
                              color: BarberTheme.accentColor),
                          labelStyle: GoogleFonts.poppins(
                              color: BarberTheme.textSecondary),
                        ),
                        items: [
                          'Cash',
                          'JazzCash',
                          'EasyPaisa',
                          'Bank Transfer'
                        ]
                            .map((m) =>
                                DropdownMenuItem(value: m, child: Text(m)))
                            .toList(),
                        onChanged: (v) => setState(() => _paymentMethod = v!),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _notesController,
                        maxLines: 2,
                        style:
                            GoogleFonts.poppins(color: BarberTheme.textPrimary),
                        decoration: InputDecoration(
                          labelText: 'Notes (Optional)',
                          prefixIcon: const Icon(Icons.notes_rounded,
                              color: BarberTheme.accentColor),
                          labelStyle: GoogleFonts.poppins(
                              color: BarberTheme.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: BarberTheme.primaryColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () => _savePayment(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BarberTheme.successColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white)),
                        )
                      : Text('Add Payment',
                          style: GoogleFonts.poppins(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _savePayment(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final payment = UdhaarPayment(
      udhaarId: widget.udhaar.id!,
      amount: double.parse(_amountController.text),
      paymentMethod: _paymentMethod,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
    );

    final success = await context.read<UdhaarProvider>().addPayment(payment);

    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Payment added successfully'),
          backgroundColor: BarberTheme.successColor,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }
}
