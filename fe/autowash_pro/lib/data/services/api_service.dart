import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:autowash_pro/core/constants/api_constants.dart';

class ApiService {
  String? _token;

  void setToken(String token) {
    _token = token;
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  // ==================== AUTH ====================
  Future<Map<String, dynamic>> register(String fullName, String email, String password, String phone) async {
    final response = await http.post(
      Uri.parse(ApiConstants.register),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'fullName': fullName,
        'email': email,
        'password': password,
        'phone': phone,
      }),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse(ApiConstants.login),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
    return _handleResponse(response);
  }

  // ==================== SERVICES ====================
  Future<Map<String, dynamic>> getServices() async {
    final response = await http.get(
      Uri.parse(ApiConstants.services),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  // ==================== BOOKINGS ====================
  Future<Map<String, dynamic>> getAvailableSlots(DateTime date, String serviceId) async {
    final dateStr = date.toIso8601String().split('T')[0];
    final response = await http.get(
      Uri.parse('${ApiConstants.availableSlots}?date=$dateStr&serviceId=$serviceId'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> getBookingSummary(String serviceId, String vehicleId, DateTime bookingDate, String timeSlotId, {String? voucherId}) async {
    final response = await http.post(
      Uri.parse(ApiConstants.bookingSummary),
      headers: _headers,
      body: jsonEncode({
        'serviceId': serviceId,
        'vehicleId': vehicleId,
        'bookingDate': bookingDate.toIso8601String(),
        'timeSlotId': timeSlotId,
        'voucherId': ?voucherId,
      }),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> createBooking(String serviceId, String vehicleId, DateTime bookingDate, String timeSlotId, {String? voucherId}) async {
    final response = await http.post(
      Uri.parse(ApiConstants.createBooking),
      headers: _headers,
      body: jsonEncode({
        'serviceId': serviceId,
        'vehicleId': vehicleId,
        'bookingDate': bookingDate.toIso8601String(),
        'timeSlotId': timeSlotId,
        'voucherId': ?voucherId,
      }),
    );
    return _handleResponse(response);
  }

    Future<Map<String, dynamic>> getMyBookings() async {
    final response = await http.get(
      Uri.parse(ApiConstants.myBookings),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> getTodayBookings() async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/bookings/today'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> updateStaffBookingStatus(String id, int newStatus) async {
    final response = await http.put(
      Uri.parse('${ApiConstants.baseUrl}/bookings/$id/status'),
      headers: _headers,
      body: jsonEncode(newStatus),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> claimBooking(String id) async {
    final response = await http.put(
      Uri.parse('${ApiConstants.baseUrl}/bookings/$id/claim'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> updateChecklist(String id, Map<String, dynamic> checklist) async {
    final response = await http.put(
      Uri.parse('${ApiConstants.baseUrl}/bookings/$id/checklist'),
      headers: _headers,
      body: jsonEncode(jsonEncode(checklist)), // backend expects a string body which is JSON itself
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> completeBooking(String id, String imageUrl) async {
    final response = await http.put(
      Uri.parse('${ApiConstants.baseUrl}/bookings/$id/complete'),
      headers: _headers,
      body: jsonEncode(imageUrl),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> getStaffStats() async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/bookings/staff-stats'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> cancelBooking(String bookingId) async {
    final response = await http.put(
      Uri.parse('${ApiConstants.createBooking}/$bookingId/cancel'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  // ==================== USER ====================
  Future<Map<String, dynamic>> getUserTier() async {
    final response = await http.get(
      Uri.parse(ApiConstants.userTier),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  // ==================== VEHICLES ====================
  Future<Map<String, dynamic>> getVehicles() async {
    final response = await http.get(
      Uri.parse(ApiConstants.vehicles),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> addVehicle(String licensePlate, int vehicleType, {String? name, String? color, String? imageUrl}) async {
    final response = await http.post(
      Uri.parse(ApiConstants.vehicles),
      headers: _headers,
      body: jsonEncode({
        'licensePlate': licensePlate,
        'vehicleType': vehicleType,
        'name': ?name,
        'color': ?color,
        'imageUrl': ?imageUrl,
      }),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> deleteVehicle(String vehicleId) async {
    final response = await http.delete(
      Uri.parse('${ApiConstants.vehicles}/$vehicleId'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  // ==================== REWARDS & LOYALTY ====================
  Future<Map<String, dynamic>> getLoyaltyHome() async {
    final response = await http.get(
      Uri.parse(ApiConstants.loyaltyHome),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> getRewards() async {
    final response = await http.get(
      Uri.parse(ApiConstants.rewards),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> redeemReward(String rewardId) async {
    final response = await http.post(
      Uri.parse(ApiConstants.redeemReward),
      headers: _headers,
      body: jsonEncode({'rewardId': rewardId}),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> getVouchers() async {
    final response = await http.get(
      Uri.parse(ApiConstants.vouchers),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  // ==================== ADMIN ====================
  Future<Map<String, dynamic>> getAdminStats() async {
    final response = await http.get(
      Uri.parse(ApiConstants.adminStats),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> getAdminBookings() async {
    final response = await http.get(
      Uri.parse(ApiConstants.adminBookings),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> updateBookingStatus(String bookingId, int status) async {
    final response = await http.put(
      Uri.parse('${ApiConstants.adminBookings}/$bookingId/status'),
      headers: _headers,
      body: jsonEncode({'status': status}),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> getAdminUsers() async {
    final response = await http.get(
      Uri.parse(ApiConstants.adminUsers),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  // ==================== ADMIN SERVICES ====================
  Future<Map<String, dynamic>> createService(String name, String description, double price, int durationMinutes, String imageUrl) async {
    final response = await http.post(
      Uri.parse(ApiConstants.services),
      headers: _headers,
      body: jsonEncode({
        'name': name,
        'description': description,
        'price': price,
        'durationMinutes': durationMinutes,
        'imageUrl': imageUrl,
      }),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> updateService(String id, String name, String description, double price, int durationMinutes, String imageUrl, bool isActive) async {
    final response = await http.put(
      Uri.parse('${ApiConstants.services}/$id'),
      headers: _headers,
      body: jsonEncode({
        'name': name,
        'description': description,
        'price': price,
        'durationMinutes': durationMinutes,
        'imageUrl': imageUrl,
        'isActive': isActive,
      }),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> deleteService(String id) async {
    final response = await http.delete(
      Uri.parse('${ApiConstants.services}/$id'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  // ==================== ADMIN TIMESLOTS ====================
  Future<Map<String, dynamic>> getAdminTimeSlots() async {
    final response = await http.get(
      Uri.parse(ApiConstants.adminTimeSlots),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> createTimeSlot(String dateIso, String startTime, String endTime, int maxCapacity) async {
    final response = await http.post(
      Uri.parse(ApiConstants.adminTimeSlots),
      headers: _headers,
      body: jsonEncode({
        'date': dateIso,
        'startTime': startTime,
        'endTime': endTime,
        'maxCapacity': maxCapacity,
      }),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> updateTimeSlot(String id, String dateIso, String startTime, String endTime, int maxCapacity) async {
    final response = await http.put(
      Uri.parse('${ApiConstants.adminTimeSlots}/$id'),
      headers: _headers,
      body: jsonEncode({
        'date': dateIso,
        'startTime': startTime,
        'endTime': endTime,
        'maxCapacity': maxCapacity,
      }),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> deleteTimeSlot(String id) async {
    final response = await http.delete(
      Uri.parse('${ApiConstants.adminTimeSlots}/$id'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  // ==================== ADMIN REWARDS ====================
  Future<Map<String, dynamic>> getAdminRewards() async {
    final response = await http.get(
      Uri.parse(ApiConstants.adminRewards),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> createReward(String name, String description, int type, int pointsCost, double discountValue, String imageUrl) async {
    final response = await http.post(
      Uri.parse(ApiConstants.adminRewards),
      headers: _headers,
      body: jsonEncode({
        'name': name,
        'description': description,
        'type': type,
        'pointsCost': pointsCost,
        'discountValue': discountValue,
        'imageUrl': imageUrl,
      }),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> updateReward(String id, String name, String description, int type, int pointsCost, double discountValue, String imageUrl, bool isActive) async {
    final response = await http.put(
      Uri.parse('${ApiConstants.adminRewards}/$id'),
      headers: _headers,
      body: jsonEncode({
        'name': name,
        'description': description,
        'type': type,
        'pointsCost': pointsCost,
        'discountValue': discountValue,
        'imageUrl': imageUrl,
        'isActive': isActive,
      }),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> deleteReward(String id) async {
    final response = await http.delete(
      Uri.parse('${ApiConstants.adminRewards}/$id'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  // ==================== ADMIN STAFF ====================
  Future<Map<String, dynamic>> getStaffList() async {
    final response = await http.get(
      Uri.parse(ApiConstants.adminStaff),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> assignStaffToBooking(String bookingId, String staffId) async {
    final response = await http.put(
      Uri.parse('${ApiConstants.adminBookings}/$bookingId/assign-staff'),
      headers: _headers,
      body: jsonEncode({'staffId': staffId}),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> createStaffAccount(String fullName, String email, String password, String phone) async {
    final response = await http.post(
      Uri.parse(ApiConstants.adminStaff),
      headers: _headers,
      body: jsonEncode({
        'fullName': fullName,
        'email': email,
        'password': password,
        'phone': phone,
      }),
    );
    return _handleResponse(response);
  }

  // ==================== CHEMICALS ====================
  Future<Map<String, dynamic>> getChemicals() async {
    final response = await http.get(
      Uri.parse(ApiConstants.adminChemicals),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> createChemical(String name, String unit, double currentStock, double minimumStock) async {
    final response = await http.post(
      Uri.parse(ApiConstants.adminChemicals),
      headers: _headers,
      body: jsonEncode({
        'name': name,
        'unit': unit,
        'currentStock': currentStock,
        'minimumStock': minimumStock,
      }),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> updateChemical(String id, String name, String unit, double minimumStock) async {
    final response = await http.put(
      Uri.parse('${ApiConstants.adminChemicals}/$id'),
      headers: _headers,
      body: jsonEncode({
        'name': name,
        'unit': unit,
        'minimumStock': minimumStock,
      }),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> restockChemical(String id, double amount, String? reason) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.adminChemicals}/$id/restock'),
      headers: _headers,
      body: jsonEncode({
        'amount': amount,
        'reason': reason,
      }),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> getChemicalLogs(String id) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.adminChemicals}/$id/logs'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> getLowStockChemicals() async {
    final response = await http.get(
      Uri.parse('${ApiConstants.adminChemicals}/low-stock'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  // ==================== SERVICE CHEMICALS ====================
  Future<Map<String, dynamic>> getServiceChemicals(String serviceId) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/admin/services/$serviceId/chemicals'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> addServiceChemical(String serviceId, String chemicalId, double quantityPerWash) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/admin/services/$serviceId/chemicals'),
      headers: _headers,
      body: jsonEncode({
        'chemicalId': chemicalId,
        'quantityPerWash': quantityPerWash,
      }),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> updateServiceChemical(String id, double quantityPerWash) async {
    final response = await http.put(
      Uri.parse('${ApiConstants.adminServiceChemicals}/$id'),
      headers: _headers,
      body: jsonEncode({
        'quantityPerWash': quantityPerWash,
      }),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> deleteServiceChemical(String id) async {
    final response = await http.delete(
      Uri.parse('${ApiConstants.adminServiceChemicals}/$id'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  // ==================== REVIEWS ====================
  Future<Map<String, dynamic>> createReview(String bookingId, int rating, String? comment) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.createBooking}/$bookingId/review'),
      headers: _headers,
      body: jsonEncode({
        'rating': rating,
        'comment': comment,
      }),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> getBookingReview(String bookingId) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.createBooking}/$bookingId/review'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> getServiceReviews(String serviceId) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/reviews/service/$serviceId'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> getAdminReviews() async {
    final response = await http.get(
      Uri.parse(ApiConstants.adminReviews),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  // ==================== HELPER ====================
  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.body.isEmpty) {
      throw Exception('Phản hồi từ máy chủ trống (Mã lỗi: ${response.statusCode})');
    }
    
    dynamic body;
    try {
      body = jsonDecode(response.body);
    } catch (e) {
      throw Exception('Định dạng dữ liệu không hợp lệ (Mã lỗi: ${response.statusCode})');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (body is Map<String, dynamic>) {
        return body;
      }
      return {'data': body};
    } else {
      if (body is Map<String, dynamic> && body.containsKey('message')) {
        throw Exception(body['message']);
      }
      throw Exception('Lỗi máy chủ (Mã lỗi: ${response.statusCode})');
    }
  }
}
