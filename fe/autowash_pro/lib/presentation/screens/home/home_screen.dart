import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:autowash_pro/core/theme/app_theme.dart';
import 'package:autowash_pro/presentation/providers/auth_provider.dart';
import 'package:autowash_pro/presentation/providers/booking_provider.dart';
import 'package:autowash_pro/presentation/screens/auth/login_screen.dart';
import 'package:autowash_pro/presentation/screens/booking/service_list_screen.dart';
import 'package:autowash_pro/presentation/screens/booking/my_bookings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
      bookingProvider.loadUserTier();
      bookingProvider.loadServices();
      bookingProvider.loadVehicles();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final booking = Provider.of<BookingProvider>(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F0F23), Color(0xFF1A1A2E), Color(0xFF0A0A1A)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Xin chào! 👋',
                          style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary),
                        ),
                        Text(
                          auth.user?.fullName ?? 'Khách',
                          style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () async {
                        await auth.logout();
                        if (mounted) {
                          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (r) => false);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.cardBg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFF2A2A3E)),
                        ),
                        child: const Icon(Icons.logout_rounded, color: AppTheme.textSecondary, size: 22),
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 400.ms),

                const SizedBox(height: 24),

                // Tier Card
                if (booking.userTier != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: AppTheme.getTierGradient(booking.userTier!.tierName),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.gradientStart.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('AutoWash Pro', style: GoogleFonts.inter(fontSize: 14, color: Colors.white70, fontWeight: FontWeight.w500)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                booking.userTier!.tierName.toUpperCase(),
                                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 1),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          '${booking.userTier!.loyaltyPoints}',
                          style: GoogleFonts.inter(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white),
                        ),
                        Text('Điểm tích lũy', style: GoogleFonts.inter(fontSize: 14, color: Colors.white70)),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _tierInfoChip(Icons.calendar_today, 'Đặt trước ${booking.userTier!.maxBookingDays} ngày'),
                            const SizedBox(width: 8),
                            _tierInfoChip(Icons.discount, 'Giảm ${booking.userTier!.discountPercentage.toStringAsFixed(0)}%'),
                          ],
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 500.ms, delay: 200.ms).slideY(begin: 0.1),

                const SizedBox(height: 28),

                // Quick Actions
                Text('Dịch vụ', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _actionCard(
                        icon: Icons.calendar_month_rounded,
                        title: 'Đặt lịch\nrửa xe',
                        gradient: AppTheme.primaryGradient,
                        onTap: () {
                          booking.resetBookingFlow();
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const ServiceListScreen()));
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _actionCard(
                        icon: Icons.history_rounded,
                        title: 'Lịch sử\nđặt lịch',
                        gradient: const LinearGradient(colors: [Color(0xFF00BCD4), Color(0xFF009688)]),
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const MyBookingsScreen()));
                        },
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 500.ms, delay: 400.ms).slideY(begin: 0.1),

                const SizedBox(height: 28),

                // Services Preview
                Text('Dịch vụ phổ biến', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                const SizedBox(height: 16),

                if (booking.services.isNotEmpty)
                  ...booking.services.take(3).map((service) {
                    final index = booking.services.indexOf(service);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF2A2A3E)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 50, height: 50,
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.local_car_wash, color: Colors.white, size: 24),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(service.name, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                                const SizedBox(height: 4),
                                Text('${service.formattedDuration}', style: TextStyle(fontSize: 13, color: AppTheme.textMuted)),
                              ],
                            ),
                          ),
                          Text(
                            service.formattedPrice,
                            style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.accentCyan),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 400.ms, delay: Duration(milliseconds: 500 + index * 100)).slideX(begin: 0.1);
                  }),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _tierInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 4),
          Text(text, style: GoogleFonts.inter(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _actionCard({required IconData icon, required String title, required Gradient gradient, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 130,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: Colors.white, size: 32),
            Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white, height: 1.3)),
          ],
        ),
      ),
    );
  }
}
