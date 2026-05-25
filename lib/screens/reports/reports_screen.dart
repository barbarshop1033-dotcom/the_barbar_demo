import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/bill_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/expense_provider.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/loading_widget.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Reports',
        showBackButton: false,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: BarberTheme.accentColor,
          labelColor: BarberTheme.accentColor,
          unselectedLabelColor: BarberTheme.textSecondary,
          labelStyle:
              GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'Revenue'),
            Tab(text: 'Expenses'),
            Tab(text: 'Summary'),
          ],
        ),
      ),
      drawer: const AppDrawer(),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRevenueTab(),
          _buildExpensesTab(),
          _buildSummaryTab(),
        ],
      ),
    );
  }

  Widget _buildRevenueTab() {
    return Consumer<BillProvider>(
      builder: (context, billProvider, _) {
        final dailyEarnings = billProvider.getDailyEarnings(7);
        final currencyFormat = NumberFormat('#,##0');

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Revenue Summary Cards
              Row(
                children: [
                  Expanded(
                      child: _buildSummaryCard(
                          'Today',
                          'Rs ${currencyFormat.format(billProvider.todayEarnings)}',
                          Icons.today_rounded,
                          BarberTheme.successColor)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _buildSummaryCard(
                          'Weekly',
                          'Rs ${currencyFormat.format(billProvider.weekEarnings)}',
                          Icons.calendar_view_week_rounded,
                          BarberTheme.accentColor)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                      child: _buildSummaryCard(
                          'Monthly',
                          'Rs ${currencyFormat.format(billProvider.monthEarnings)}',
                          Icons.calendar_month_rounded,
                          BarberTheme.warningColor)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _buildSummaryCard(
                          'Total Bills',
                          '${billProvider.todayBillCount}',
                          Icons.receipt_long_rounded,
                          BarberTheme.dangerColor)),
                ],
              ),

              const SizedBox(height: 24),

              // Daily Revenue Chart
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: BarberTheme.cardColor,
                    borderRadius: BorderRadius.circular(20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Daily Revenue (7 Days)',
                        style: GoogleFonts.poppins(
                            color: BarberTheme.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 250,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: dailyEarnings.values.isNotEmpty
                              ? dailyEarnings.values
                                      .reduce((a, b) => a > b ? a : b) *
                                  1.2
                              : 1000,
                          barGroups: dailyEarnings.entries.map((entry) {
                            return BarChartGroupData(
                              x: dailyEarnings.keys.toList().indexOf(entry.key),
                              barRods: [
                                BarChartRodData(
                                    toY: entry.value,
                                    color: BarberTheme.accentColor,
                                    width: 22,
                                    borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(6),
                                        topRight: Radius.circular(6)))
                              ],
                            );
                          }).toList(),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      final index = value.toInt();
                                      if (index >= 0 &&
                                          index < dailyEarnings.keys.length) {
                                        return Text(
                                            dailyEarnings.keys.elementAt(index),
                                            style: GoogleFonts.poppins(
                                                color:
                                                    BarberTheme.textSecondary,
                                                fontSize: 10));
                                      }
                                      return const SizedBox.shrink();
                                    })),
                            leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 60,
                                    getTitlesWidget: (value, meta) => Text(
                                        'Rs ${currencyFormat.format(value)}',
                                        style: GoogleFonts.poppins(
                                            color: BarberTheme.textSecondary,
                                            fontSize: 10)))),
                            topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                          ),
                          gridData: FlGridData(
                              show: true,
                              horizontalInterval:
                                  dailyEarnings.values.isNotEmpty
                                      ? dailyEarnings.values
                                              .reduce((a, b) => a > b ? a : b) /
                                          4
                                      : 250,
                              drawVerticalLine: false,
                              getDrawingHorizontalLine: (value) => FlLine(
                                  color: BarberTheme.textSecondary
                                      .withOpacity(0.1),
                                  strokeWidth: 1)),
                          borderData: FlBorderData(show: false),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Monthly Revenue Chart
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: BarberTheme.cardColor,
                    borderRadius: BorderRadius.circular(20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Monthly Revenue',
                        style: GoogleFonts.poppins(
                            color: BarberTheme.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 200,
                      child: FutureBuilder<Map<String, double>>(
                        future:
                            context.read<DashboardProvider>().getWeeklyTrend(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return const LoadingWidget();
                          final data = snapshot.data!;
                          return LineChart(
                            LineChartData(
                              lineBarsData: [
                                LineChartBarData(
                                  spots: data.entries
                                      .toList()
                                      .asMap()
                                      .entries
                                      .map((e) => FlSpot(
                                          e.key.toDouble(), e.value.value))
                                      .toList(),
                                  isCurved: true,
                                  color: BarberTheme.accentColor,
                                  barWidth: 3,
                                  dotData: FlDotData(
                                      show: true,
                                      getDotPainter: (spot, percent, bar,
                                              index) =>
                                          FlDotCirclePainter(
                                              radius: 4,
                                              color: BarberTheme.accentColor,
                                              strokeWidth: 2,
                                              strokeColor:
                                                  BarberTheme.primaryColor)),
                                  belowBarData: BarAreaData(
                                      show: true,
                                      color: BarberTheme.accentColor
                                          .withOpacity(0.1)),
                                ),
                              ],
                              titlesData: FlTitlesData(
                                bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (value, meta) {
                                          final index = value.toInt();
                                          if (index >= 0 &&
                                              index < data.keys.length) {
                                            return Text(
                                                data.keys.elementAt(index),
                                                style: GoogleFonts.poppins(
                                                    color: BarberTheme
                                                        .textSecondary,
                                                    fontSize: 10));
                                          }
                                          return const SizedBox.shrink();
                                        })),
                                leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 60,
                                        getTitlesWidget: (value, meta) => Text(
                                            'Rs ${currencyFormat.format(value)}',
                                            style: GoogleFonts.poppins(
                                                color:
                                                    BarberTheme.textSecondary,
                                                fontSize: 10)))),
                              ),
                              gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: false,
                                  getDrawingHorizontalLine: (value) => FlLine(
                                      color: BarberTheme.textSecondary
                                          .withOpacity(0.1),
                                      strokeWidth: 1)),
                              borderData: FlBorderData(show: false),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExpensesTab() {
    return Consumer<ExpenseProvider>(
      builder: (context, expenseProvider, _) {
        final expensesByCategory = expenseProvider.getExpensesByCategory();
        final currencyFormat = NumberFormat('#,##0');
        final colors = [
          BarberTheme.dangerColor,
          BarberTheme.warningColor,
          BarberTheme.accentColor,
          BarberTheme.successColor,
          Colors.orange,
          Colors.purple,
          Colors.teal
        ];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Expenses by Category',
                  style: GoogleFonts.poppins(
                      color: BarberTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: BarberTheme.cardColor,
                    borderRadius: BorderRadius.circular(20)),
                child: SizedBox(
                  height: 250,
                  child: expensesByCategory.isEmpty
                      ? Center(
                          child: Text('No expense data',
                              style: GoogleFonts.poppins(
                                  color: BarberTheme.textSecondary)))
                      : PieChart(
                          PieChartData(
                            sections: expensesByCategory.entries
                                .toList()
                                .asMap()
                                .entries
                                .map((e) {
                              final index = e.key;
                              final entry = e.value;
                              return PieChartSectionData(
                                color: colors[index % colors.length],
                                value: entry.value,
                                title:
                                    '${entry.key}\nRs ${currencyFormat.format(entry.value)}',
                                radius: 90,
                                titleStyle: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600),
                              );
                            }).toList(),
                            sectionsSpace: 2,
                            centerSpaceRadius: 40,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
              Text('Daily Expenses (7 Days)',
                  style: GoogleFonts.poppins(
                      color: BarberTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: BarberTheme.cardColor,
                    borderRadius: BorderRadius.circular(20)),
                child: SizedBox(
                  height: 200,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY:
                          expenseProvider.getExpensesByDay(7).values.isNotEmpty
                              ? expenseProvider
                                      .getExpensesByDay(7)
                                      .values
                                      .reduce((a, b) => a > b ? a : b) *
                                  1.5
                              : 1000,
                      barGroups: expenseProvider
                          .getExpensesByDay(7)
                          .entries
                          .map((entry) {
                        return BarChartGroupData(
                          x: expenseProvider
                              .getExpensesByDay(7)
                              .keys
                              .toList()
                              .indexOf(entry.key),
                          barRods: [
                            BarChartRodData(
                                toY: entry.value,
                                color: BarberTheme.dangerColor,
                                width: 22,
                                borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(6),
                                    topRight: Radius.circular(6)))
                          ],
                        );
                      }).toList(),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  final keys = expenseProvider
                                      .getExpensesByDay(7)
                                      .keys
                                      .toList();
                                  final index = value.toInt();
                                  if (index >= 0 && index < keys.length)
                                    return Text(keys[index],
                                        style: GoogleFonts.poppins(
                                            color: BarberTheme.textSecondary,
                                            fontSize: 10));
                                  return const SizedBox.shrink();
                                })),
                        leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 60,
                                getTitlesWidget: (value, meta) => Text(
                                    'Rs ${currencyFormat.format(value)}',
                                    style: GoogleFonts.poppins(
                                        color: BarberTheme.textSecondary,
                                        fontSize: 10)))),
                      ),
                      gridData: FlGridData(show: true, drawVerticalLine: false),
                      borderData: FlBorderData(show: false),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryTab() {
    return Consumer2<BillProvider, ExpenseProvider>(
      builder: (context, billProvider, expenseProvider, _) {
        final currencyFormat = NumberFormat('#,##0');
        final totalRevenue = billProvider.monthEarnings;
        final totalExpenses = expenseProvider.monthExpenses;
        final profit = totalRevenue - totalExpenses;
        final profitMargin =
            totalRevenue > 0 ? (profit / totalRevenue * 100) : 0.0;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Monthly Summary',
                  style: GoogleFonts.poppins(
                      color: BarberTheme.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              _buildSummaryCard(
                  'Total Revenue',
                  'Rs ${currencyFormat.format(totalRevenue)}',
                  Icons.trending_up_rounded,
                  BarberTheme.successColor),
              const SizedBox(height: 12),
              _buildSummaryCard(
                  'Total Expenses',
                  'Rs ${currencyFormat.format(totalExpenses)}',
                  Icons.trending_down_rounded,
                  BarberTheme.dangerColor),
              const SizedBox(height: 12),
              _buildSummaryCard(
                  'Net Profit',
                  'Rs ${currencyFormat.format(profit)}',
                  Icons.account_balance_rounded,
                  profit >= 0
                      ? BarberTheme.successColor
                      : BarberTheme.dangerColor),
              const SizedBox(height: 12),
              _buildSummaryCard(
                  'Profit Margin',
                  '${profitMargin.toStringAsFixed(1)}%',
                  Icons.pie_chart_rounded,
                  BarberTheme.accentColor),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: BarberTheme.cardColor,
                    borderRadius: BorderRadius.circular(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Quick Stats',
                        style: GoogleFonts.poppins(
                            color: BarberTheme.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    _buildStatRow(
                        'Total Bills', '${billProvider.todayBillCount}'),
                    _buildStatRow('Avg Bill Amount',
                        'Rs ${currencyFormat.format(totalRevenue / (billProvider.todayBillCount > 0 ? billProvider.todayBillCount : 1))}'),
                    _buildStatRow('Revenue vs Expenses',
                        '${totalExpenses > 0 ? currencyFormat.format(totalRevenue / totalExpenses) : 'N/A'}x'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: BarberTheme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3))),
      child: Row(
        children: [
          Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color)),
          const SizedBox(width: 16),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  style: GoogleFonts.poppins(
                      color: BarberTheme.textSecondary, fontSize: 13)),
              Text(value,
                  style: GoogleFonts.poppins(
                      color: color, fontSize: 22, fontWeight: FontWeight.bold)),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label,
            style: GoogleFonts.poppins(
                color: BarberTheme.textSecondary, fontSize: 14)),
        Text(value,
            style: GoogleFonts.poppins(
                color: BarberTheme.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600)),
      ]),
    );
  }
}
