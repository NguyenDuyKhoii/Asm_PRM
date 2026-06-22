class RewardModel {
  final String id;
  final String name;
  final String description;
  final String type;
  final int pointsCost;
  final double discountValue;
  final String imageUrl;
  final bool canRedeem;

  RewardModel({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.pointsCost,
    required this.discountValue,
    required this.imageUrl,
    required this.canRedeem,
  });

  factory RewardModel.fromJson(Map<String, dynamic> json) {
    return RewardModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? '',
      pointsCost: json['pointsCost'] ?? 0,
      discountValue: (json['discountValue'] ?? 0).toDouble(),
      imageUrl: json['imageUrl'] ?? '',
      canRedeem: json['canRedeem'] ?? false,
    );
  }
}

class VoucherModel {
  final String id;
  final String code;
  final String rewardName;
  final String rewardType;
  final double discountValue;
  final bool isUsed;
  final DateTime expiryDate;
  final DateTime createdAt;

  VoucherModel({
    required this.id,
    required this.code,
    required this.rewardName,
    required this.rewardType,
    required this.discountValue,
    required this.isUsed,
    required this.expiryDate,
    required this.createdAt,
  });

  factory VoucherModel.fromJson(Map<String, dynamic> json) {
    return VoucherModel(
      id: json['id'] ?? '',
      code: json['code'] ?? '',
      rewardName: json['rewardName'] ?? '',
      rewardType: json['rewardType'] ?? '',
      discountValue: (json['discountValue'] ?? 0).toDouble(),
      isUsed: json['isUsed'] ?? false,
      expiryDate: DateTime.parse(json['expiryDate']),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class RedeemResultModel {
  final String voucherId;
  final String voucherCode;
  final String rewardName;
  final int pointsSpent;
  final int remainingPoints;
  final DateTime expiryDate;

  RedeemResultModel({
    required this.voucherId,
    required this.voucherCode,
    required this.rewardName,
    required this.pointsSpent,
    required this.remainingPoints,
    required this.expiryDate,
  });

  factory RedeemResultModel.fromJson(Map<String, dynamic> json) {
    return RedeemResultModel(
      voucherId: json['voucherId'] ?? '',
      voucherCode: json['voucherCode'] ?? '',
      rewardName: json['rewardName'] ?? '',
      pointsSpent: json['pointsSpent'] ?? 0,
      remainingPoints: json['remainingPoints'] ?? 0,
      expiryDate: DateTime.parse(json['expiryDate']),
    );
  }
}

class LoyaltyHomeModel {
  final String tierName;
  final int tierLevel;
  final int loyaltyPoints;
  final int maxBookingDays;
  final double discountPercentage;
  final int pointsToNextTier;
  final String nextTierName;
  final int expiringPoints;
  final DateTime? pointsExpiryDate;
  final int totalVouchers;

  LoyaltyHomeModel({
    required this.tierName,
    required this.tierLevel,
    required this.loyaltyPoints,
    required this.maxBookingDays,
    required this.discountPercentage,
    required this.pointsToNextTier,
    required this.nextTierName,
    required this.expiringPoints,
    this.pointsExpiryDate,
    required this.totalVouchers,
  });

  factory LoyaltyHomeModel.fromJson(Map<String, dynamic> json) {
    return LoyaltyHomeModel(
      tierName: json['tierName'] ?? 'Member',
      tierLevel: json['tierLevel'] ?? 0,
      loyaltyPoints: json['loyaltyPoints'] ?? 0,
      maxBookingDays: json['maxBookingDays'] ?? 7,
      discountPercentage: (json['discountPercentage'] ?? 0).toDouble(),
      pointsToNextTier: json['pointsToNextTier'] ?? 0,
      nextTierName: json['nextTierName'] ?? '',
      expiringPoints: json['expiringPoints'] ?? 0,
      pointsExpiryDate: json['pointsExpiryDate'] != null
          ? DateTime.parse(json['pointsExpiryDate'])
          : null,
      totalVouchers: json['totalVouchers'] ?? 0,
    );
  }
}
