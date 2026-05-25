import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/visit_provider.dart';
import '../../providers/customer_provider.dart';
import '../../providers/service_provider.dart';
import '../../providers/worker_provider.dart';
import '../../widgets/custom_appbar.dart';
import '../../models/visit_model.dart';
import '../../models/customer_model.dart';
import '../../models/service_model.dart';
import '../../models/worker_model.dart';

class NewVisitScreen extends StatefulWidget {
  const NewVisitScreen({super.key});

  @override
  State<NewVisitScreen> createState() => _NewVisitScreenState();
}

class _NewVisitScreenState extends State<NewVisitScreen> {
  final _currencyFormat = NumberFormat('#,##0');
  final _notesController = TextEditingController();

  CustomerModel? _selectedCustomer;
  WorkerModel? _selectedWorker;
  final List<ServiceModel> _selectedServices = [];
  DateTime _visitDate = DateTime.now();
  String _paymentStatus = 'paid';
  String _paymentMethod = 'Cash';
  bool _isLoading = false;
  bool _isEditing = false;
  int? _editingVisitId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args['visit'] != null) {
        final visit = args['visit'] as VisitModel;
        _loadVisitForEditing(visit);
      }
    });
  }

  void _loadVisitForEditing(VisitModel visit) {
    setState(() {
      _isEditing = true;
      _editingVisitId = visit.id;
      _visitDate = visit.visitDate;
      _paymentStatus = visit.paymentStatus;
      _paymentMethod = visit.paymentMethod ?? 'Cash';
      _notesController.text = visit.notes ?? '';
    });
    // Load customer, worker, and services
    final customerProvider = context.read<CustomerProvider>();
    final workerProvider = context.read<WorkerProvider>();
    final serviceProvider = context.read<ServiceProvider>();

    customerProvider.getCustomerById(visit.customerId).then((customer) {
      if (customer != null) setState(() => _selectedCustomer = customer);
    });

    if (visit.workerId != null) {
      workerProvider.getWorkerById(visit.workerId!).then((worker) {
        if (worker != null) setState(() => _selectedWorker = worker);
      });
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  double get _totalAmount =>
      _selectedServices.fold(0, (sum, service) => sum + service.price);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: _isEditing ? 'Edit Visit' : 'New Visit',
        actions: [
          TextButton.icon(
            onPressed: _isLoading ? null : _saveVisit,
            icon: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: BarberTheme.accentColor))
                : const Icon(Icons.save_rounded,
                    color: BarberTheme.accentColor),
            label: Text('Save',
                style: GoogleFonts.poppins(
                    color: BarberTheme.accentColor,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Customer Selection
            _buildSectionLabel('Customer'),
            const SizedBox(height: 8),
            _buildCustomerSelector(),

            const SizedBox(height: 20),

            // Visit Date
            _buildSectionLabel('Visit Date & Time'),
            const SizedBox(height: 8),
            _buildDateTimePicker(),

            const SizedBox(height: 20),

            // Services Selection
            _buildSectionLabel('Services'),
            const SizedBox(height: 8),
            _buildServicesSelector(),

            const SizedBox(height: 20),

            // Worker Assignment
            _buildSectionLabel('Assigned Barber (Optional)'),
            const SizedBox(height: 8),
            _buildWorkerSelector(),

            const SizedBox(height: 20),

            // Payment Details
            _buildSectionLabel('Payment'),
            const SizedBox(height: 8),
            _buildPaymentSection(),

            const SizedBox(height: 20),

            // Notes
            _buildSectionLabel('Notes (Optional)'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              style: GoogleFonts.poppins(color: BarberTheme.textPrimary),
              decoration: InputDecoration(
                hintText: 'Add any notes about this visit...',
                hintStyle:
                    GoogleFonts.poppins(color: BarberTheme.textSecondary),
                filled: true,
                fillColor: BarberTheme.cardColor,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
            ),

            const SizedBox(height: 24),

            // Total
            if (_selectedServices.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: BarberTheme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: BarberTheme.accentColor.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Amount',
                        style: GoogleFonts.poppins(
                            color: BarberTheme.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w600)),
                    Text(
                      'Rs ${_currencyFormat.format(_totalAmount)}',
                      style: GoogleFonts.poppins(
                          color: BarberTheme.accentColor,
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 40),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: (_selectedCustomer != null &&
                        _selectedServices.isNotEmpty &&
                        !_isLoading)
                    ? _saveVisit
                    : null,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                BarberTheme.primaryColor)))
                    : const Icon(Icons.save_rounded),
                label: Text(_isEditing ? 'Update Visit' : 'Save Visit',
                    style: GoogleFonts.poppins(
                        fontSize: 16, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                    backgroundColor: BarberTheme.accentColor,
                    foregroundColor: BarberTheme.primaryColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16))),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(text,
        style: GoogleFonts.poppins(
            color: BarberTheme.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w500));
  }

  Widget _buildCustomerSelector() {
    return InkWell(
      onTap: _isEditing ? null : _showCustomerPicker,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: BarberTheme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: BarberTheme.accentColor.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: BarberTheme.accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.person_rounded,
                  color: BarberTheme.accentColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _selectedCustomer != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                          Text(_selectedCustomer!.name,
                              style: GoogleFonts.poppins(
                                  color: BarberTheme.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600)),
                          Text(_selectedCustomer!.phone,
                              style: GoogleFonts.poppins(
                                  color: BarberTheme.textSecondary,
                                  fontSize: 13)),
                        ])
                  : Text('Select Customer *',
                      style: GoogleFonts.poppins(
                          color: BarberTheme.textSecondary, fontSize: 16)),
            ),
            if (!_isEditing)
              const Icon(Icons.chevron_right_rounded,
                  color: BarberTheme.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimePicker() {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _visitDate,
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 365)),
          builder: (context, child) => Theme(
              data: ThemeData.dark().copyWith(
                  colorScheme:
                      const ColorScheme.dark(primary: BarberTheme.accentColor)),
              child: child!),
        );
        if (date != null) {
          final time = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(_visitDate),
            builder: (context, child) => Theme(
                data: ThemeData.dark().copyWith(
                    colorScheme: const ColorScheme.dark(
                        primary: BarberTheme.accentColor)),
                child: child!),
          );
          if (time != null) {
            setState(() => _visitDate = DateTime(
                date.year, date.month, date.day, time.hour, time.minute));
          }
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: BarberTheme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border:
                Border.all(color: BarberTheme.accentColor.withOpacity(0.2))),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: BarberTheme.accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.calendar_today_rounded,
                  color: BarberTheme.accentColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(DateFormat('dd MMMM yyyy').format(_visitDate),
                        style: GoogleFonts.poppins(
                            color: BarberTheme.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
                    Text(DateFormat('hh:mm a').format(_visitDate),
                        style: GoogleFonts.poppins(
                            color: BarberTheme.textSecondary, fontSize: 13)),
                  ]),
            ),
            const Icon(Icons.edit_calendar_rounded,
                color: BarberTheme.accentColor),
          ],
        ),
      ),
    );
  }

  Widget _buildServicesSelector() {
    return Column(
      children: [
        if (_selectedServices.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
                color: BarberTheme.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: BarberTheme.accentColor.withOpacity(0.1))),
            child: Column(children: [
              Icon(Icons.content_cut_rounded,
                  color: BarberTheme.textSecondary.withOpacity(0.5), size: 32),
              const SizedBox(height: 8),
              Text('No services selected',
                  style: GoogleFonts.poppins(
                      color: BarberTheme.textSecondary, fontSize: 13)),
            ]),
          )
        else
          ...List.generate(_selectedServices.length, (index) {
            final service = _selectedServices[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: BarberTheme.cardColor,
                  borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: BarberTheme.accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.content_cut,
                        color: BarberTheme.accentColor, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(service.name,
                              style: GoogleFonts.poppins(
                                  color: BarberTheme.textPrimary,
                                  fontWeight: FontWeight.w500)),
                          Text('${service.duration} min',
                              style: GoogleFonts.poppins(
                                  color: BarberTheme.textSecondary,
                                  fontSize: 12)),
                        ]),
                  ),
                  Text('Rs ${_currencyFormat.format(service.price)}',
                      style: GoogleFonts.poppins(
                          color: BarberTheme.accentColor,
                          fontWeight: FontWeight.w600)),
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline,
                        color: BarberTheme.dangerColor, size: 20),
                    onPressed: () =>
                        setState(() => _selectedServices.removeAt(index)),
                  ),
                ],
              ),
            );
          }),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _showServicePicker,
            icon: const Icon(Icons.add_rounded),
            label: Text('Add Service',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
            style: OutlinedButton.styleFrom(
                foregroundColor: BarberTheme.accentColor,
                side: const BorderSide(color: BarberTheme.accentColor),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12))),
          ),
        ),
      ],
    );
  }

  Widget _buildWorkerSelector() {
    return InkWell(
      onTap: _showWorkerPicker,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: BarberTheme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border:
                Border.all(color: BarberTheme.accentColor.withOpacity(0.2))),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: BarberTheme.accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.badge_rounded,
                  color: BarberTheme.accentColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _selectedWorker != null
                  ? Text(_selectedWorker!.name,
                      style: GoogleFonts.poppins(
                          color: BarberTheme.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600))
                  : Text('Select Barber',
                      style: GoogleFonts.poppins(
                          color: BarberTheme.textSecondary, fontSize: 16)),
            ),
            if (_selectedWorker != null)
              IconButton(
                  icon: const Icon(Icons.close,
                      color: BarberTheme.textSecondary, size: 20),
                  onPressed: () => setState(() => _selectedWorker = null)),
            const Icon(Icons.chevron_right_rounded,
                color: BarberTheme.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: BarberTheme.cardColor,
          borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            value: _paymentMethod,
            dropdownColor: BarberTheme.cardColor,
            style: GoogleFonts.poppins(color: BarberTheme.textPrimary),
            decoration: InputDecoration(
                labelText: 'Payment Method',
                labelStyle:
                    GoogleFonts.poppins(color: BarberTheme.textSecondary),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10))),
            items: ['Cash', 'JazzCash', 'EasyPaisa', 'Bank Transfer']
                .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                .toList(),
            onChanged: (v) => setState(() => _paymentMethod = v!),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text('Status:',
                  style: GoogleFonts.poppins(
                      color: BarberTheme.textSecondary, fontSize: 13)),
              const SizedBox(width: 12),
              _buildStatusChip('paid', 'Paid'),
              const SizedBox(width: 8),
              _buildStatusChip('unpaid', 'Unpaid'),
              const SizedBox(width: 8),
              _buildStatusChip('partial', 'Partial'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String value, String label) {
    final isSelected = _paymentStatus == value;
    return GestureDetector(
      onTap: () => setState(() => _paymentStatus = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? BarberTheme.accentColor.withOpacity(0.2)
              : BarberTheme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: isSelected
                  ? BarberTheme.accentColor
                  : BarberTheme.textSecondary.withOpacity(0.3)),
        ),
        child: Text(label,
            style: GoogleFonts.poppins(
                color: isSelected
                    ? BarberTheme.accentColor
                    : BarberTheme.textSecondary,
                fontSize: 12)),
      ),
    );
  }

  Future<void> _showCustomerPicker() async {
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
              Text('Select Customer',
                  style: GoogleFonts.poppins(
                      color: BarberTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w600)),
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
                              color: BarberTheme.accentColor)),
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
    if (result != null) setState(() => _selectedCustomer = result);
  }

  Future<void> _showServicePicker() async {
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
              Text('Add Service',
                  style: GoogleFonts.poppins(
                      color: BarberTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w600)),
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
                              borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.content_cut,
                              color: BarberTheme.accentColor)),
                      title: Text(service.name,
                          style: GoogleFonts.poppins(
                              color: BarberTheme.textPrimary)),
                      subtitle: Text(
                          'Rs ${_currencyFormat.format(service.price)} - ${service.duration}min',
                          style: GoogleFonts.poppins(
                              color: BarberTheme.textSecondary)),
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
    if (result != null) setState(() => _selectedServices.add(result));
  }

  Future<void> _showWorkerPicker() async {
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
              Text('Select Barber',
                  style: GoogleFonts.poppins(
                      color: BarberTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w600)),
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
                              color: BarberTheme.accentColor)),
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
    if (result != null) setState(() => _selectedWorker = result);
  }

  Future<void> _saveVisit() async {
    if (_selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Please select a customer'),
          backgroundColor: BarberTheme.warningColor,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
      return;
    }
    if (_selectedServices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Please add at least one service'),
          backgroundColor: BarberTheme.warningColor,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
      return;
    }

    setState(() => _isLoading = true);

    final visit = VisitModel(
      id: _editingVisitId,
      customerId: _selectedCustomer!.id!,
      customerName: _selectedCustomer!.name,
      customerPhone: _selectedCustomer!.phone,
      workerId: _selectedWorker?.id,
      workerName: _selectedWorker?.name,
      visitDate: _visitDate,
      services: _selectedServices.map((s) => s.name).toList(),
      serviceIds: _selectedServices.map((s) => s.id!).toList(),
      totalAmount: _totalAmount,
      paymentStatus: _paymentStatus,
      paymentMethod: _paymentMethod,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
    );

    final provider = context.read<VisitProvider>();
    final success = _isEditing
        ? await provider.updateVisit(visit)
        : await provider.addVisit(visit);

    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_isEditing ? 'Visit updated' : 'Visit saved'),
          backgroundColor: BarberTheme.successColor,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
    }
  }
}
