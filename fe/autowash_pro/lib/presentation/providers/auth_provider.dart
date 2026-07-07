import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:autowash_pro/data/models/user_model.dart';
import 'package:autowash_pro/data/services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService;
  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  AuthProvider(this._apiService);

  ApiService get apiService => _apiService;
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;
  bool get isAdmin => _user?.role == 'Admin';
  String? get error => _error;

  Future<void> checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userId = prefs.getString('userId');
    final fullName = prefs.getString('fullName');
    final email = prefs.getString('email');
    final tier = prefs.getString('tier');
    final points = prefs.getInt('loyaltyPoints');
    final role = prefs.getString('role');

    if (token != null && userId != null) {
      _user = UserModel(
        userId: userId,
        fullName: fullName ?? '',
        email: email ?? '',
        tier: tier ?? 'Member',
        loyaltyPoints: points ?? 0,
        token: token,
        role: role ?? 'Customer',
      );
      _apiService.setToken(token);
      notifyListeners();
    }
  }

  Future<bool> register(String fullName, String email, String password, String phone) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _apiService.register(fullName, email, password, phone);
      final data = result['data'];
      _user = UserModel.fromJson(data);
      _apiService.setToken(_user!.token);
      await _saveUserData();
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

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _apiService.login(email, password);
      final data = result['data'];
      _user = UserModel.fromJson(data);
      _apiService.setToken(_user!.token);
      await _saveUserData();
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

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _user = null;
    notifyListeners();
  }

  Future<void> _saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', _user!.token);
    await prefs.setString('userId', _user!.userId);
    await prefs.setString('fullName', _user!.fullName);
    await prefs.setString('email', _user!.email);
    await prefs.setString('tier', _user!.tier);
    await prefs.setInt('loyaltyPoints', _user!.loyaltyPoints);
    await prefs.setString('role', _user!.role);
  }
}
