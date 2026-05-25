class ShopModel {
  final int? id;
  final String? shopName;
  final String? ownerName;
  final String? phone;
  final String? address;
  final String? email;
  final String currency;
  final String? workingHours;
  final String? qrJazzcash;
  final String? qrEasypaisa;
  final String? qrBank;
  final String? logoPath;
  final DateTime createdAt;
  final DateTime updatedAt;

  ShopModel({
    this.id,
    this.shopName,
    this.ownerName,
    this.phone,
    this.address,
    this.email,
    this.currency = 'PKR',
    this.workingHours,
    this.qrJazzcash,
    this.qrEasypaisa,
    this.qrBank,
    this.logoPath,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'shop_name': shopName,
      'owner_name': ownerName,
      'phone': phone,
      'address': address,
      'email': email,
      'currency': currency,
      'working_hours': workingHours,
      'qr_jazzcash': qrJazzcash,
      'qr_easypaisa': qrEasypaisa,
      'qr_bank': qrBank,
      'logo_path': logoPath,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory ShopModel.fromMap(Map<String, dynamic> map) {
    return ShopModel(
      id: map['id'] as int?,
      shopName: map['shop_name'] as String?,
      ownerName: map['owner_name'] as String?,
      phone: map['phone'] as String?,
      address: map['address'] as String?,
      email: map['email'] as String?,
      currency: map['currency'] as String? ?? 'PKR',
      workingHours: map['working_hours'] as String?,
      qrJazzcash: map['qr_jazzcash'] as String?,
      qrEasypaisa: map['qr_easypaisa'] as String?,
      qrBank: map['qr_bank'] as String?,
      logoPath: map['logo_path'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  ShopModel copyWith({
    int? id,
    String? shopName,
    String? ownerName,
    String? phone,
    String? address,
    String? email,
    String? currency,
    String? workingHours,
    String? qrJazzcash,
    String? qrEasypaisa,
    String? qrBank,
    String? logoPath,
    DateTime? updatedAt,
  }) {
    return ShopModel(
      id: id ?? this.id,
      shopName: shopName ?? this.shopName,
      ownerName: ownerName ?? this.ownerName,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      email: email ?? this.email,
      currency: currency ?? this.currency,
      workingHours: workingHours ?? this.workingHours,
      qrJazzcash: qrJazzcash ?? this.qrJazzcash,
      qrEasypaisa: qrEasypaisa ?? this.qrEasypaisa,
      qrBank: qrBank ?? this.qrBank,
      logoPath: logoPath ?? this.logoPath,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'ShopModel(id: $id, shopName: $shopName, ownerName: $ownerName, currency: $currency)';
  }
}
