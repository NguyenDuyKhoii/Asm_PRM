import 'package:flutter/foundation.dart';

class ApiConstants {
  static String get baseUrl => kIsWeb ? 'http://localhost:5048/api' : 'http://10.0.2.2:5048/api';
  
  // Auth
  static String get register => '$baseUrl/auth/register';
  static String get login => '$baseUrl/auth/login';
  
  // Services
  static String get services => '$baseUrl/services';
  
  // Bookings
  static String get availableSlots => '$baseUrl/bookings/available-slots';
  static String get bookingSummary => '$baseUrl/bookings/summary';
  static String get createBooking => '$baseUrl/bookings';
  static String get myBookings => '$baseUrl/bookings/my';
  
  // Users
  static String get userTier => '$baseUrl/users/tier';
  
  // Vehicles
  static String get vehicles => '$baseUrl/vehicles';
  
  // Rewards & Loyalty
  static String get rewards => '$baseUrl/rewards';
  static String get loyaltyHome => '$baseUrl/rewards/loyalty';
  static String get redeemReward => '$baseUrl/rewards/redeem';
  static String get vouchers => '$baseUrl/rewards/vouchers';

  // Admin
  static String get adminStats => '$baseUrl/admin/stats';
  static String get adminBookings => '$baseUrl/admin/bookings';
  static String get adminUsers => '$baseUrl/admin/users';
  static String get adminTimeSlots => '$baseUrl/admin/timeslots';
  static String get adminRewards => '$baseUrl/admin/rewards';
  static String get adminStaff => '$baseUrl/admin/staff';
  static String get adminChemicals => '$baseUrl/admin/chemicals';
  static String get adminServiceChemicals => '$baseUrl/admin/service-chemicals';
  static String get adminReviews => '$baseUrl/admin/reviews';
}
