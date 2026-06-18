class ApiConstants {
  static const String baseUrl = 'http://10.0.2.2:5000/api'; // Android emulator
  // static const String baseUrl = 'http://localhost:5000/api'; // iOS simulator
  
  // Auth
  static const String register = '$baseUrl/auth/register';
  static const String login = '$baseUrl/auth/login';
  
  // Services
  static const String services = '$baseUrl/services';
  
  // Bookings
  static const String availableSlots = '$baseUrl/bookings/available-slots';
  static const String bookingSummary = '$baseUrl/bookings/summary';
  static const String createBooking = '$baseUrl/bookings';
  static const String myBookings = '$baseUrl/bookings/my';
  
  // Users
  static const String userTier = '$baseUrl/users/tier';
  
  // Vehicles
  static const String vehicles = '$baseUrl/vehicles';
}
