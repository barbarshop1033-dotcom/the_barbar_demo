import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme.dart';
import '../../providers/customer_provider.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state_widget.dart';
import 'package:intl/intl.dart';
import '../../widgets/customer_card.dart';
import '../../models/customer_model.dart';
import '../../providers/worker_provider.dart';

class CustomersListScreen extends StatefulWidget {
  const CustomersListScreen({super.key});

  @override
  State<CustomersListScreen> createState() => _CustomersListScreenState();
}

class _CustomersListScreenState extends State<CustomersListScreen> {
  final _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomerProvider>().loadCustomers();
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
        title: _isSearching ? '' : 'Customers',
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
                  context.read<CustomerProvider>().setSearchQuery('');
                }
              });
            },
          ),
          if (!_isSearching)
            PopupMenuButton<String>(
              icon: const Icon(
                Icons.sort_rounded,
                color: BarberTheme.accentColor,
              ),
              color: BarberTheme.cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onSelected: (value) {
                context.read<CustomerProvider>().setSortBy(value);
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'name',
                  child: Row(
                    children: [
                      const Icon(
                        Icons.sort_by_alpha,
                        color: BarberTheme.accentColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Sort by Name',
                        style: GoogleFonts.poppins(
                          color: BarberTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'last_visit',
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        color: BarberTheme.accentColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Sort by Last Visit',
                        style: GoogleFonts.poppins(
                          color: BarberTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'total_spent',
                  child: Row(
                    children: [
                      const Icon(
                        Icons.monetization_on,
                        color: BarberTheme.accentColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Sort by Total Spent',
                        style: GoogleFonts.poppins(
                          color: BarberTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'visits',
                  child: Row(
                    children: [
                      const Icon(
                        Icons.repeat,
                        color: BarberTheme.accentColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Sort by Visits',
                        style: GoogleFonts.poppins(
                          color: BarberTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      drawer: const AppDrawer(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditCustomerDialog(context),
        backgroundColor: BarberTheme.accentColor,
        foregroundColor: BarberTheme.primaryColor,
        icon: const Icon(Icons.person_add_rounded),
        label: Text(
          'Add Customer',
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
                  hintText: 'Search by name or phone...',
                  hintStyle: GoogleFonts.poppins(
                    color: BarberTheme.textSecondary,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: BarberTheme.accentColor,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.clear,
                            color: BarberTheme.textSecondary,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            context.read<CustomerProvider>().setSearchQuery('');
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
                  context.read<CustomerProvider>().setSearchQuery(query);
                  setState(() {});
                },
              ),
            ),

          // Stats Bar
          _buildStatsBar(),

          // Customers List
          Expanded(
            child: Consumer<CustomerProvider>(
              builder: (context, customerProvider, _) {
                if (customerProvider.isLoading) {
                  return const LoadingWidget(message: 'Loading customers...');
                }

                if (customerProvider.customers.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.people_outline_rounded,
                    title: 'No Customers',
                    message: _isSearching
                        ? 'No customers match your search'
                        : 'Add your first customer to get started',
                    actionLabel: _isSearching ? null : 'Add Customer',
                    onAction: _isSearching
                        ? null
                        : () => _showAddEditCustomerDialog(context),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => customerProvider.loadCustomers(),
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 100),
                    itemCount: customerProvider.customers.length,
                    itemBuilder: (context, index) {
                      final customer = customerProvider.customers[index];
                      return CustomerCard(
                        customer: customer,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/customers/detail',
                            arguments: {'customerId': customer.id},
                          ).then((_) {
                            // Refresh list when returning from detail
                            customerProvider.loadCustomers();
                          });
                        },
                        onCall: () => _makePhoneCall(customer.phone),
                        onMessage: () => _sendWhatsApp(customer.phone),
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

  Widget _buildStatsBar() {
    return Consumer<CustomerProvider>(
      builder: (context, provider, _) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                BarberTheme.accentColor.withOpacity(0.15),
                BarberTheme.accentColor.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: BarberTheme.accentColor.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  '${provider.totalCustomers}',
                  'Total',
                  Icons.people_rounded,
                ),
              ),
              Container(
                width: 1,
                height: 30,
                color: BarberTheme.accentColor.withOpacity(0.3),
              ),
              Expanded(
                child: _buildStatItem(
                  '${provider.regularCustomers}',
                  'Regular',
                  Icons.star_rounded,
                ),
              ),
              Container(
                width: 1,
                height: 30,
                color: BarberTheme.accentColor.withOpacity(0.3),
              ),
              Expanded(
                child: _buildStatItem(
                  'Rs ${NumberFormat.compact().format(provider.totalRevenue)}',
                  'Revenue',
                  Icons.monetization_on_rounded,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: BarberTheme.accentColor, size: 18),
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

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Could not make call'),
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

  Future<void> _sendWhatsApp(String phoneNumber) async {
    // Remove any non-digit characters
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'\D'), '');
    final Uri launchUri = Uri.parse('https://wa.me/$cleanPhone');
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Could not open WhatsApp'),
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

  void _showAddEditCustomerDialog(
    BuildContext context, {
    CustomerModel? customer,
  }) {
    showDialog(
      context: context,
      builder: (context) => AddEditCustomerDialog(customer: customer),
    ).then((_) {
      // Refresh list after dialog closes
      context.read<CustomerProvider>().loadCustomers();
    });
  }
}

// Import for NumberFormat

class AddEditCustomerDialog extends StatefulWidget {
  final CustomerModel? customer;

  const AddEditCustomerDialog({super.key, this.customer});

  @override
  State<AddEditCustomerDialog> createState() => _AddEditCustomerDialogState();
}

class _AddEditCustomerDialogState extends State<AddEditCustomerDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();
  final _favoriteHairstyleController = TextEditingController();
  final _allergyNotesController = TextEditingController();

  String? _preferredWorker;
  bool _isRegular = false;
  bool _isLoading = false;

  bool get _isEditing => widget.customer != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nameController.text = widget.customer!.name;
      _phoneController.text = widget.customer!.phone;
      _notesController.text = widget.customer!.notes ?? '';
      _favoriteHairstyleController.text =
          widget.customer!.favoriteHairstyle ?? '';
      _allergyNotesController.text = widget.customer!.allergyNotes ?? '';
      _preferredWorker = widget.customer!.preferredWorker;
      _isRegular = widget.customer!.isRegular;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    _favoriteHairstyleController.dispose();
    _allergyNotesController.dispose();
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
                      color: BarberTheme.accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _isEditing
                          ? Icons.edit_rounded
                          : Icons.person_add_rounded,
                      color: BarberTheme.accentColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _isEditing ? 'Edit Customer' : 'Add Customer',
                      style: GoogleFonts.playfairDisplay(
                        color: BarberTheme.accentColor,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.close,
                      color: BarberTheme.textSecondary,
                    ),
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
                      // Name Field
                      TextFormField(
                        controller: _nameController,
                        style: GoogleFonts.poppins(
                          color: BarberTheme.textPrimary,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Customer Name *',
                          prefixIcon: const Icon(
                            Icons.person_rounded,
                            color: BarberTheme.accentColor,
                          ),
                          labelStyle: GoogleFonts.poppins(
                            color: BarberTheme.textSecondary,
                          ),
                        ),
                        validator: (v) =>
                            v?.isEmpty ?? true ? 'Name is required' : null,
                      ),
                      const SizedBox(height: 16),

                      // Phone Field
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        style: GoogleFonts.poppins(
                          color: BarberTheme.textPrimary,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Phone Number *',
                          prefixIcon: const Icon(
                            Icons.phone_rounded,
                            color: BarberTheme.accentColor,
                          ),
                          labelStyle: GoogleFonts.poppins(
                            color: BarberTheme.textSecondary,
                          ),
                        ),
                        validator: (v) =>
                            v?.isEmpty ?? true ? 'Phone is required' : null,
                      ),
                      const SizedBox(height: 16),

                      // Preferred Worker
                      Consumer<WorkerProvider>(
                        builder: (context, workerProvider, _) {
                          return DropdownButtonFormField<String>(
                            value: _preferredWorker,
                            dropdownColor: BarberTheme.cardColor,
                            style: GoogleFonts.poppins(
                              color: BarberTheme.textPrimary,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Preferred Barber',
                              prefixIcon: const Icon(
                                Icons.badge_rounded,
                                color: BarberTheme.accentColor,
                              ),
                              labelStyle: GoogleFonts.poppins(
                                color: BarberTheme.textSecondary,
                              ),
                            ),
                            items: [
                              const DropdownMenuItem(
                                value: null,
                                child: Text('None'),
                              ),
                              ...workerProvider.activeWorkers.map((worker) {
                                return DropdownMenuItem(
                                  value: worker.name,
                                  child: Text(worker.name),
                                );
                              }),
                            ],
                            onChanged: (v) =>
                                setState(() => _preferredWorker = v),
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      // Favorite Hairstyle
                      TextFormField(
                        controller: _favoriteHairstyleController,
                        style: GoogleFonts.poppins(
                          color: BarberTheme.textPrimary,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Favorite Hairstyle',
                          prefixIcon: const Icon(
                            Icons.content_cut_rounded,
                            color: BarberTheme.accentColor,
                          ),
                          labelStyle: GoogleFonts.poppins(
                            color: BarberTheme.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Allergy Notes
                      TextFormField(
                        controller: _allergyNotesController,
                        maxLines: 2,
                        style: GoogleFonts.poppins(
                          color: BarberTheme.textPrimary,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Allergy/Skin Notes',
                          prefixIcon: const Icon(
                            Icons.warning_amber_rounded,
                            color: BarberTheme.warningColor,
                          ),
                          labelStyle: GoogleFonts.poppins(
                            color: BarberTheme.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Notes
                      TextFormField(
                        controller: _notesController,
                        maxLines: 3,
                        style: GoogleFonts.poppins(
                          color: BarberTheme.textPrimary,
                        ),
                        decoration: InputDecoration(
                          labelText: 'General Notes',
                          prefixIcon: const Icon(
                            Icons.notes_rounded,
                            color: BarberTheme.accentColor,
                          ),
                          labelStyle: GoogleFonts.poppins(
                            color: BarberTheme.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Regular Customer Switch
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: BarberTheme.cardColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: BarberTheme.accentColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.star_rounded,
                                color: BarberTheme.accentColor,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Regular Customer',
                                    style: GoogleFonts.poppins(
                                      color: BarberTheme.textPrimary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    'Mark as a loyal/regular customer',
                                    style: GoogleFonts.poppins(
                                      color: BarberTheme.textSecondary,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: _isRegular,
                              onChanged: (v) => setState(() => _isRegular = v),
                              activeColor: BarberTheme.accentColor,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Buttons
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: BarberTheme.primaryColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  if (_isEditing)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _deleteCustomer(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: BarberTheme.dangerColor,
                          side: const BorderSide(
                            color: BarberTheme.dangerColor,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          'Delete',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  if (_isEditing) const SizedBox(width: 12),
                  Expanded(
                    flex: _isEditing ? 2 : 1,
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () => _saveCustomer(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: BarberTheme.accentColor,
                        foregroundColor: BarberTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  BarberTheme.primaryColor,
                                ),
                              ),
                            )
                          : Text(
                              _isEditing ? 'Update' : 'Save Customer',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveCustomer(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final customerProvider = context.read<CustomerProvider>();

    final customer = CustomerModel(
      id: widget.customer?.id,
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      notes: _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : null,
      favoriteHairstyle: _favoriteHairstyleController.text.trim().isNotEmpty
          ? _favoriteHairstyleController.text.trim()
          : null,
      preferredWorker: _preferredWorker,
      isRegular: _isRegular,
      allergyNotes: _allergyNotesController.text.trim().isNotEmpty
          ? _allergyNotesController.text.trim()
          : null,
    );

    bool success;
    if (_isEditing) {
      success = await customerProvider.updateCustomer(customer);
    } else {
      success = await customerProvider.addCustomer(customer);
    }

    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'Customer updated' : 'Customer added'),
          backgroundColor: BarberTheme.successColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(customerProvider.error ?? 'Failed to save customer'),
          backgroundColor: BarberTheme.dangerColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Future<void> _deleteCustomer(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: BarberTheme.cardColor,
        title: Text(
          'Delete Customer',
          style: GoogleFonts.poppins(color: BarberTheme.dangerColor),
        ),
        content: Text(
          'Are you sure you want to delete "${widget.customer!.name}"? All related data (bills, visits, udhaar) will also be deleted.',
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
      setState(() => _isLoading = true);
      final success = await context.read<CustomerProvider>().deleteCustomer(
        widget.customer!.id!,
      );
      setState(() => _isLoading = false);

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
