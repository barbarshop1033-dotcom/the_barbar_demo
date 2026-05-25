import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/expense_provider.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state_widget.dart';
import '../../models/expense_model.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpenseProvider>().loadExpenses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Expenses', showBackButton: false),
      drawer: const AppDrawer(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddExpenseDialog(context),
        backgroundColor: BarberTheme.accentColor,
        foregroundColor: BarberTheme.primaryColor,
        icon: const Icon(Icons.add_rounded),
        label: Text('Add Expense',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, expenseProvider, _) {
          if (expenseProvider.isLoading) {
            return const LoadingWidget(message: 'Loading expenses...');
          }

          return Column(
            children: [
              // Summary Cards
              _buildSummaryCards(expenseProvider),

              // Filters
              _buildFilters(expenseProvider),

              // Expenses List
              Expanded(
                child: expenseProvider.expenses.isEmpty
                    ? const EmptyStateWidget(
                        icon: Icons.money_off_rounded,
                        title: 'No Expenses',
                        message: 'Track your shop expenses here',
                        actionLabel: 'Add Expense',
                      )
                    : RefreshIndicator(
                        onRefresh: () => expenseProvider.loadExpenses(),
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 100),
                          itemCount: expenseProvider.expenses.length,
                          itemBuilder: (context, index) {
                            final expense = expenseProvider.expenses[index];
                            return _buildExpenseCard(expense, context);
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

  Widget _buildSummaryCards(ExpenseProvider provider) {
    final currencyFormat = NumberFormat('#,##0');

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            BarberTheme.dangerColor.withOpacity(0.15),
            BarberTheme.dangerColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: BarberTheme.dangerColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryItem(
              'Today',
              'Rs ${currencyFormat.format(provider.todayExpenses)}',
              Icons.today_rounded,
            ),
          ),
          Container(
              width: 1,
              height: 40,
              color: BarberTheme.dangerColor.withOpacity(0.3)),
          Expanded(
            child: _buildSummaryItem(
              'This Month',
              'Rs ${currencyFormat.format(provider.monthExpenses)}',
              Icons.calendar_month_rounded,
            ),
          ),
          Container(
              width: 1,
              height: 40,
              color: BarberTheme.dangerColor.withOpacity(0.3)),
          Expanded(
            child: _buildSummaryItem(
              'Total',
              'Rs ${currencyFormat.format(provider.totalExpenses)}',
              Icons.account_balance_wallet_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: BarberTheme.dangerColor, size: 20),
        const SizedBox(height: 4),
        Text(value,
            style: GoogleFonts.poppins(
                color: BarberTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
        Text(label,
            style: GoogleFonts.poppins(
                color: BarberTheme.textSecondary, fontSize: 11)),
      ],
    );
  }

  Widget _buildFilters(ExpenseProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Category Filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: provider.categories.map((category) {
                final isSelected = provider.categoryFilter == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category,
                        style: GoogleFonts.poppins(fontSize: 11)),
                    selected: isSelected,
                    onSelected: (_) => provider.setCategoryFilter(category),
                    selectedColor: BarberTheme.accentColor.withOpacity(0.3),
                    backgroundColor: BarberTheme.cardColor,
                    checkmarkColor: BarberTheme.accentColor,
                    side: BorderSide(
                        color: isSelected
                            ? BarberTheme.accentColor
                            : BarberTheme.cardColor),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          // Period Filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children:
                  ['All', 'Today', 'This Week', 'This Month'].map((period) {
                final isSelected = provider.periodFilter == period;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label:
                        Text(period, style: GoogleFonts.poppins(fontSize: 11)),
                    selected: isSelected,
                    onSelected: (_) => provider.setPeriodFilter(period),
                    selectedColor: BarberTheme.accentColor,
                    backgroundColor: BarberTheme.cardColor,
                    labelStyle: TextStyle(
                        color: isSelected
                            ? BarberTheme.primaryColor
                            : BarberTheme.textSecondary),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseCard(ExpenseModel expense, BuildContext context) {
    final currencyFormat = NumberFormat('#,##0');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _showEditExpenseDialog(context, expense),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Category Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: BarberTheme.dangerColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_getCategoryIcon(expense.category),
                    color: BarberTheme.dangerColor, size: 24),
              ),
              const SizedBox(width: 16),

              // Expense Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.category,
                      style: GoogleFonts.poppins(
                          color: BarberTheme.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600),
                    ),
                    if (expense.description != null &&
                        expense.description!.isNotEmpty)
                      Text(
                        expense.description!,
                        style: GoogleFonts.poppins(
                            color: BarberTheme.textSecondary, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.calendar_today,
                            color: BarberTheme.textSecondary, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('dd MMM yyyy').format(expense.expenseDate),
                          style: GoogleFonts.poppins(
                              color: BarberTheme.textSecondary, fontSize: 11),
                        ),
                        if (expense.paymentMethod != null) ...[
                          const SizedBox(width: 12),
                          Icon(Icons.payment,
                              color: BarberTheme.textSecondary, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            expense.paymentMethod!,
                            style: GoogleFonts.poppins(
                                color: BarberTheme.textSecondary, fontSize: 11),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Amount
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Rs ${currencyFormat.format(expense.amount)}',
                    style: GoogleFonts.poppins(
                        color: BarberTheme.dangerColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert,
                        color: BarberTheme.textSecondary, size: 18),
                    color: BarberTheme.cardColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showEditExpenseDialog(context, expense);
                      } else if (value == 'delete') {
                        _deleteExpense(context, expense);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            const Icon(Icons.edit,
                                color: BarberTheme.accentColor, size: 18),
                            const SizedBox(width: 8),
                            Text('Edit',
                                style: GoogleFonts.poppins(
                                    color: BarberTheme.textPrimary)),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            const Icon(Icons.delete,
                                color: BarberTheme.dangerColor, size: 18),
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
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'rent':
        return Icons.home_rounded;
      case 'utilities':
        return Icons.bolt_rounded;
      case 'products':
        return Icons.inventory_rounded;
      case 'equipment':
        return Icons.build_rounded;
      case 'salary':
        return Icons.payments_rounded;
      case 'marketing':
        return Icons.campaign_rounded;
      case 'maintenance':
        return Icons.handyman_rounded;
      default:
        return Icons.receipt_rounded;
    }
  }

  void _showAddExpenseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddEditExpenseDialog(),
    ).then((_) {
      context.read<ExpenseProvider>().loadExpenses();
    });
  }

  void _showEditExpenseDialog(BuildContext context, ExpenseModel expense) {
    showDialog(
      context: context,
      builder: (context) => AddEditExpenseDialog(expense: expense),
    ).then((_) {
      context.read<ExpenseProvider>().loadExpenses();
    });
  }

  Future<void> _deleteExpense(
      BuildContext context, ExpenseModel expense) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: BarberTheme.cardColor,
        title: Text('Delete Expense',
            style: GoogleFonts.poppins(color: BarberTheme.dangerColor)),
        content: Text(
            'Delete this expense of Rs ${NumberFormat('#,##0').format(expense.amount)}?',
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
            child:
                Text('Delete', style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await context.read<ExpenseProvider>().deleteExpense(expense.id!);
    }
  }
}

class AddEditExpenseDialog extends StatefulWidget {
  final ExpenseModel? expense;
  const AddEditExpenseDialog({super.key, this.expense});
  @override
  State<AddEditExpenseDialog> createState() => _AddEditExpenseDialogState();
}

class _AddEditExpenseDialogState extends State<AddEditExpenseDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCategory = 'Rent';
  String _paymentMethod = 'Cash';
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  bool get _isEditing => widget.expense != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _amountController.text = widget.expense!.amount.toString();
      _descriptionController.text = widget.expense!.description ?? '';
      _selectedCategory = widget.expense!.category;
      _paymentMethod = widget.expense!.paymentMethod ?? 'Cash';
      _selectedDate = widget.expense!.expenseDate;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
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
                          color: BarberTheme.dangerColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.money_off_rounded,
                          color: BarberTheme.dangerColor)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Text(_isEditing ? 'Edit Expense' : 'Add Expense',
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                        items: ExpenseModel.categories
                            .map((cat) =>
                                DropdownMenuItem(value: cat, child: Text(cat)))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _selectedCategory = v!),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        style:
                            GoogleFonts.poppins(color: BarberTheme.textPrimary),
                        decoration: InputDecoration(
                            labelText: 'Amount *',
                            prefixText: 'Rs ',
                            prefixIcon: const Icon(
                                Icons.monetization_on_rounded,
                                color: BarberTheme.accentColor),
                            labelStyle: GoogleFonts.poppins(
                                color: BarberTheme.textSecondary)),
                        validator: (v) => (v == null ||
                                v.isEmpty ||
                                double.tryParse(v) == null)
                            ? 'Valid amount required'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 2,
                        style:
                            GoogleFonts.poppins(color: BarberTheme.textPrimary),
                        decoration: InputDecoration(
                            labelText: 'Description',
                            prefixIcon: const Icon(Icons.description_rounded,
                                color: BarberTheme.accentColor),
                            labelStyle: GoogleFonts.poppins(
                                color: BarberTheme.textSecondary)),
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
                                color: BarberTheme.textSecondary)),
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
                      InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                              builder: (context, child) => Theme(
                                  data: ThemeData.dark().copyWith(
                                      colorScheme: const ColorScheme.dark(
                                          primary: BarberTheme.accentColor)),
                                  child: child!));
                          if (date != null)
                            setState(() => _selectedDate = date);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                              color: BarberTheme.cardColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: BarberTheme.accentColor
                                      .withOpacity(0.2))),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today_rounded,
                                  color: BarberTheme.accentColor),
                              const SizedBox(width: 12),
                              Text(
                                  DateFormat('dd MMMM yyyy')
                                      .format(_selectedDate),
                                  style: GoogleFonts.poppins(
                                      color: BarberTheme.textPrimary)),
                            ],
                          ),
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
                      bottomRight: Radius.circular(24))),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () => _saveExpense(context),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: BarberTheme.dangerColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14))),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white)))
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

  Future<void> _saveExpense(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final expense = ExpenseModel(
      id: widget.expense?.id,
      category: _selectedCategory,
      amount: double.parse(_amountController.text),
      description: _descriptionController.text.isNotEmpty
          ? _descriptionController.text
          : null,
      expenseDate: _selectedDate,
      paymentMethod: _paymentMethod,
    );

    final provider = context.read<ExpenseProvider>();
    final success = _isEditing
        ? await provider.updateExpense(expense)
        : await provider.addExpense(expense);

    setState(() => _isLoading = false);
    if (success && mounted) Navigator.pop(context);
  }
}
