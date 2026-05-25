import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/visit_provider.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state_widget.dart';
import '../../models/visit_model.dart';

class VisitsListScreen extends StatefulWidget {
  const VisitsListScreen({super.key});

  @override
  State<VisitsListScreen> createState() => _VisitsListScreenState();
}

class _VisitsListScreenState extends State<VisitsListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VisitProvider>().loadVisits();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Visits',
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_rounded,
                color: BarberTheme.accentColor),
            onPressed: () => _selectDate(context),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.pushNamed(context, '/visits/new');
          if (mounted) {
            context.read<VisitProvider>().loadVisits();
          }
        },
        backgroundColor: BarberTheme.accentColor,
        foregroundColor: BarberTheme.primaryColor,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          'New Visit',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      body: Consumer<VisitProvider>(
        builder: (context, visitProvider, _) {
          if (visitProvider.isLoading) {
            return const LoadingWidget(message: 'Loading visits...');
          }

          return Column(
            children: [
              // Date Filter
              if (visitProvider.filterDate != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: BarberTheme.primaryColor,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Showing: ${DateFormat('dd MMMM yyyy').format(visitProvider.filterDate!)}',
                          style: GoogleFonts.poppins(
                              color: BarberTheme.accentColor, fontSize: 14),
                        ),
                      ),
                      TextButton(
                        onPressed: () => visitProvider.clearFilter(),
                        child: Text('Clear',
                            style: GoogleFonts.poppins(
                                color: BarberTheme.dangerColor)),
                      ),
                    ],
                  ),
                ),

              // Today's Summary
              _buildTodaySummary(visitProvider),

              // Visits List
              Expanded(
                child: visitProvider.visits.isEmpty
                    ? EmptyStateWidget(
                        icon: Icons.assignment_rounded,
                        title: 'No Visits',
                        message: visitProvider.filterDate != null
                            ? 'No visits on this date'
                            : 'Record customer visits here',
                        actionLabel: 'New Visit',
                        onAction: () async {
                          await Navigator.pushNamed(context, '/visits/new');
                          if (mounted) {
                            context.read<VisitProvider>().loadVisits();
                          }
                        },
                      )
                    : RefreshIndicator(
                        onRefresh: () => visitProvider.loadVisits(),
                        child: ListView.builder(
                          padding: const EdgeInsets.only(top: 8, bottom: 100),
                          itemCount: visitProvider.visits.length,
                          itemBuilder: (context, index) {
                            final visit = visitProvider.visits[index];
                            return _buildVisitCard(visit, context);
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

  Widget _buildTodaySummary(VisitProvider provider) {
    final currencyFormat = NumberFormat('#,##0');
    final todayTotal =
        provider.todayVisits.fold(0.0, (sum, v) => sum + v.totalAmount);

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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BarberTheme.accentColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryItem(
              'Today Visits',
              '${provider.todayVisits.length}',
              Icons.people_rounded,
            ),
          ),
          Container(
              width: 1,
              height: 40,
              color: BarberTheme.accentColor.withOpacity(0.3)),
          Expanded(
            child: _buildSummaryItem(
              'Today Revenue',
              'Rs ${currencyFormat.format(todayTotal)}',
              Icons.monetization_on_rounded,
            ),
          ),
          Container(
              width: 1,
              height: 40,
              color: BarberTheme.accentColor.withOpacity(0.3)),
          Expanded(
            child: _buildSummaryItem(
              'Total Visits',
              '${provider.allVisits.length}',
              Icons.assignment_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: BarberTheme.accentColor, size: 20),
        const SizedBox(height: 4),
        Text(value,
            style: GoogleFonts.poppins(
                color: BarberTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        Text(label,
            style: GoogleFonts.poppins(
                color: BarberTheme.textSecondary, fontSize: 11)),
      ],
    );
  }

  Widget _buildVisitCard(VisitModel visit, BuildContext context) {
    final currencyFormat = NumberFormat('#,##0');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          // Can navigate to visit detail if needed
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  // Customer Info
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: BarberTheme.accentColor.withOpacity(0.1),
                          ),
                          child: const Icon(Icons.person_rounded,
                              color: BarberTheme.accentColor, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                visit.customerName ??
                                    'Customer #${visit.customerId}',
                                style: GoogleFonts.poppins(
                                    color: BarberTheme.textPrimary,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600),
                              ),
                              Text(
                                DateFormat('dd MMM yyyy, hh:mm a')
                                    .format(visit.visitDate),
                                style: GoogleFonts.poppins(
                                    color: BarberTheme.textSecondary,
                                    fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Amount
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Rs ${currencyFormat.format(visit.totalAmount)}',
                        style: GoogleFonts.poppins(
                            color: BarberTheme.accentColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      _buildPaymentStatusBadge(visit.paymentStatus),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Services
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: visit.services
                    .map((service) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: BarberTheme.accentColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            service,
                            style: GoogleFonts.poppins(
                                color: BarberTheme.accentColor, fontSize: 11),
                          ),
                        ))
                    .toList(),
              ),

              // Worker & Payment
              if (visit.workerName != null || visit.paymentMethod != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (visit.workerName != null) ...[
                      const Icon(Icons.person_outline,
                          color: BarberTheme.textSecondary, size: 14),
                      const SizedBox(width: 4),
                      Text(visit.workerName!,
                          style: GoogleFonts.poppins(
                              color: BarberTheme.textSecondary, fontSize: 12)),
                      const SizedBox(width: 16),
                    ],
                    if (visit.paymentMethod != null) ...[
                      const Icon(Icons.payment,
                          color: BarberTheme.textSecondary, size: 14),
                      const SizedBox(width: 4),
                      Text(visit.paymentMethod!,
                          style: GoogleFonts.poppins(
                              color: BarberTheme.textSecondary, fontSize: 12)),
                    ],
                  ],
                ),
              ],

              // Notes
              if (visit.notes != null && visit.notes!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(visit.notes!,
                    style: GoogleFonts.poppins(
                        color: BarberTheme.textSecondary,
                        fontSize: 12,
                        fontStyle: FontStyle.italic)),
              ],

              const SizedBox(height: 8),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _editVisit(context, visit),
                    icon: const Icon(Icons.edit_rounded, size: 16),
                    label:
                        Text('Edit', style: GoogleFonts.poppins(fontSize: 12)),
                    style: TextButton.styleFrom(
                        foregroundColor: BarberTheme.accentColor),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => _deleteVisit(context, visit),
                    icon: const Icon(Icons.delete_rounded, size: 16),
                    label: Text('Delete',
                        style: GoogleFonts.poppins(fontSize: 12)),
                    style: TextButton.styleFrom(
                        foregroundColor: BarberTheme.dangerColor),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'paid':
        color = BarberTheme.successColor;
        break;
      case 'partial':
        color = BarberTheme.warningColor;
        break;
      default:
        color = BarberTheme.dangerColor;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.toUpperCase(),
        style: GoogleFonts.poppins(
            color: color, fontSize: 9, fontWeight: FontWeight.w600),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final visitProvider = context.read<VisitProvider>();
    final date = await showDatePicker(
      context: context,
      initialDate: visitProvider.filterDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(primary: BarberTheme.accentColor),
        ),
        child: child!,
      ),
    );
    if (date != null) {
      visitProvider.setFilterDate(date);
    }
  }

  Future<void> _editVisit(BuildContext context, VisitModel visit) async {
    await Navigator.pushNamed(context, '/visits/new',
        arguments: {'visit': visit});
    if (mounted) {
      context.read<VisitProvider>().loadVisits();
    }
  }

  Future<void> _deleteVisit(BuildContext context, VisitModel visit) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: BarberTheme.cardColor,
        title: Text('Delete Visit',
            style: GoogleFonts.poppins(color: BarberTheme.dangerColor)),
        content: Text('Delete this visit record?',
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
      final success =
          await context.read<VisitProvider>().deleteVisit(visit.id!);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: const Text('Visit deleted'),
              backgroundColor: BarberTheme.dangerColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10))),
        );
      }
    }
  }
}
