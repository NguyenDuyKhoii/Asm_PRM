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

  // ==================== HELPER ====================
  Map<String, dynamic> _handleResponse(http.Response response) {
    final body = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    } else {
      throw Exception(body['message'] ?? 'An error occurred');
    }
  }
}
