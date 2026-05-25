import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/app_drawer.dart';
import '../../services/database_service.dart';
import '../../models/shop_model.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _shopNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _workingHoursController = TextEditingController();
  final _qrJazzcashController = TextEditingController();
  final _qrEasypaisaController = TextEditingController();
  final _qrBankController = TextEditingController();

  String _currency = 'PKR';
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);

    final db = DatabaseService.database;
    final maps = await db.query('shop_settings', limit: 1);

    if (maps.isNotEmpty) {
      final shop = ShopModel.fromMap(maps.first);
      _shopNameController.text = shop.shopName ?? '';
      _ownerNameController.text = shop.ownerName ?? '';
      _phoneController.text = shop.phone ?? '';
      _addressController.text = shop.address ?? '';
      _workingHoursController.text = shop.workingHours ?? '';
      _qrJazzcashController.text = shop.qrJazzcash ?? '';
      _qrEasypaisaController.text = shop.qrEasypaisa ?? '';
      _qrBankController.text = shop.qrBank ?? '';
      _currency = shop.currency;
    }

    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _shopNameController.dispose();
    _ownerNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _workingHoursController.dispose();
    _qrJazzcashController.dispose();
    _qrEasypaisaController.dispose();
    _qrBankController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final db = DatabaseService.database;
    final now = DateTime.now().toIso8601String();

    await db.update(
      'shop_settings',
      {
        'shop_name': _shopNameController.text.trim(),
        'owner_name': _ownerNameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'working_hours': _workingHoursController.text.trim(),
        'qr_jazzcash': _qrJazzcashController.text.trim(),
        'qr_easypaisa': _qrEasypaisaController.text.trim(),
        'qr_bank': _qrBankController.text.trim(),
        'currency': _currency,
        'updated_at': now,
      },
      where: 'id = ?',
      whereArgs: [1],
    );

    // Also update Firestore
    final auth = context.read<AuthProvider>();
    await auth.updateShopData({
      'shopName': _shopNameController.text.trim(),
      'ownerName': _ownerNameController.text.trim(),
      'phone': _phoneController.text.trim(),
    });

    setState(() => _isSaving = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: const Text('Settings saved'),
            backgroundColor: BarberTheme.successColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: const CustomAppBar(title: 'Settings', showBackButton: false),
        drawer: const AppDrawer(),
        body: const Center(
            child: CircularProgressIndicator(color: BarberTheme.accentColor)),
      );
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Settings',
        showBackButton: false,
        actions: [
          TextButton.icon(
            onPressed: _isSaving ? null : _saveSettings,
            icon: _isSaving
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
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo Section
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: BarberTheme.accentColor.withOpacity(0.1),
                          border: Border.all(
                              color: BarberTheme.accentColor, width: 3)),
                      child: const Icon(Icons.store_rounded,
                          color: BarberTheme.accentColor, size: 50),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () async {
                          final picker = ImagePicker();
                          await picker.pickImage(source: ImageSource.gallery);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: BarberTheme.accentColor),
                          child: const Icon(Icons.camera_alt_rounded,
                              color: BarberTheme.primaryColor, size: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Shop Information
              _buildSectionHeader('Shop Information'),
              const SizedBox(height: 12),
              _buildTextField(
                  _shopNameController, 'Shop Name', Icons.store_rounded),
              const SizedBox(height: 12),
              _buildTextField(
                  _ownerNameController, 'Owner Name', Icons.person_rounded),
              const SizedBox(height: 12),
              _buildTextField(_phoneController, 'Phone', Icons.phone_rounded,
                  keyboardType: TextInputType.phone),
              const SizedBox(height: 12),
              _buildTextField(
                  _addressController, 'Address', Icons.location_on_rounded,
                  maxLines: 2),
              const SizedBox(height: 12),
              _buildTextField(_workingHoursController, 'Working Hours',
                  Icons.access_time_rounded,
                  hint: 'e.g., 10:00 AM - 10:00 PM'),

              const SizedBox(height: 24),
              _buildSectionHeader('Currency'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                    color: BarberTheme.cardColor,
                    borderRadius: BorderRadius.circular(12)),
                child: DropdownButtonFormField<String>(
                  value: _currency,
                  dropdownColor: BarberTheme.cardColor,
                  style: GoogleFonts.poppins(color: BarberTheme.textPrimary),
                  decoration: const InputDecoration(border: InputBorder.none),
                  items: ['PKR', 'USD', 'GBP', 'EUR', 'AED']
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setState(() => _currency = v!),
                ),
              ),

              const SizedBox(height: 24),
              _buildSectionHeader('QR Payment Settings'),
              const SizedBox(height: 12),
              _buildTextField(_qrJazzcashController, 'JazzCash Account/Number',
                  Icons.account_balance_wallet_rounded),
              const SizedBox(height: 12),
              _buildTextField(
                  _qrEasypaisaController,
                  'EasyPaisa Account/Number',
                  Icons.account_balance_wallet_rounded),
              const SizedBox(height: 12),
              _buildTextField(_qrBankController, 'Bank Account Number',
                  Icons.account_balance_rounded,
                  hint: 'e.g., PK1234567890123456'),

              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveSettings,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  BarberTheme.primaryColor)))
                      : const Icon(Icons.save_rounded),
                  label: Text(_isSaving ? 'Saving...' : 'Save Settings',
                      style: GoogleFonts.poppins(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: BarberTheme.accentColor,
                      foregroundColor: BarberTheme.primaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16))),
                ),
              ),

              const SizedBox(height: 16),

              // App Info
              Center(
                child: Column(
                  children: [
                    Text('The Barber v1.0.0',
                        style: GoogleFonts.poppins(
                            color: BarberTheme.textSecondary, fontSize: 12)),
                    Text('Premium Barber Shop Management',
                        style: GoogleFonts.poppins(
                            color: BarberTheme.textSecondary.withOpacity(0.5),
                            fontSize: 11)),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(title,
        style: GoogleFonts.poppins(
            color: BarberTheme.accentColor,
            fontSize: 16,
            fontWeight: FontWeight.w600));
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon,
      {TextInputType? keyboardType, int maxLines = 1, String? hint}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: GoogleFonts.poppins(color: BarberTheme.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: BarberTheme.accentColor),
        labelStyle: GoogleFonts.poppins(color: BarberTheme.textSecondary),
        hintStyle: GoogleFonts.poppins(
            color: BarberTheme.textSecondary.withOpacity(0.5)),
      ),
    );
  }
}
