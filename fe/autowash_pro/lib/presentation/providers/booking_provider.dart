import 'package:flutter/material.dart';
import 'package:autowash_pro/data/models/service_model.dart';
import 'package:autowash_pro/data/models/booking_model.dart';
import 'package:autowash_pro/data/models/user_model.dart';
import 'package:autowash_pro/data/services/api_service.dart';

class BookingProvider with ChangeNotifier {
  final ApiService _apiService;

  BookingProvider(this._apiService);

  // State
  List<ServiceModel> _services = [];
  List<AvailableSlotModel> _availableSlots = [];
  List<VehicleModel> _vehicles = [];
  List<BookingListModel> _myBookings = [];
  UserTierModel? _userTier;
  BookingSummaryModel? _bookingSummary;
  BookingConfirmationModel? _bookingConfirmation;
  bool _isLoading = false;
  String? _error;

  // Selected state for booking flow
  ServiceModel? _selectedService;
  DateTime? _selectedDate;
  AvailableSlotModel? _selectedSlot;
  VehicleModel? _selectedVehicle;

  // Getters
  List<ServiceModel> get services => _services;
  List<AvailableSlotModel> get availableSlots => _availableSlots;
  List<VehicleModel> get vehicles => _vehicles;
  List<BookingListModel> get myBookings => _myBookings;
  UserTierModel? get userTier => _userTier;
  BookingSummaryModel? get bookingSummary => _bookingSummary;
  BookingConfirmationModel? get bookingConfirmation => _bookingConfirmation;
  bool get isLoading => _isLoading;
  String? get error => _error;
  ServiceModel? get selectedService => _selectedService;
  DateTime? get selectedDate => _selectedDate;
  AvailableSlotModel? get selectedSlot => _selectedSlot;
  VehicleModel? get selectedVehicle => _selectedVehicle;

  // ==================== SERVICES ====================
  Future<void> loadServices() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _apiService.getServices();
      final List data = result['data'];
      _services = data.map((e) => ServiceModel.fromJson(e)).toList();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    }

    _isLoading = false;
    notifyListeners();
  }

  void selectService(ServiceModel service) {
    _selectedService = service;
    notifyListeners();
  }

  // ==================== USER TIER ====================
  Future<void> loadUserTier() async {
    try {
      final result = await _apiService.getUserTier();
      _userTier = UserTierModel.fromJson(result['data']);
      notifyListeners();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    }
  }

  // ==================== AVAILABLE SLOTS ====================
  Future<void> loadAvailableSlots(DateTime date) async {
    if (_selectedService == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _apiService.getAvailableSlots(date, _selectedService!.id);
      final List data = result['data'];
      _availableSlots = data.map((e) => AvailableSlotModel.fromJson(e)).toList();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    }

    _isLoading = false;
    notifyListeners();
  }

  void selectDate(DateTime date) {
    _selectedDate = date;
    _selectedSlot = null;
    notifyListeners();
    loadAvailableSlots(date);
  }

  void selectSlot(AvailableSlotModel slot) {
    _selectedSlot = slot;
    notifyListeners();
  }

  // ==================== VEHICLES ====================
  Future<void> loadVehicles() async {
    try {
      final result = await _apiService.getVehicles();
      final List data = result['data'];
      _vehicles = data.map((e) => VehicleModel.fromJson(e)).toList();
      notifyListeners();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    }
  }

  Future<bool> addVehicle(String licensePlate, int vehicleType, {String? name, String? color, String? imageUrl}) async {
    try {
      await _apiService.addVehicle(licensePlate, vehicleType, name: name, color: color, imageUrl: imageUrl);
      await loadVehicles();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  void selectVehicle(VehicleModel vehicle) {
    _selectedVehicle = vehicle;
    notifyListeners();
  }

  Future<bool> deleteVehicle(String vehicleId) async {
    try {
      await _apiService.deleteVehicle(vehicleId);
      if (_selectedVehicle?.id == vehicleId) {
        _selectedVehicle = null;
      }
      await loadVehicles();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  // ==================== BOOKING SUMMARY ====================
  Future<bool> loadBookingSummary() async {
    if (_selectedService == null || _selectedVehicle == null || _selectedDate == null || _selectedSlot == null) {
      _error = 'Vui lòng chọn đầy đủ thông tin';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _apiService.getBookingSummary(
        _selectedService!.id,
        _selectedVehicle!.id,
        _selectedDate!,
        _selectedSlot!.timeSlotId,
      );
      _bookingSummary = BookingSummaryModel.fromJson(result['data']);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ==================== CREATE BOOKING ====================
  Future<bool> confirmBooking() async {
    if (_selectedService == null || _selectedVehicle == null || _selectedDate == null || _selectedSlot == null) {
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _apiService.createBooking(
        _selectedService!.id,
        _selectedVehicle!.id,
        _selectedDate!,
        _selectedSlot!.timeSlotId,
      );
      _bookingConfirmation = BookingConfirmationModel.fromJson(result['data']);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ==================== MY BOOKINGS ====================
  Future<void> loadMyBookings() async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _apiService.getMyBookings();
      final List data = result['data'];
      _myBookings = data.map((e) => BookingListModel.fromJson(e)).toList();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    }

    _isLoading = false;
    notifyListeners();
  }

  // ==================== RESET ====================
  void resetBookingFlow() {
    _selectedService = null;
    _selectedDate = null;
    _selectedSlot = null;
    _selectedVehicle = null;
    _bookingSummary = null;
    _bookingConfirmation = null;
    _availableSlots = [];
    _error = null;
    notifyListeners();
  }
}
