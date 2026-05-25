import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme.dart';
import '../../providers/worker_provider.dart';
import '../../providers/visit_provider.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/loading_widget.dart';
import '../../models/worker_model.dart';
import '../../models/visit_model.dart';
import 'workers_list_screen.dart';

class WorkerDetailScreen extends StatefulWidget {
  final int workerId;
  const WorkerDetailScreen({super.key, required this.workerId});
  @override
  State<WorkerDetailScreen> createState() => _WorkerDetailScreenState();
}

class _WorkerDetailScreenState extends State<WorkerDetailScreen> {
  WorkerModel? _worker;
  Map<String, dynamic>? _stats;
  List<VisitModel> _visits = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final workerProvider = context.read<WorkerProvider>();
    final visitProvider = context.read<VisitProvider>();
    _worker = await workerProvider.getWorkerById(widget.workerId);
    if (_worker != null) {
      _stats = await workerProvider.getWorkerStats(widget.workerId);
      _visits = await visitProvider.getWorkerVisits(widget.workerId);
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: _worker?.name ?? 'Worker Details',
        actions: [
          IconButton(
              icon: const Icon(Icons.edit_rounded,
                  color: BarberTheme.accentColor),
              onPressed: () => _editWorker()),
          IconButton(
              icon: const Icon(Icons.delete_outline_rounded,
                  color: BarberTheme.dangerColor),
              onPressed: () => _deleteWorker()),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'Loading...')
          : _worker == null
              ? Center(
                  child: Text('Worker not found',
                      style: GoogleFonts.poppins(
                          color: BarberTheme.textSecondary)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProfileHeader(),
                        const SizedBox(height: 20),
                        _buildStatsCard(),
                        const SizedBox(height: 20),
                        _buildInfoCard(),
                        const SizedBox(height: 20),
                        Text('Recent Visits',
                            style: GoogleFonts.poppins(
                                color: BarberTheme.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 12),
                        if (_visits.isEmpty)
                          Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                  color: BarberTheme.cardColor,
                                  borderRadius: BorderRadius.circular(16)),
                              child: Center(
                                  child: Text('No visits yet',
                                      style: GoogleFonts.poppins(
                                          color: BarberTheme.textSecondary)))),
                        ..._visits
                            .take(5)
                            .map((visit) => _buildVisitCard(visit)),
                        const SizedBox(height: 100),
                      ]),
                ),
    );
  }

  Widget _buildProfileHeader() {
    final worker = _worker!;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [BarberTheme.primaryColor, BarberTheme.surfaceColor]),
          borderRadius: BorderRadius.circular(20)),
      child: Column(children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: BarberTheme.accentColor.withOpacity(0.1),
              border: Border.all(color: BarberTheme.accentColor, width: 3)),
          child: const Icon(Icons.person_rounded,
              color: BarberTheme.accentColor, size: 40),
        ),
        const SizedBox(height: 12),
        Text(worker.name,
            style: GoogleFonts.poppins(
                color: BarberTheme.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold)),
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
                color: BarberTheme.accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12)),
            child: Text(worker.role,
                style: GoogleFonts.poppins(
                    color: BarberTheme.accentColor, fontSize: 13))),
        if (worker.isActive)
          const SizedBox(height: 8)
        else ...[
          const SizedBox(height: 8),
          Icon(Icons.block, color: BarberTheme.dangerColor, size: 20),
          Text('Inactive',
              style: GoogleFonts.poppins(
                  color: BarberTheme.dangerColor, fontSize: 12))
        ],
      ]),
    );
  }

  Widget _buildStatsCard() {
    if (_stats == null) return const SizedBox.shrink();
    final currencyFormat = NumberFormat('#,##0');
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: BarberTheme.cardColor,
          borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Performance',
            style: GoogleFonts.poppins(
                color: BarberTheme.accentColor,
                fontSize: 16,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(
              child: _buildStat('Total Bills', '${_stats!['totalBills'] ?? 0}',
                  Icons.receipt_long_rounded, BarberTheme.accentColor)),
          Expanded(
              child: _buildStat(
                  'Customers',
                  '${_stats!['totalCustomers'] ?? 0}',
                  Icons.people_rounded,
                  BarberTheme.successColor)),
        ]),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(
              child: _buildStat(
                  'Total Earnings',
                  'Rs ${currencyFormat.format(_stats!['totalEarnings'] ?? 0)}',
                  Icons.monetization_on_rounded,
                  BarberTheme.successColor)),
          Expanded(
              child: _buildStat(
                  'This Month',
                  'Rs ${currencyFormat.format(_stats!['monthlyEarnings'] ?? 0)}',
                  Icons.calendar_month_rounded,
                  BarberTheme.accentColor)),
        ]),
        if (_worker!.commissionPercentage > 0) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: BarberTheme.accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10)),
            child: Row(children: [
              const Icon(Icons.percent_rounded, color: BarberTheme.accentColor),
              const SizedBox(width: 8),
              Text('Commission: ${_worker!.commissionPercentage}%',
                  style: GoogleFonts.poppins(
                      color: BarberTheme.accentColor,
                      fontWeight: FontWeight.w600)),
              const Spacer(),
              Text(
                  'Rs ${currencyFormat.format((_stats!['monthlyEarnings'] ?? 0) * _worker!.commissionPercentage / 100)}',
                  style: GoogleFonts.poppins(
                      color: BarberTheme.successColor,
                      fontWeight: FontWeight.bold)),
            ]),
          ),
        ],
      ]),
    );
  }

  Widget _buildStat(String label, String value, IconData icon, Color color) {
    return Column(children: [
      Icon(icon, color: color, size: 20),
      const SizedBox(height: 4),
      Text(value,
          style: GoogleFonts.poppins(
              color: BarberTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold)),
      Text(label,
          style: GoogleFonts.poppins(
              color: BarberTheme.textSecondary, fontSize: 11)),
    ]);
  }

  Widget _buildInfoCard() {
    final worker = _worker!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: BarberTheme.cardColor,
          borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Details',
            style: GoogleFonts.poppins(
                color: BarberTheme.accentColor,
                fontSize: 16,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        if (worker.phone != null) ...[
          _buildInfoRow('Phone', worker.phone!),
          const Divider(color: BarberTheme.primaryColor)
        ],
        _buildInfoRow('Role', worker.role),
        const Divider(color: BarberTheme.primaryColor),
        _buildInfoRow(
            'Join Date', DateFormat('dd MMMM yyyy').format(worker.joinDate)),
        const Divider(color: BarberTheme.primaryColor),
        _buildInfoRow('Status', worker.isActive ? 'Active' : 'Inactive'),
        if (worker.notes != null && worker.notes!.isNotEmpty) ...[
          const Divider(color: BarberTheme.primaryColor),
          _buildInfoRow('Notes', worker.notes!)
        ],
      ]),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
            width: 100,
            child: Text(label,
                style: GoogleFonts.poppins(
                    color: BarberTheme.textSecondary, fontSize: 13))),
        Expanded(
            child: Text(value,
                style: GoogleFonts.poppins(
                    color: BarberTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500))),
      ]),
    );
  }

  Widget _buildVisitCard(VisitModel visit) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(children: [
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(visit.customerName ?? 'Customer #${visit.customerId}',
                    style: GoogleFonts.poppins(
                        color: BarberTheme.textPrimary,
                        fontWeight: FontWeight.w500)),
                Text(DateFormat('dd MMM yyyy').format(visit.visitDate),
                    style: GoogleFonts.poppins(
                        color: BarberTheme.textSecondary, fontSize: 11)),
                Wrap(
                    spacing: 4,
                    children: visit.services
                        .map((s) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                                color: BarberTheme.accentColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4)),
                            child: Text(s,
                                style: GoogleFonts.poppins(
                                    color: BarberTheme.accentColor,
                                    fontSize: 9))))
                        .toList()),
              ])),
          Text('Rs ${NumberFormat('#,##0').format(visit.totalAmount)}',
              style: GoogleFonts.poppins(
                  color: BarberTheme.accentColor, fontWeight: FontWeight.bold)),
        ]),
      ),
    );
  }

  void _editWorker() {
    showDialog(
            context: context,
            builder: (context) => AddEditWorkerDialog(worker: _worker))
        .then((_) => _loadData());
  }

  Future<void> _deleteWorker() async {
    final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
                backgroundColor: BarberTheme.cardColor,
                title: Text('Delete Worker',
                    style: GoogleFonts.poppins(color: BarberTheme.dangerColor)),
                content: Text('Delete ${_worker!.name}?',
                    style:
                        GoogleFonts.poppins(color: BarberTheme.textSecondary)),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text('Cancel',
                          style: GoogleFonts.poppins(
                              color: BarberTheme.textSecondary))),
                  ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: BarberTheme.dangerColor),
                      child: Text('Delete',
                          style: GoogleFonts.poppins(color: Colors.white)))
                ]));
    if (confirm == true) {
      final success =
          await context.read<WorkerProvider>().deleteWorker(_worker!.id!);
      if (success && mounted) Navigator.pop(context);
    }
  }
}

// Import for AddEditWorkerDialog
