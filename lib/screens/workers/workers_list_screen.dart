import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/worker_provider.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state_widget.dart';
import '../../models/worker_model.dart';

class WorkersListScreen extends StatefulWidget {
  const WorkersListScreen({super.key});

  @override
  State<WorkersListScreen> createState() => _WorkersListScreenState();
}

class _WorkersListScreenState extends State<WorkersListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkerProvider>().loadWorkers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Workers', showBackButton: false),
      drawer: const AppDrawer(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddWorkerDialog(context),
        backgroundColor: BarberTheme.accentColor,
        foregroundColor: BarberTheme.primaryColor,
        icon: const Icon(Icons.person_add_rounded),
        label: Text('Add Worker',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
      ),
      body: Consumer<WorkerProvider>(
        builder: (context, workerProvider, _) {
          if (workerProvider.isLoading) {
            return const LoadingWidget(message: 'Loading workers...');
          }

          if (workerProvider.workers.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.badge_rounded,
              title: 'No Workers',
              message: 'Add barbers and staff members',
              actionLabel: 'Add Worker',
              onAction: () => _showAddWorkerDialog(context),
            );
          }

          return RefreshIndicator(
            onRefresh: () => workerProvider.loadWorkers(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: workerProvider.workers.length,
              itemBuilder: (context, index) {
                final worker = workerProvider.workers[index];
                return _buildWorkerCard(worker, context);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildWorkerCard(WorkerModel worker, BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () async {
          await Navigator.pushNamed(context, '/workers/detail',
              arguments: {'workerId': worker.id});
          if (mounted) context.read<WorkerProvider>().loadWorkers();
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              Stack(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: worker.isActive
                          ? BarberTheme.accentColor.withOpacity(0.1)
                          : BarberTheme.textSecondary.withOpacity(0.1),
                      border: Border.all(
                          color: worker.isActive
                              ? BarberTheme.accentColor
                              : BarberTheme.textSecondary,
                          width: 2),
                    ),
                    child: const Icon(Icons.person_rounded,
                        color: BarberTheme.accentColor, size: 28),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: worker.isActive
                            ? BarberTheme.successColor
                            : BarberTheme.dangerColor,
                        border: Border.all(
                            color: BarberTheme.primaryColor, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(worker.name,
                        style: GoogleFonts.poppins(
                            color: BarberTheme.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                          color: BarberTheme.accentColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6)),
                      child: Text(worker.role,
                          style: GoogleFonts.poppins(
                              color: BarberTheme.accentColor, fontSize: 11)),
                    ),
                    if (worker.phone != null) ...[
                      const SizedBox(height: 4),
                      Text(worker.phone!,
                          style: GoogleFonts.poppins(
                              color: BarberTheme.textSecondary, fontSize: 12)),
                    ],
                    if (worker.commissionPercentage > 0) ...[
                      const SizedBox(height: 4),
                      Text('Commission: ${worker.commissionPercentage}%',
                          style: GoogleFonts.poppins(
                              color: BarberTheme.successColor, fontSize: 11)),
                    ],
                  ],
                ),
              ),

              // Actions
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert,
                    color: BarberTheme.textSecondary),
                color: BarberTheme.cardColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                onSelected: (value) {
                  if (value == 'edit')
                    _showAddWorkerDialog(context, worker: worker);
                  else if (value == 'toggle')
                    context
                        .read<WorkerProvider>()
                        .toggleWorkerStatus(worker.id!, !worker.isActive);
                  else if (value == 'delete') _deleteWorker(context, worker);
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                      value: 'edit',
                      child: Row(children: [
                        const Icon(Icons.edit,
                            color: BarberTheme.accentColor, size: 18),
                        const SizedBox(width: 8),
                        Text('Edit',
                            style: GoogleFonts.poppins(
                                color: BarberTheme.textPrimary))
                      ])),
                  PopupMenuItem(
                      value: 'toggle',
                      child: Row(children: [
                        Icon(worker.isActive ? Icons.block : Icons.check_circle,
                            color: worker.isActive
                                ? BarberTheme.dangerColor
                                : BarberTheme.successColor,
                            size: 18),
                        const SizedBox(width: 8),
                        Text(worker.isActive ? 'Deactivate' : 'Activate',
                            style: GoogleFonts.poppins(
                                color: BarberTheme.textPrimary))
                      ])),
                  PopupMenuItem(
                      value: 'delete',
                      child: Row(children: [
                        const Icon(Icons.delete,
                            color: BarberTheme.dangerColor, size: 18),
                        const SizedBox(width: 8),
                        Text('Delete',
                            style: GoogleFonts.poppins(
                                color: BarberTheme.dangerColor))
                      ])),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddWorkerDialog(BuildContext context, {WorkerModel? worker}) {
    showDialog(
        context: context,
        builder: (context) => AddEditWorkerDialog(worker: worker)).then((_) {
      context.read<WorkerProvider>().loadWorkers();
    });
  }

  Future<void> _deleteWorker(BuildContext context, WorkerModel worker) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: BarberTheme.cardColor,
        title: Text('Delete Worker',
            style: GoogleFonts.poppins(color: BarberTheme.dangerColor)),
        content: Text('Delete ${worker.name}?',
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
      await context.read<WorkerProvider>().deleteWorker(worker.id!);
    }
  }
}

class AddEditWorkerDialog extends StatefulWidget {
  final WorkerModel? worker;
  const AddEditWorkerDialog({super.key, this.worker});
  @override
  State<AddEditWorkerDialog> createState() => _AddEditWorkerDialogState();
}

class _AddEditWorkerDialogState extends State<AddEditWorkerDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();
  String _role = 'Barber';
  double _commission = 0;
  bool _isLoading = false;
  bool get _isEditing => widget.worker != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nameController.text = widget.worker!.name;
      _phoneController.text = widget.worker!.phone ?? '';
      _notesController.text = widget.worker!.notes ?? '';
      _role = widget.worker!.role;
      _commission = widget.worker!.commissionPercentage;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
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
                      child: const Icon(Icons.badge_rounded,
                          color: BarberTheme.accentColor)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Text(_isEditing ? 'Edit Worker' : 'Add Worker',
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
                          style: GoogleFonts.poppins(
                              color: BarberTheme.textPrimary),
                          decoration: InputDecoration(
                              labelText: 'Name *',
                              prefixIcon: const Icon(Icons.person_rounded,
                                  color: BarberTheme.accentColor),
                              labelStyle: GoogleFonts.poppins(
                                  color: BarberTheme.textSecondary)),
                          validator: (v) =>
                              v?.isEmpty ?? true ? 'Required' : null),
                      const SizedBox(height: 16),
                      TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          style: GoogleFonts.poppins(
                              color: BarberTheme.textPrimary),
                          decoration: InputDecoration(
                              labelText: 'Phone',
                              prefixIcon: const Icon(Icons.phone_rounded,
                                  color: BarberTheme.accentColor),
                              labelStyle: GoogleFonts.poppins(
                                  color: BarberTheme.textSecondary))),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                          value: _role,
                          dropdownColor: BarberTheme.cardColor,
                          style: GoogleFonts.poppins(
                              color: BarberTheme.textPrimary),
                          decoration: InputDecoration(
                              labelText: 'Role',
                              prefixIcon: const Icon(Icons.work_rounded,
                                  color: BarberTheme.accentColor),
                              labelStyle: GoogleFonts.poppins(
                                  color: BarberTheme.textSecondary)),
                          items: WorkerModel.roles
                              .map((r) =>
                                  DropdownMenuItem(value: r, child: Text(r)))
                              .toList(),
                          onChanged: (v) => setState(() => _role = v!)),
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: _commission.toString(),
                        keyboardType: TextInputType.number,
                        style:
                            GoogleFonts.poppins(color: BarberTheme.textPrimary),
                        decoration: InputDecoration(
                            labelText: 'Commission (%)',
                            prefixIcon: const Icon(Icons.percent_rounded,
                                color: BarberTheme.accentColor),
                            suffixText: '%',
                            labelStyle: GoogleFonts.poppins(
                                color: BarberTheme.textSecondary)),
                        onChanged: (v) => _commission = double.tryParse(v) ?? 0,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                          controller: _notesController,
                          maxLines: 2,
                          style: GoogleFonts.poppins(
                              color: BarberTheme.textPrimary),
                          decoration: InputDecoration(
                              labelText: 'Notes',
                              prefixIcon: const Icon(Icons.notes_rounded,
                                  color: BarberTheme.accentColor),
                              labelStyle: GoogleFonts.poppins(
                                  color: BarberTheme.textSecondary))),
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
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () => _saveWorker(context),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: BarberTheme.accentColor,
                      foregroundColor: BarberTheme.primaryColor,
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
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveWorker(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final worker = WorkerModel(
        id: widget.worker?.id,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim().isNotEmpty
            ? _phoneController.text.trim()
            : null,
        role: _role,
        commissionPercentage: _commission,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null);
    final provider = context.read<WorkerProvider>();
    final success = _isEditing
        ? await provider.updateWorker(worker)
        : await provider.addWorker(worker);
    setState(() => _isLoading = false);
    if (success && mounted) Navigator.pop(context);
  }
}
