import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/app_drawer.dart';

class QrPaymentScreen extends StatefulWidget {
  const QrPaymentScreen({super.key});

  @override
  State<QrPaymentScreen> createState() => _QrPaymentScreenState();
}

class _QrPaymentScreenState extends State<QrPaymentScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _amountController = TextEditingController();
  String _selectedType = 'jazzcash';
  String _generatedQRData = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _generateQR() {
    final amount = _amountController.text;
    final shopData = context.read<AuthProvider>().shopData;
    final shopName = shopData?['shopName'] ?? 'The Barber';

    String qrData = '';
    switch (_selectedType) {
      case 'jazzcash':
        qrData =
            'JazzCash:${shopData?['qrJazzcash'] ?? '03001234567'}:$amount:$shopName';
        break;
      case 'easypaisa':
        qrData =
            'EasyPaisa:${shopData?['qrEasypaisa'] ?? '03001234567'}:$amount:$shopName';
        break;
      case 'bank':
        qrData =
            'Bank:${shopData?['qrBank'] ?? 'PK123456789'}:$amount:$shopName';
        break;
    }

    setState(() => _generatedQRData = qrData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'QR Payments',
        showBackButton: false,
      ),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  BarberTheme.accentColor.withOpacity(0.2),
                  BarberTheme.accentColor.withOpacity(0.05)
                ]),
                borderRadius: BorderRadius.circular(20),
                border:
                    Border.all(color: BarberTheme.accentColor.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: BarberTheme.accentColor.withOpacity(0.1),
                        border: Border.all(
                            color: BarberTheme.accentColor, width: 2)),
                    child: const Icon(Icons.qr_code_2_rounded,
                        color: BarberTheme.accentColor, size: 48),
                  ),
                  const SizedBox(height: 16),
                  Text('Receive Payments via QR',
                      style: GoogleFonts.poppins(
                          color: BarberTheme.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text(
                      'Generate QR code for JazzCash, EasyPaisa, or Bank Transfer',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                          color: BarberTheme.textSecondary, fontSize: 14)),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Payment Type Tabs
            Container(
              decoration: BoxDecoration(
                  color: BarberTheme.cardColor,
                  borderRadius: BorderRadius.circular(16)),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                    color: BarberTheme.accentColor,
                    borderRadius: BorderRadius.circular(12)),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: BarberTheme.primaryColor,
                unselectedLabelColor: BarberTheme.textSecondary,
                labelStyle: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600, fontSize: 14),
                tabs: const [
                  Tab(text: 'JazzCash'),
                  Tab(text: 'EasyPaisa'),
                  Tab(text: 'Bank'),
                ],
                onTap: (index) {
                  setState(() {
                    _selectedType = ['jazzcash', 'easypaisa', 'bank'][index];
                    _generatedQRData = '';
                  });
                },
              ),
            ),

            const SizedBox(height: 24),

            // Amount Input
            Text('Enter Amount',
                style: GoogleFonts.poppins(
                    color: BarberTheme.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: GoogleFonts.poppins(
                  color: BarberTheme.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                prefixText: 'Rs ',
                prefixStyle: GoogleFonts.poppins(
                    color: BarberTheme.accentColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
                hintText: '0',
                hintStyle: GoogleFonts.poppins(
                    color: BarberTheme.textSecondary, fontSize: 24),
                filled: true,
                fillColor: BarberTheme.cardColor,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                        color: BarberTheme.accentColor, width: 2)),
                suffixIcon: IconButton(
                  onPressed: _generateQR,
                  icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: BarberTheme.accentColor,
                          borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.qr_code_2,
                          color: BarberTheme.primaryColor)),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Generate Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _generateQR,
                icon: const Icon(Icons.qr_code_2_rounded),
                label: Text('Generate QR Code',
                    style: GoogleFonts.poppins(
                        fontSize: 16, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                    backgroundColor: BarberTheme.accentColor,
                    foregroundColor: BarberTheme.primaryColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16))),
              ),
            ),

            // Generated QR Code
            if (_generatedQRData.isNotEmpty) ...[
              const SizedBox(height: 32),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                            color: BarberTheme.accentColor.withOpacity(0.3),
                            blurRadius: 20)
                      ]),
                  child: Column(
                    children: [
                      QrImageView(
                        data: _generatedQRData,
                        version: QrVersions.auto,
                        size: 220,
                        backgroundColor: Colors.white,
                        eyeStyle: const QrEyeStyle(
                            eyeShape: QrEyeShape.square,
                            color: BarberTheme.primaryColor),
                        dataModuleStyle: const QrDataModuleStyle(
                            dataModuleShape: QrDataModuleShape.square,
                            color: BarberTheme.primaryColor),
                      ),
                      const SizedBox(height: 16),
                      Text('Scan to Pay',
                          style: GoogleFonts.poppins(
                              color: BarberTheme.primaryColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w600)),
                      Text('Amount: Rs ${_amountController.text}',
                          style: GoogleFonts.poppins(
                              color: BarberTheme.primaryColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      Text(_selectedType.toUpperCase(),
                          style: GoogleFonts.poppins(
                              color: BarberTheme.primaryColor.withOpacity(0.7),
                              fontSize: 12)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    // Share QR logic
                  },
                  icon: const Icon(Icons.share_rounded,
                      color: BarberTheme.accentColor),
                  label: Text('Share QR',
                      style:
                          GoogleFonts.poppins(color: BarberTheme.accentColor)),
                ),
              ),
            ],

            const SizedBox(height: 32),

            // Payment Instructions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: BarberTheme.cardColor,
                  borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('How it works',
                      style: GoogleFonts.poppins(
                          color: BarberTheme.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  _buildStep(1, 'Enter the payment amount'),
                  _buildStep(2, 'Generate the QR code'),
                  _buildStep(3, 'Customer scans the QR with their app'),
                  _buildStep(4, 'Payment is received instantly'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(int number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: BarberTheme.accentColor.withOpacity(0.2)),
            child: Center(
                child: Text('$number',
                    style: GoogleFonts.poppins(
                        color: BarberTheme.accentColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600))),
          ),
          const SizedBox(width: 12),
          Text(text,
              style: GoogleFonts.poppins(
                  color: BarberTheme.textSecondary, fontSize: 14)),
        ],
      ),
    );
  }
}
