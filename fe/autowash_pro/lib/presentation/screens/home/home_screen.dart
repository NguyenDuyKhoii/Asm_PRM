
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
      body: Stack(
        children: [
          // Photography Background Image
          Positioned.fill(
            child: Opacity(
              opacity: 0.10,
              child: Image.asset(
                'assets/images/background.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          
          // Main Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              physics: const BouncingScrollPhysics(),
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
                            'Xin chào,',
                            style: GoogleFonts.outfit(fontSize: 16, color: AppTheme.textSecondary, letterSpacing: 0.5),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            auth.user?.fullName ?? 'Khách',
                            style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w800, color: AppTheme.textPrimary, height: 1.1),
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
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 10, spreadRadius: 1)],
                          ),
                          child: const Icon(Icons.logout_rounded, color: AppTheme.textSecondary, size: 22),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.2),

                  const SizedBox(height: 32),

                  // Tier Card
                  if (booking.userTier != null)
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: AppTheme.getTierGradient(booking.userTier!.tierName),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(color: AppTheme.getTierGradient(booking.userTier!.tierName).colors.first.withAlpha(76), blurRadius: 24, offset: const Offset(0, 12)),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // Card Background pattern
                          Positioned(
                            right: -20, top: -20,
                            child: Icon(Icons.star_rounded, size: 140, color: Colors.white.withAlpha(30)),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(28),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Thẻ thành viên', style: GoogleFonts.outfit(fontSize: 14, color: Colors.white.withAlpha(200), fontWeight: FontWeight.w500)),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withAlpha(50),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: Colors.white.withAlpha(76)),
                                      ),
                                      child: Text(
                                        booking.userTier!.tierName.toUpperCase(),
                                        style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 1.5),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${booking.userTier!.loyaltyPoints}',
                                      style: GoogleFonts.outfit(fontSize: 48, fontWeight: FontWeight.w900, color: Colors.white, height: 1),
                                    ),
                                    const SizedBox(width: 8),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 6),
                                      child: Text('điểm', style: GoogleFonts.outfit(fontSize: 16, color: Colors.white.withAlpha(200), fontWeight: FontWeight.w600)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      _tierInfoChip(Icons.event_available_rounded, 'Đặt trước ${booking.userTier!.maxBookingDays} ngày'),
                                      const SizedBox(width: 12),
                                      _tierInfoChip(Icons.local_offer_rounded, 'Giảm ${booking.userTier!.discountPercentage.toStringAsFixed(0)}%'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 600.ms, delay: 200.ms).scale(begin: const Offset(0.95, 0.95)),

                  const SizedBox(height: 36),

                  // Quick Actions
                  Text('Trải nghiệm dịch vụ', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: _actionCard(
                          icon: Icons.calendar_month_rounded,
                          title: 'Đặt lịch\nngay',
                          gradient: AppTheme.primaryGradient,
                          onTap: () {
                            booking.resetBookingFlow();
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const ServiceListScreen()));
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _actionCard(
                          icon: Icons.history_rounded,
                          title: 'Lịch sử\nđặt lịch',
                          gradient: const LinearGradient(colors: [Color(0xFF28D8A1), Color(0xFF00C6FF)]),
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const MyBookingsScreen()));
                          },
                        ),
                      ),
                    ],
                  ).animate().fadeIn(duration: 600.ms, delay: 400.ms).slideY(begin: 0.1),

                  const SizedBox(height: 36),

                  // Services Preview
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Dịch vụ phổ biến', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
                      Text('Xem tất cả', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.primaryBlue)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  if (booking.services.isNotEmpty)
                    ...booking.services.take(3).map((service) {
                      final index = booking.services.indexOf(service);
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 20, offset: const Offset(0, 5))],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 56, height: 56,
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryBlue.withAlpha(20),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: const Icon(Icons.local_car_wash_rounded, color: AppTheme.primaryBlue, size: 28),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(service.name, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(Icons.timer_outlined, size: 14, color: AppTheme.textSecondary),
                                        const SizedBox(width: 4),
                                        Text(service.formattedDuration, style: GoogleFonts.outfit(fontSize: 14, color: AppTheme.textSecondary)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryBlue.withAlpha(15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  service.formattedPrice,
                                  style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.primaryBlue),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(duration: 500.ms, delay: Duration(milliseconds: 600 + index * 100)).slideX(begin: 0.1);
                    }),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tierInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(40),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withAlpha(50)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(text, style: GoogleFonts.outfit(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _actionCard({required IconData icon, required String title, required Gradient gradient, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 150,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(color: gradient.colors.first.withAlpha(100), blurRadius: 20, offset: const Offset(0, 10))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(50),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            Text(title, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white, height: 1.2)),
          ],
        ),
      ),
    );
  }
}
