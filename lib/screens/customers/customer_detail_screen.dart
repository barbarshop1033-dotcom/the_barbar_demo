import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/bill_model.dart';
import '../../models/udhaar_model.dart';
import '../billing/billing_screen.dart';
import 'customers_list_screen.dart';
import '../../config/theme.dart';
import '../../providers/customer_provider.dart';
import '../../providers/bill_provider.dart';
import '../../providers/udhaar_provider.dart';
import '../../providers/visit_provider.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/bill_card.dart';
import '../../widgets/udhaar_card.dart';
import '../../models/customer_model.dart';
import '../../models/visit_model.dart';

class CustomerDetailScreen extends StatefulWidget {
  final int customerId;

  const CustomerDetailScreen({super.key, required this.customerId});

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen>
    with SingleTickerProviderStateMixin {
  CustomerModel? _customer;
  List<VisitModel> _visits = [];
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final customerProvider = context.read<CustomerProvider>();
    final visitProvider = context.read<VisitProvider>();

    _customer = await customerProvider.getCustomerById(widget.customerId);
    _visits = await visitProvider.getCustomerVisits(widget.customerId);

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: _customer?.name ?? 'Customer Details',
        actions: [
          IconButton(
            icon: const Icon(
              Icons.edit_rounded,
              color: BarberTheme.accentColor,
            ),
            onPressed: () => _showEditDialog(),
          ),
          IconButton(
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: BarberTheme.dangerColor,
            ),
            onPressed: () => _deleteCustomer(),
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'Loading customer details...')
          : _customer == null
          ? Center(
              child: Text(
                'Customer not found',
                style: GoogleFonts.poppins(color: BarberTheme.textSecondary),
              ),
            )
          : Column(
              children: [
                // Customer Profile Header
                _buildProfileHeader(),

                // Quick Action Buttons
                _buildQuickActions(),

                // Tabs
                Container(
                  color: BarberTheme.primaryColor,
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: BarberTheme.accentColor,
                    labelColor: BarberTheme.accentColor,
                    unselectedLabelColor: BarberTheme.textSecondary,
                    labelStyle: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    tabs: const [
                      Tab(text: 'Info'),
                      Tab(text: 'Visits'),
                      Tab(text: 'Bills'),
                      Tab(text: 'Udhaar'),
                    ],
                  ),
                ),

                // Tab Content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildInfoTab(),
                      _buildVisitsTab(),
                      _buildBillsTab(),
                      _buildUdhaarTab(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildProfileHeader() {
    final customer = _customer!;
    final currencyFormat = NumberFormat('#,##0');

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [BarberTheme.primaryColor, BarberTheme.surfaceColor],
        ),
      ),
      child: Column(
        children: [
          // Avatar
          Stack(
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: BarberTheme.accentColor.withOpacity(0.1),
                  border: Border.all(color: BarberTheme.accentColor, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: BarberTheme.accentColor.withOpacity(0.2),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: BarberTheme.accentColor,
                  size: 48,
                ),
              ),
              if (customer.isRegular)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: BarberTheme.accentColor,
                    ),
                    child: const Icon(
                      Icons.star_rounded,
                      color: BarberTheme.primaryColor,
                      size: 18,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Name
          Text(
            customer.name,
            style: GoogleFonts.poppins(
              color: BarberTheme.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),

          // Phone
          Text(
            customer.phone,
            style: GoogleFonts.poppins(
              color: BarberTheme.textSecondary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),

          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStat(
                'Visits',
                '${customer.visitCount}',
                Icons.calendar_today_rounded,
              ),
              _buildStat(
                'Spent',
                'Rs ${currencyFormat.format(customer.totalSpent)}',
                Icons.monetization_on_rounded,
              ),
              _buildStat(
                'Last Visit',
                customer.lastVisitDate != null
                    ? DateFormat('dd/MM/yy').format(customer.lastVisitDate!)
                    : 'N/A',
                Icons.history_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: BarberTheme.accentColor, size: 20),
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

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: BarberTheme.surfaceColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(Icons.call_rounded, 'Call', () => _makeCall()),
          _buildActionButton(
            Icons.message_rounded,
            'WhatsApp',
            () => _sendWhatsApp(),
          ),
          _buildActionButton(
            Icons.receipt_long_rounded,
            'New Bill',
            () => _createBill(),
          ),
          _buildActionButton(
            Icons.book_rounded,
            'Add Udhaar',
            () => _addUdhaar(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: BarberTheme.accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: BarberTheme.accentColor, size: 22),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: BarberTheme.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTab() {
    final customer = _customer!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Customer Details Card
          _buildInfoCard('Customer Details', [
            _buildInfoRow('Name', customer.name),
            _buildInfoRow('Phone', customer.phone),
            if (customer.preferredWorker != null)
              _buildInfoRow('Preferred Barber', customer.preferredWorker!),
            _buildInfoRow(
              'Status',
              customer.isRegular ? 'Regular Customer ⭐' : 'Regular',
            ),
            _buildInfoRow('Total Visits', '${customer.visitCount}'),
            _buildInfoRow(
              'Total Spent',
              'Rs ${NumberFormat('#,##0').format(customer.totalSpent)}',
            ),
            if (customer.lastVisitDate != null)
              _buildInfoRow(
                'Last Visit',
                DateFormat('dd MMMM yyyy').format(customer.lastVisitDate!),
              ),
          ]),

          const SizedBox(height: 16),

          // Preferences Card
          if (customer.favoriteHairstyle != null ||
              customer.allergyNotes != null)
            _buildInfoCard('Preferences', [
              if (customer.favoriteHairstyle != null)
                _buildInfoRow(
                  'Favorite Hairstyle',
                  customer.favoriteHairstyle!,
                ),
              if (customer.allergyNotes != null)
                _buildInfoRow('Allergy Notes', customer.allergyNotes!),
            ]),

          const SizedBox(height: 16),

          // Notes Card
          if (customer.notes != null)
            _buildInfoCard('Notes', [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  customer.notes!,
                  style: GoogleFonts.poppins(
                    color: BarberTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ),
            ]),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
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
            title,
            style: GoogleFonts.poppins(
              color: BarberTheme.accentColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                color: BarberTheme.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                color: BarberTheme.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisitsTab() {
    if (_visits.isEmpty) {
      return _buildEmptyState(
        icon: Icons.assignment_rounded,
        title: 'No Visits',
        message: 'No visit history for this customer',
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        final visitProvider = context.read<VisitProvider>();
        _visits = await visitProvider.getCustomerVisits(widget.customerId);
        setState(() {});
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _visits.length,
        itemBuilder: (context, index) {
          final visit = _visits[index];
          return _buildVisitCard(visit);
        },
      ),
    );
  }

  Widget _buildVisitCard(VisitModel visit) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('dd MMM yyyy, hh:mm a').format(visit.visitDate),
                  style: GoogleFonts.poppins(
                    color: BarberTheme.accentColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Rs ${NumberFormat('#,##0').format(visit.totalAmount)}',
                  style: GoogleFonts.poppins(
                    color: BarberTheme.accentColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: visit.services
                  .map(
                    (service) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: BarberTheme.accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        service,
                        style: GoogleFonts.poppins(
                          color: BarberTheme.accentColor,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            if (visit.workerName != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.person_outline,
                    color: BarberTheme.textSecondary,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    visit.workerName!,
                    style: GoogleFonts.poppins(
                      color: BarberTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
            if (visit.notes != null && visit.notes!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                visit.notes!,
                style: GoogleFonts.poppins(
                  color: BarberTheme.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBillsTab() {
    return FutureBuilder<List<BillModel>>(
      future: context.read<BillProvider>().getCustomerBills(widget.customerId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingWidget(message: 'Loading bills...');
        }

        final bills = snapshot.data ?? [];

        if (bills.isEmpty) {
          return _buildEmptyState(
            icon: Icons.receipt_long_rounded,
            title: 'No Bills',
            message: 'No bills for this customer yet',
            actionLabel: 'Create Bill',
            onAction: () => _createBill(),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: bills.length,
          itemBuilder: (context, index) {
            return BillCard(
              bill: bills[index],
              compact: true,
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/billing/detail',
                  arguments: {'billId': bills[index].id},
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildUdhaarTab() {
    return FutureBuilder<List<UdhaarModel>>(
      future: context.read<UdhaarProvider>().getCustomerUdhaar(
        widget.customerId,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingWidget(message: 'Loading udhaar...');
        }

        final udhaars = snapshot.data ?? [];

        if (udhaars.isEmpty) {
          return _buildEmptyState(
            icon: Icons.book_rounded,
            title: 'No Udhaar',
            message: 'No pending payments for this customer',
            actionLabel: 'Add Udhaar',
            onAction: () => _addUdhaar(),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: udhaars.length,
          itemBuilder: (context, index) {
            return UdhaarCard(
              udhaar: udhaars[index],
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/udhaar/detail',
                  arguments: {'udhaarId': udhaars[index].id},
                );
              },
            );
          },
        );
      },
    );
  }

  // Inline Empty State Widget (to avoid missing dependency)
  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: BarberTheme.cardColor,
              ),
              child: Icon(icon, color: BarberTheme.textSecondary, size: 40),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.poppins(
                color: BarberTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: BarberTheme.textSecondary,
                fontSize: 14,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: BarberTheme.accentColor,
                  foregroundColor: BarberTheme.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(actionLabel),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Inline AddEditCustomerDialog (to avoid missing dependency)
  void _showEditDialog() {
    final customer = _customer!;
    final nameController = TextEditingController(text: customer.name);
    final phoneController = TextEditingController(text: customer.phone);
    final notesController = TextEditingController(text: customer.notes ?? '');
    final favHairstyleController = TextEditingController(
      text: customer.favoriteHairstyle ?? '',
    );
    final allergyController = TextEditingController(
      text: customer.allergyNotes ?? '',
    );
    bool isRegular = customer.isRegular;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: BarberTheme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Edit Customer',
          style: GoogleFonts.poppins(color: BarberTheme.textPrimary),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                style: GoogleFonts.poppins(),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                style: GoogleFonts.poppins(),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  prefixIcon: Icon(Icons.note_outlined),
                ),
                style: GoogleFonts.poppins(),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: favHairstyleController,
                decoration: const InputDecoration(
                  labelText: 'Favorite Hairstyle',
                  prefixIcon: Icon(Icons.cut_outlined),
                ),
                style: GoogleFonts.poppins(),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: allergyController,
                decoration: const InputDecoration(
                  labelText: 'Allergy Notes',
                  prefixIcon: Icon(Icons.warning_amber_rounded),
                ),
                style: GoogleFonts.poppins(),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Checkbox(
                    value: isRegular,
                    onChanged: (val) {
                      isRegular = val ?? false;
                      (context as Element).markNeedsBuild();
                    },
                    activeColor: BarberTheme.accentColor,
                  ),
                  Text(
                    'Regular Customer',
                    style: GoogleFonts.poppins(color: BarberTheme.textPrimary),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: BarberTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final updatedCustomer = CustomerModel(
                id: customer.id,
                name: nameController.text.trim(),
                phone: phoneController.text.trim(),
                notes: notesController.text.trim().isEmpty
                    ? null
                    : notesController.text.trim(),
                isRegular: isRegular,
                totalSpent: customer.totalSpent,
                visitCount: customer.visitCount,
                favoriteHairstyle: favHairstyleController.text.trim().isEmpty
                    ? null
                    : favHairstyleController.text.trim(),
                allergyNotes: allergyController.text.trim().isEmpty
                    ? null
                    : allergyController.text.trim(),
                preferredWorker: customer.preferredWorker,
                lastVisitDate: customer.lastVisitDate,
                createdAt: customer.createdAt,
                updatedAt: DateTime.now(),
              );
              await context.read<CustomerProvider>().updateCustomer(
                updatedCustomer,
              );
              if (context.mounted) {
                Navigator.pop(context);
                _loadData();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Customer updated'),
                    backgroundColor: BarberTheme.successColor,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: BarberTheme.accentColor,
              foregroundColor: BarberTheme.primaryColor,
            ),
            child: Text(
              'Save',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _makeCall() async {
    final cleanPhone = _customer!.phone.replaceAll(RegExp(r'\D'), '');
    final Uri launchUri = Uri(scheme: 'tel', path: cleanPhone);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  Future<void> _sendWhatsApp() async {
    final cleanPhone = _customer!.phone.replaceAll(RegExp(r'\D'), '');
    final Uri launchUri = Uri.parse('https://wa.me/$cleanPhone');
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri, mode: LaunchMode.externalApplication);
    }
  }

  void _createBill() {
    Navigator.pushNamed(context, '/billing');
  }

  void _addUdhaar() {
    Navigator.pushNamed(context, '/udhaar');
  }

  Future<void> _deleteCustomer() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: BarberTheme.cardColor,
        title: Text(
          'Delete Customer',
          style: GoogleFonts.poppins(color: BarberTheme.dangerColor),
        ),
        content: Text(
          'Are you sure you want to delete "${_customer!.name}"? This action cannot be undone and will delete all related data.',
          style: GoogleFonts.poppins(color: BarberTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: BarberTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: BarberTheme.dangerColor,
            ),
            child: Text(
              'Delete',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await context.read<CustomerProvider>().deleteCustomer(
        _customer!.id!,
      );
      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Customer deleted'),
            backgroundColor: BarberTheme.dangerColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }
}
