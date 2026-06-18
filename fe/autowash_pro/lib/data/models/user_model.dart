class UserModel {
  final String userId;
  final String fullName;
  final String email;
  final String tier;
  final int loyaltyPoints;
  final String token;

  UserModel({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.tier,
    required this.loyaltyPoints,
    required this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, {String? token}) {
    return UserModel(
      userId: json['userId'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      tier: json['tier'] ?? 'Member',
      loyaltyPoints: json['loyaltyPoints'] ?? 0,
      token: token ?? json['token'] ?? '',
    );
  }
}

class UserTierModel {
  final String tierName;
  final int tierLevel;
  final int maxBookingDays;
  final double discountPercentage;
  final int loyaltyPoints;

  UserTierModel({
    required this.tierName,
    required this.tierLevel,
    required this.maxBookingDays,
    required this.discountPercentage,
    required this.loyaltyPoints,
  });

  factory UserTierModel.fromJson(Map<String, dynamic> json) {
    return UserTierModel(
      tierName: json['tierName'] ?? 'Member',
      tierLevel: json['tierLevel'] ?? 0,
      maxBookingDays: json['maxBookingDays'] ?? 7,
      discountPercentage: (json['discountPercentage'] ?? 0).toDouble(),
      loyaltyPoints: json['loyaltyPoints'] ?? 0,
    );
  }
}
