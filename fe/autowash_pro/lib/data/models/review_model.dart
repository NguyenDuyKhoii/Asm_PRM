class ReviewModel {
  final String id;
  final String bookingId;
  final int rating;
  final String? comment;
  final String customerName;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.bookingId,
    required this.rating,
    this.comment,
    required this.customerName,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] ?? '',
      bookingId: json['bookingId'] ?? '',
      rating: json['rating'] ?? 0,
      comment: json['comment'],
      customerName: json['customerName'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class AdminReviewModel {
  final String id;
  final String bookingId;
  final String customerName;
  final String serviceName;
  final int rating;
  final String? comment;
  final DateTime createdAt;

  AdminReviewModel({
    required this.id,
    required this.bookingId,
    required this.customerName,
    required this.serviceName,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  factory AdminReviewModel.fromJson(Map<String, dynamic> json) {
    return AdminReviewModel(
      id: json['id'] ?? '',
      bookingId: json['bookingId'] ?? '',
      customerName: json['customerName'] ?? '',
      serviceName: json['serviceName'] ?? '',
      rating: json['rating'] ?? 0,
      comment: json['comment'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
