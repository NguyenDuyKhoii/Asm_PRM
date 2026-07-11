class ChemicalModel {
  final String id;
  final String name;
  final String unit;
  final double currentStock;
  final double minimumStock;
  final bool isLowStock;
  final DateTime createdAt;
  final DateTime updatedAt;

  ChemicalModel({
    required this.id,
    required this.name,
    required this.unit,
    required this.currentStock,
    required this.minimumStock,
    required this.isLowStock,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChemicalModel.fromJson(Map<String, dynamic> json) {
    return ChemicalModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      unit: json['unit'] ?? '',
      currentStock: (json['currentStock'] ?? 0).toDouble(),
      minimumStock: (json['minimumStock'] ?? 0).toDouble(),
      isLowStock: json['isLowStock'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class ChemicalLogModel {
  final String id;
  final double changeAmount;
  final String reason;
  final String? bookingId;
  final DateTime createdAt;

  ChemicalLogModel({
    required this.id,
    required this.changeAmount,
    required this.reason,
    this.bookingId,
    required this.createdAt,
  });

  factory ChemicalLogModel.fromJson(Map<String, dynamic> json) {
    return ChemicalLogModel(
      id: json['id'] ?? '',
      changeAmount: (json['changeAmount'] ?? 0).toDouble(),
      reason: json['reason'] ?? '',
      bookingId: json['bookingId'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class ServiceChemicalModel {
  final String id;
  final String serviceId;
  final String chemicalId;
  final String chemicalName;
  final String unit;
  final double quantityPerWash;

  ServiceChemicalModel({
    required this.id,
    required this.serviceId,
    required this.chemicalId,
    required this.chemicalName,
    required this.unit,
    required this.quantityPerWash,
  });

  factory ServiceChemicalModel.fromJson(Map<String, dynamic> json) {
    return ServiceChemicalModel(
      id: json['id'] ?? '',
      serviceId: json['serviceId'] ?? '',
      chemicalId: json['chemicalId'] ?? '',
      chemicalName: json['chemicalName'] ?? '',
      unit: json['unit'] ?? '',
      quantityPerWash: (json['quantityPerWash'] ?? 0).toDouble(),
    );
  }
}
