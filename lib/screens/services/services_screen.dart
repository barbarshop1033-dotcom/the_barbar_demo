import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/service_provider.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/service_card.dart';
import '../../models/service_model.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceProvider>().loadServices();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Services', showBackButton: false),
      drawer: const AppDrawer(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddServiceDialog(context),
        backgroundColor: BarberTheme.accentColor,
        foregroundColor: BarberTheme.primaryColor,
        icon: const Icon(Icons.add_rounded),
        label: Text('Add Service',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
      ),
      body: Consumer<ServiceProvider>(
        builder: (context, serviceProvider, _) {
          if (serviceProvider.isLoading) {
            return const LoadingWidget(message: 'Loading services...');
          }

          return Column(
            children: [
              // Category Filter
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildCategoryChip('All', null, serviceProvider),
                      ...serviceProvider.categories.map((cat) =>
                          _buildCategoryChip(cat, cat, serviceProvider)),
                    ],
                  ),
                ),
              ),

              // Services List
              Expanded(
                child: serviceProvider.services.isEmpty
                    ? EmptyStateWidget(
                        icon: Icons.content_cut_rounded,
                        title: 'No Services',
                        message: 'Add services with custom pricing',
                        actionLabel: 'Add Service',
                        onAction: () => _showAddServiceDialog(context),
                      )
                    : RefreshIndicator(
                        onRefresh: () => serviceProvider.loadServices(),
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 100),
                          itemCount: serviceProvider.services.length,
                          itemBuilder: (context, index) {
                            final service = serviceProvider.services[index];
                            return ServiceCard(
                              service: service,
                              onTap: () =>
                                  _showEditServiceDialog(context, service),
                              onEdit: () =>
                                  _showEditServiceDialog(context, service),
                              onToggle: () =>
                                  serviceProvider.toggleServiceStatus(
                                      service.id!, !service.isActive),
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

  Widget _buildCategoryChip(
      String label, String? category, ServiceProvider provider) {
    final isSelected = provider.selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label,
            style: GoogleFonts.poppins(
                fontSize: 12,
                color: isSelected
                    ? BarberTheme.primaryColor
                    : BarberTheme.textSecondary)),
        selected: isSelected,
        onSelected: (_) => provider.setSelectedCategory(category),
        selectedColor: BarberTheme.accentColor,
        backgroundColor: BarberTheme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  void _showAddServiceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddEditServiceDialog(),
    ).then((_) {
      context.read<ServiceProvider>().loadServices();
    });
  }

  void _showEditServiceDialog(BuildContext context, ServiceModel service) {
    showDialog(
      context: context,
      builder: (context) => AddEditServiceDialog(service: service),
    ).then((_) {
      context.read<ServiceProvider>().loadServices();
    });
  }
}

class AddEditServiceDialog extends StatefulWidget {
  final ServiceModel? service;
  const AddEditServiceDialog({super.key, this.service});
  @override
  State<AddEditServiceDialog> createState() => _AddEditServiceDialogState();
}

class _AddEditServiceDialogState extends State<AddEditServiceDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController();
  String _selectedCategory = 'Hair';
  bool _isLoading = false;
  bool get _isEditing => widget.service != null;

  final _categories = ['Hair', 'Beard', 'Skin Care', 'Body', 'Other'];

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nameController.text = widget.service!.name;
      _priceController.text = widget.service!.price.toString();
      _durationController.text = widget.service!.duration.toString();
      _selectedCategory = widget.service!.category ?? 'Hair';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _durationController.dispose();
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
            borderRadius: BorderRadius.circular(24)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: BarberTheme.primaryColor,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24))),
              child: Row(
                children: [
                  Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: BarberTheme.accentColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.content_cut_rounded,
                          color: BarberTheme.accentColor)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Text(_isEditing ? 'Edit Service' : 'Add Service',
                          style: GoogleFonts.playfairDisplay(
                              color: BarberTheme.accentColor,
                              fontSize: 22,
                              fontWeight: FontWeight.bold))),
                  IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close,
                          color: BarberTheme.textSecondary)),
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
                        controller: _nameController,
                        style:
                            GoogleFonts.poppins(color: BarberTheme.textPrimary),
                        decoration: InputDecoration(
                            labelText: 'Service Name *',
                            prefixIcon: const Icon(Icons.content_cut_rounded,
                                color: BarberTheme.accentColor),
                            labelStyle: GoogleFonts.poppins(
                                color: BarberTheme.textSecondary)),
                        validator: (v) =>
                            v?.isEmpty ?? true ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        style:
                            GoogleFonts.poppins(color: BarberTheme.textPrimary),
                        decoration: InputDecoration(
                            labelText: 'Price (Rs) *',
                            prefixIcon: const Icon(
                                Icons.monetization_on_rounded,
                                color: BarberTheme.accentColor),
                            labelStyle: GoogleFonts.poppins(
                                color: BarberTheme.textSecondary)),
                        validator: (v) => (v == null ||
                                v.isEmpty ||
                                double.tryParse(v) == null)
                            ? 'Valid price required'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _durationController,
                        keyboardType: TextInputType.number,
                        style:
                            GoogleFonts.poppins(color: BarberTheme.textPrimary),
                        decoration: InputDecoration(
                            labelText: 'Duration (minutes) *',
                            prefixIcon: const Icon(Icons.timer_rounded,
                                color: BarberTheme.accentColor),
                            labelStyle: GoogleFonts.poppins(
                                color: BarberTheme.textSecondary)),
                        validator: (v) =>
                            (v == null || v.isEmpty || int.tryParse(v) == null)
                                ? 'Valid duration required'
                                : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        dropdownColor: BarberTheme.cardColor,
                        style:
                            GoogleFonts.poppins(color: BarberTheme.textPrimary),
                        decoration: InputDecoration(
                            labelText: 'Category',
                            prefixIcon: const Icon(Icons.category_rounded,
                                color: BarberTheme.accentColor),
                            labelStyle: GoogleFonts.poppins(
                                color: BarberTheme.textSecondary)),
                        items: _categories
                            .map((cat) =>
                                DropdownMenuItem(value: cat, child: Text(cat)))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _selectedCategory = v!),
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
                      bottomRight: Radius.circular(24))),
              child: Row(
                children: [
                  if (_isEditing)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _deleteService(context),
                        style: OutlinedButton.styleFrom(
                            foregroundColor: BarberTheme.dangerColor,
                            side: const BorderSide(
                                color: BarberTheme.dangerColor),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14))),
                        child: Text('Delete',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                  if (_isEditing) const SizedBox(width: 12),
                  Expanded(
                    flex: _isEditing ? 2 : 1,
                    child: ElevatedButton(
                      onPressed:
                          _isLoading ? null : () => _saveService(context),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: BarberTheme.accentColor,
                          foregroundColor: BarberTheme.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14))),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      BarberTheme.primaryColor)))
                          : Text(_isEditing ? 'Update' : 'Save',
                              style: GoogleFonts.poppins(
                                  fontSize: 16, fontWeight: FontWeight.w600)),
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

  Future<void> _saveService(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final service = ServiceModel(
      id: widget.service?.id,
      name: _nameController.text.trim(),
      price: double.parse(_priceController.text),
      duration: int.parse(_durationController.text),
      category: _selectedCategory,
      isCustom: !_isEditing ? true : widget.service!.isCustom,
    );

    final provider = context.read<ServiceProvider>();
    final success = _isEditing
        ? await provider.updateService(service)
        : await provider.addService(service);

    setState(() => _isLoading = false);
    if (success && mounted) Navigator.pop(context);
  }

  Future<void> _deleteService(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: BarberTheme.cardColor,
        title: Text('Delete Service',
            style: GoogleFonts.poppins(color: BarberTheme.dangerColor)),
        content: Text('Delete "${widget.service!.name}"?',
            style: GoogleFonts.poppins(color: BarberTheme.textSecondary)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel',
                  style:
                      GoogleFonts.poppins(color: BarberTheme.textSecondary))),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                  backgroundColor: BarberTheme.dangerColor),
              child: Text('Delete',
                  style: GoogleFonts.poppins(color: Colors.white))),
        ],
      ),
    );
    if (confirm == true) {
      await context.read<ServiceProvider>().deleteService(widget.service!.id!);
      if (mounted) Navigator.pop(context);
    }
  }
}
