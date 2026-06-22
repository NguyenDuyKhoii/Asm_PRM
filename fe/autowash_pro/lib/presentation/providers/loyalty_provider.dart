import 'package:flutter/material.dart';
import 'package:autowash_pro/data/models/reward_model.dart';
import 'package:autowash_pro/data/services/api_service.dart';

class LoyaltyProvider with ChangeNotifier {
  final ApiService _apiService;

  LoyaltyProvider(this._apiService);

  // State
  LoyaltyHomeModel? _loyaltyHome;
  List<RewardModel> _rewards = [];
  List<VoucherModel> _vouchers = [];
  RedeemResultModel? _lastRedeemResult;
  bool _isLoading = false;
  String? _error;

  // Getters
  LoyaltyHomeModel? get loyaltyHome => _loyaltyHome;
  List<RewardModel> get rewards => _rewards;
  List<VoucherModel> get vouchers => _vouchers;
  RedeemResultModel? get lastRedeemResult => _lastRedeemResult;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ==================== LOYALTY HOME ====================
  Future<void> loadLoyaltyHome() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _apiService.getLoyaltyHome();
      _loyaltyHome = LoyaltyHomeModel.fromJson(result['data']);
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    }

    _isLoading = false;
    notifyListeners();
  }

  // ==================== REWARDS ====================
  Future<void> loadRewards() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _apiService.getRewards();
      final List data = result['data'];
      _rewards = data.map((e) => RewardModel.fromJson(e)).toList();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    }

    _isLoading = false;
    notifyListeners();
  }

  // ==================== REDEEM ====================
  Future<bool> redeemReward(String rewardId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _apiService.redeemReward(rewardId);
      _lastRedeemResult = RedeemResultModel.fromJson(result['data']);
      // Refresh data
      await loadLoyaltyHome();
      await loadRewards();
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

  // ==================== VOUCHERS ====================
  Future<void> loadVouchers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _apiService.getVouchers();
      final List data = result['data'];
      _vouchers = data.map((e) => VoucherModel.fromJson(e)).toList();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    }

    _isLoading = false;
    notifyListeners();
  }
}
