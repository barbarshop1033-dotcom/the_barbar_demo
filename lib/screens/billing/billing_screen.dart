import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/bill_provider.dart';
import '../../providers/customer_provider.dart';
import '../../providers/service_provider.dart';
import '../../providers/worker_provider.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/bill_card.dart';
import '../../models/customer_model.dart';
import '../../models/service_model.dart';
import '../../models/worker_model.dart';
import '../../models/bill_model.dart';

class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BillProvider>().loadBills();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Billing',
        showBackButton: false,
      ),
      drawer: const AppDrawer(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateBillDialog(context),
        backgroundColor: BarberTheme.accentColor,
        foregroundColor: BarberTheme.primaryColor,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          'New Bill',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      body: Consumer<BillProvider>(
        builder: (context, billProvider, _) {
          if (billProvider.isLoading) {
            return const LoadingWidget(message: 'Loading bills...');
          }

          return Column(
            children: [
              // Summary Cards
              _buildSummaryRow(billProvider),

              // Filter Chips
              _buildFilterChips(billProvider),

              const SizedBox(height: 8),

              // Bills List
              Expanded(
                child: billProvider.bills.isEmpty
                    ? const EmptyStateWidget(
                        icon: Icons.receipt_long_rounded,
                        title: 'No Bills',
                        message:
                            'Create your first bill by tapping the button below',
                        actionLabel: 'Create Bill',
                      )
                    : RefreshIndicator(
                        onRefresh: () => billProvider.loadBills(),
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 100),
                          itemCount: billProvider.bills.length,
                          itemBuilder: (context, index) {
                            final bill = billProvider.bills[index];
                            return BillCard(
                              bill: bill,
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/billing/detail',
                                  arguments: {'billId': bill.id},
                                );
                              },
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryRow(BillProvider provider) {
    final currencyFormat = NumberFormat('#,##0');

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryItem(
              'Today',
              'Rs ${currencyFormat.format(provider.todayEarnings)}',
              Icons.today_rounded,
              BarberTheme.successColor,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: BarberTheme.accentColor.withOpacity(0.3),
          ),
          Expanded(
            child: _buildSummaryItem(
              'This Week',
              'Rs ${currencyFormat.format(provider.weekEarnings)}',
              Icons.calendar_view_week_rounded,
              BarberTheme.accentColor,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: BarberTheme.accentColor.withOpacity(0.3),
          ),
          Expanded(
            child: _buildSummaryItem(
              'This Month',
              'Rs ${currencyFormat.format(provider.monthEarnings)}',
              Icons.calendar_month_rounded,
              BarberTheme.warningColor,
            ),
          ),
        ],
      ),
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
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            color: BarberTheme.textSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips(BillProvider provider) {
    final filters = [
      {'label': 'All', 'value': 'all'},
      {'label': 'Paid', 'value': 'paid'},
      {'label': 'Unpaid', 'value': 'unpaid'},
      {'label': 'Partial', 'value': 'partial'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: filters.map((filter) {
          final isSelected = provider.paymentFilter == filter['value'];
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
              onSelected: (_) => provider.setPaymentFilter(filter['value']!),
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
  }

  void _showCreateBillDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const CreateBillDialog(),
    ).then((_) {
      // Refresh bills after dialog closes
      context.read<BillProvider>().loadBills();
    });
  }
}

class CreateBillDialog extends StatefulWidget {
  const CreateBillDialog({super.key});

  @override
  State<CreateBillDialog> createState() => _CreateBillDialogState();
}

class _CreateBillDialogState extends State<CreateBillDialog> {
  final _currencyFormat = NumberFormat('#,##0');

  // Selected items
  CustomerModel? _selectedCustomer;
  WorkerModel? _selectedWorker;
  final List<BillItem> _selectedServices = [];

  // Payment
  String _paymentMethod = 'Cash';
  String _paymentStatus = 'paid';
  double _discount = 0;
  final _notesController = TextEditingController();

  // Calculations
  double get _subtotal =>
      _selectedServices.fold(0, (sum, item) => sum + item.total);
  double get _finalAmount => _subtotal - _discount;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
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
                  Expanded(
                    child: Text(
                      'Create New Bill',
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Customer Selection
                    _buildCustomerSection(),
                    const SizedBox(height: 16),

                    // Services Section
                    _buildServicesSection(),
                    const SizedBox(height: 16),

                    // Worker Selection
                    _buildWorkerSection(),
                    const SizedBox(height: 16),

                    // Payment Details
                    _buildPaymentSection(),
                    const SizedBox(height: 16),

                    // Notes
                    TextField(
                      controller: _notesController,
                      maxLines: 2,
                      style:
                          GoogleFonts.poppins(color: BarberTheme.textPrimary),
                      decoration: InputDecoration(
                        labelText: 'Notes (Optional)',
                        hintText: 'Add any notes...',
                        labelStyle: GoogleFonts.poppins(
                            color: BarberTheme.textSecondary),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Totals
                    _buildTotalsSection(),
                  ],
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
                  onPressed: _canCreateBill ? () => _createBill(context) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BarberTheme.accentColor,
                    foregroundColor: BarberTheme.primaryColor,
                    disabledBackgroundColor: BarberTheme.textSecondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Create Bill - Rs ${_currencyFormat.format(_finalAmount)}',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool get _canCreateBill =>
      _selectedCustomer != null && _selectedServices.isNotEmpty;

  Widget _buildCustomerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
              border:
                  Border.all(color: BarberTheme.accentColor.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: BarberTheme.accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.person_rounded,
                      color: BarberTheme.accentColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _selectedCustomer != null
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
      ],
    );
  }

  Widget _buildServicesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Services',
              style: GoogleFonts.poppins(
                color: BarberTheme.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            TextButton.icon(
              onPressed: () => _showServicePicker(context),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text(
                'Add Service',
                style: GoogleFonts.poppins(fontSize: 12),
              ),
              style: TextButton.styleFrom(
                  foregroundColor: BarberTheme.accentColor),
            ),
          ],
        ),
        if (_selectedServices.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: BarberTheme.cardColor,
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: BarberTheme.accentColor.withOpacity(0.1)),
            ),
            child: Column(
              children: [
                Icon(Icons.content_cut_rounded,
                    color: BarberTheme.textSecondary.withOpacity(0.5),
                    size: 32),
                const SizedBox(height: 8),
                Text(
                  'No services added',
                  style: GoogleFonts.poppins(
                      color: BarberTheme.textSecondary, fontSize: 13),
                ),
              ],
            ),
          )
        else
          ...List.generate(_selectedServices.length, (index) {
            final item = _selectedServices[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: BarberTheme.cardColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.serviceName,
                          style: GoogleFonts.poppins(
                              color: BarberTheme.textPrimary,
                              fontWeight: FontWeight.w500),
                        ),
                        Text(
                          '${item.quantity}x Rs ${_currencyFormat.format(item.price)}',
                          style: GoogleFonts.poppins(
                              color: BarberTheme.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Rs ${_currencyFormat.format(item.total)}',
                    style: GoogleFonts.poppins(
                      color: BarberTheme.accentColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline,
                        color: BarberTheme.dangerColor, size: 20),
                    onPressed: () {
                      setState(() => _selectedServices.removeAt(index));
                    },
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  Widget _buildWorkerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Assigned Barber (Optional)',
          style: GoogleFonts.poppins(
            color: BarberTheme.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _showWorkerPicker(context),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: BarberTheme.cardColor,
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: BarberTheme.accentColor.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: BarberTheme.accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.badge_rounded,
                      color: BarberTheme.accentColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _selectedWorker != null
                      ? Text(
                          _selectedWorker!.name,
                          style: GoogleFonts.poppins(
                              color: BarberTheme.textPrimary,
                              fontWeight: FontWeight.w500),
                        )
                      : Text(
                          'Select Barber',
                          style: GoogleFonts.poppins(
                              color: BarberTheme.textSecondary),
                        ),
                ),
                if (_selectedWorker != null)
                  IconButton(
                    icon: const Icon(Icons.close,
                        color: BarberTheme.textSecondary, size: 18),
                    onPressed: () => setState(() => _selectedWorker = null),
                  ),
                const Icon(Icons.chevron_right,
                    color: BarberTheme.textSecondary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentSection() {
    final paymentMethods = ['Cash', 'JazzCash', 'EasyPaisa', 'Bank Transfer'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment',
          style: GoogleFonts.poppins(
            color: BarberTheme.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        // Payment Method
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: BarberTheme.cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: _paymentMethod,
                dropdownColor: BarberTheme.cardColor,
                style: GoogleFonts.poppins(color: BarberTheme.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Method',
                  labelStyle:
                      GoogleFonts.poppins(color: BarberTheme.textSecondary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                        color: BarberTheme.accentColor.withOpacity(0.2)),
                  ),
                ),
                items: paymentMethods
                    .map((method) => DropdownMenuItem(
                          value: method,
                          child: Text(method),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _paymentMethod = v!),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Status',
                          style: GoogleFonts.poppins(
                              color: BarberTheme.textSecondary, fontSize: 12),
                        ),
                        Row(
                          children: [
                            _buildStatusChip('paid', 'Paid'),
                            const SizedBox(width: 8),
                            _buildStatusChip('unpaid', 'Unpaid'),
                            const SizedBox(width: 8),
                            _buildStatusChip('partial', 'Partial'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Discount
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: _discount.toString(),
                      keyboardType: TextInputType.number,
                      style:
                          GoogleFonts.poppins(color: BarberTheme.textPrimary),
                      decoration: InputDecoration(
                        labelText: 'Discount',
                        prefixText: 'Rs ',
                        labelStyle: GoogleFonts.poppins(
                            color: BarberTheme.textSecondary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onChanged: (v) {
                        setState(() {
                          _discount = double.tryParse(v) ?? 0;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String value, String label) {
    final isSelected = _paymentStatus == value;
    return GestureDetector(
      onTap: () => setState(() => _paymentStatus = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? BarberTheme.accentColor.withOpacity(0.2)
              : BarberTheme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? BarberTheme.accentColor
                : BarberTheme.textSecondary.withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            color: isSelected
                ? BarberTheme.accentColor
                : BarberTheme.textSecondary,
            fontSize: 11,
          ),
        ),
      ),
    );
  }

  Widget _buildTotalsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BarberTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: BarberTheme.accentColor.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          _buildTotalRow('Subtotal', _subtotal),
          if (_discount > 0)
            _buildTotalRow('Discount', -_discount,
                color: BarberTheme.dangerColor),
          const Divider(color: BarberTheme.textSecondary),
          _buildTotalRow('Total', _finalAmount,
              isBold: true, color: BarberTheme.accentColor),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, double amount,
      {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              color: color ?? BarberTheme.textSecondary,
              fontSize: isBold ? 16 : 14,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          Text(
            'Rs ${_currencyFormat.format(amount.abs())}',
            style: GoogleFonts.poppins(
              color: color ?? BarberTheme.textPrimary,
              fontSize: isBold ? 18 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
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

  Future<void> _showServicePicker(BuildContext context) async {
    final services = context.read<ServiceProvider>().allServices;

    final result = await showDialog<ServiceModel>(
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
                'Add Service',
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
                  itemCount: services.length,
                  itemBuilder: (context, index) {
                    final service = services[index];
                    return ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: BarberTheme.accentColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.content_cut,
                            color: BarberTheme.accentColor),
                      ),
                      title: Text(service.name,
                          style: GoogleFonts.poppins(
                              color: BarberTheme.textPrimary)),
                      subtitle: Text(
                        'Rs ${_currencyFormat.format(service.price)} - ${service.duration}min',
                        style: GoogleFonts.poppins(
                            color: BarberTheme.textSecondary),
                      ),
                      onTap: () => Navigator.pop(context, service),
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
      setState(() {
        final existingIndex =
            _selectedServices.indexWhere((item) => item.serviceId == result.id);
        if (existingIndex != -1) {
          // Increase quantity
          final item = _selectedServices[existingIndex];
          _selectedServices[existingIndex] = BillItem(
            billId: item.billId,
            serviceId: item.serviceId,
            serviceName: item.serviceName,
            price: item.price,
            quantity: item.quantity + 1,
            total: item.price * (item.quantity + 1),
          );
        } else {
          _selectedServices.add(BillItem(
            billId: 0,
            serviceId: result.id!,
            serviceName: result.name,
            price: result.price,
            quantity: 1,
            total: result.price,
          ));
        }
      });
    }
  }

  Future<void> _showWorkerPicker(BuildContext context) async {
    final workers = context.read<WorkerProvider>().activeWorkers;

    final result = await showDialog<WorkerModel>(
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
                'Select Barber',
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
                  itemCount: workers.length,
                  itemBuilder: (context, index) {
                    final worker = workers[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            BarberTheme.accentColor.withOpacity(0.2),
                        child: const Icon(Icons.person,
                            color: BarberTheme.accentColor),
                      ),
                      title: Text(worker.name,
                          style: GoogleFonts.poppins(
                              color: BarberTheme.textPrimary)),
                      subtitle: Text(worker.role,
                          style: GoogleFonts.poppins(
                              color: BarberTheme.textSecondary)),
                      onTap: () => Navigator.pop(context, worker),
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
      setState(() => _selectedWorker = result);
    }
  }

  Future<void> _createBill(BuildContext context) async {
    final billProvider = context.read<BillProvider>();

    final bill = BillModel(
      customerId: _selectedCustomer!.id!,
      customerName: _selectedCustomer!.name,
      customerPhone: _selectedCustomer!.phone,
      workerId: _selectedWorker?.id,
      workerName: _selectedWorker?.name,
      totalAmount: _subtotal,
      discount: _discount,
      tax: 0,
      finalAmount: _finalAmount,
      paymentMethod: _paymentMethod,
      paymentStatus: _paymentStatus,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      items: _selectedServices,
    );

    final billId = await billProvider.createBill(bill);

    if (billId != null && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bill #$billId created successfully'),
          backgroundColor: BarberTheme.successColor,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }
}

// Add these imports at the top
