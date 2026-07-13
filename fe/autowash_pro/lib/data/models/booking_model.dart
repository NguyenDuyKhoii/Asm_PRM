class BookingModels {
  // Empty class for namespace
}

class AvailableSlotModel {
  final String timeSlotId;
  final String startTime;
  final String endTime;
  final bool isAvailable;
  final int remainingCapacity;

  AvailableSlotModel({
    required this.timeSlotId,
    required this.startTime,
    required this.endTime,
    required this.isAvailable,
    required this.remainingCapacity,
  });

  factory AvailableSlotModel.fromJson(Map<String, dynamic> json) {
    return AvailableSlotModel(
      timeSlotId: json['timeSlotId'] ?? '',
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      isAvailable: json['isAvailable'] ?? false,
      remainingCapacity: json['remainingCapacity'] ?? 0,
    );
  }
}

class BookingSummaryModel {
  final String serviceId;
  final String serviceName;
  final String vehicleId;
  final String vehiclePlate;
  final String vehicleTypeName;
  final DateTime bookingDate;
  final String timeSlotDisplay;
  final double originalPrice;
  final double discountPercentage;
  final double discountAmount;
  final double voucherDiscountAmount;
  final String? voucherCode;
  final double finalPrice;
  final String tierName;
  final String perkApplied;

  BookingSummaryModel({
    required this.serviceId,
    required this.serviceName,
    required this.vehicleId,
    required this.vehiclePlate,
    required this.vehicleTypeName,
    required this.bookingDate,
    required this.timeSlotDisplay,
    required this.originalPrice,
    required this.discountPercentage,
    required this.discountAmount,
    required this.voucherDiscountAmount,
    this.voucherCode,
    required this.finalPrice,
    required this.tierName,
    required this.perkApplied,
  });

  factory BookingSummaryModel.fromJson(Map<String, dynamic> json) {
    return BookingSummaryModel(
      serviceId: json['serviceId'] ?? '',
      serviceName: json['serviceName'] ?? '',
      vehicleId: json['vehicleId'] ?? '',
      vehiclePlate: json['vehiclePlate'] ?? '',
      vehicleTypeName: json['vehicleTypeName'] ?? '',
      bookingDate: DateTime.parse(json['bookingDate']),
      timeSlotDisplay: json['timeSlotDisplay'] ?? '',
      originalPrice: (json['originalPrice'] ?? 0).toDouble(),
      discountPercentage: (json['discountPercentage'] ?? 0).toDouble(),
      discountAmount: (json['discountAmount'] ?? 0).toDouble(),
      voucherDiscountAmount: (json['voucherDiscountAmount'] ?? 0).toDouble(),
      voucherCode: json['voucherCode'],
      finalPrice: (json['finalPrice'] ?? 0).toDouble(),
      tierName: json['tierName'] ?? '',
      perkApplied: json['perkApplied'] ?? '',
    );
  }
}

class BookingConfirmationModel {
  final String bookingId;
  final String qrCode;
  final String status;
  final String serviceName;
  final String vehiclePlate;
  final DateTime bookingDate;
  final String timeSlotDisplay;
  final double totalPrice;

  BookingConfirmationModel({
    required this.bookingId,
    required this.qrCode,
    required this.status,
    required this.serviceName,
    required this.vehiclePlate,
    required this.bookingDate,
    required this.timeSlotDisplay,
    required this.totalPrice,
  });

  factory BookingConfirmationModel.fromJson(Map<String, dynamic> json) {
    return BookingConfirmationModel(
      bookingId: json['bookingId'] ?? '',
      qrCode: json['qrCode'] ?? '',
      status: json['status'] ?? '',
      serviceName: json['serviceName'] ?? '',
      vehiclePlate: json['vehiclePlate'] ?? '',
      bookingDate: DateTime.parse(json['bookingDate']),
      timeSlotDisplay: json['timeSlotDisplay'] ?? '',
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
    );
  }
}

class BookingListModel {
  final String id;
  final String serviceName;
  final String vehiclePlate;
  final DateTime bookingDate;
  final String timeSlotDisplay;
  final double totalPrice;
  final String status;
  final String qrCode;
  final String? staffId;
  String? checklist;
  final String? completionImageUrl;
  final int? rating;
  final String? reviewComment;

  BookingListModel({
    required this.id,
    required this.serviceName,
    required this.vehiclePlate,
    required this.bookingDate,
    required this.timeSlotDisplay,
    required this.totalPrice,
    required this.status,
    required this.qrCode,
    this.staffId,
    this.checklist,
    this.completionImageUrl,
    this.rating,
    this.reviewComment,
  });

  factory BookingListModel.fromJson(Map<String, dynamic> json) {
    return BookingListModel(
      id: json['id'] ?? '',
      serviceName: json['serviceName'] ?? '',
      vehiclePlate: json['vehiclePlate'] ?? '',
      bookingDate: DateTime.parse(json['bookingDate']),
      timeSlotDisplay: json['timeSlotDisplay'] ?? '',
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      status: json['status'] ?? '',
      qrCode: json['qrCode'] ?? '',
      staffId: json['staffId'],
      checklist: json['checklist'],
      completionImageUrl: json['completionImageUrl'],
      rating: json['rating'],
      reviewComment: json['reviewComment'],
    );
  }
}

class VehicleModel {
  final String id;
  final String licensePlate;
  final String vehicleTypeName;
  final int vehicleType;
  final String? name;
  final String? color;
  final String? imageUrl;

  VehicleModel({
    required this.id,
    required this.licensePlate,
    required this.vehicleTypeName,
    required this.vehicleType,
    this.name,
    this.color,
    this.imageUrl,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'] ?? '',
      licensePlate: json['licensePlate'] ?? '',
      vehicleTypeName: json['vehicleTypeName'] ?? '',
      vehicleType: json['vehicleType'] ?? 0,
      name: json['name'],
      color: json['color'],
      imageUrl: json['imageUrl'],
    );
  }
}
