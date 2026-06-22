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
import 'package:autowash_pro/presentation/screens/vehicle/my_vehicles_screen.dart';
import 'package:autowash_pro/presentation/screens/loyalty/loyalty_home_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

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

  void _onNavTapped(int index) {
    if (index == 0) return;
    if (index == 1) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const MyVehiclesScreen()));
    } else if (index == 2) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const MyBookingsScreen()));
    } else if (index == 3) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const LoyaltyHomeScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final booking = Provider.of<BookingProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              
              // 1. Header (Avatar, Welcome, Bell)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppTheme.accentLightBlue,
                        child: Text(
                          auth.user?.fullName.substring(0, 1).toUpperCase() ?? 'P',
                          style: GoogleFonts.outfit(color: AppTheme.pristineNavy, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Welcome back,', style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textSecondary)),
                          Text(
                            auth.user?.fullName ?? 'Pristine Care',
                            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.pristineNavy),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_none_rounded, color: AppTheme.pristineNavy),
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 2. Member Status Card (Pristine Style)
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.pristineDark, AppTheme.primaryBlue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: AppTheme.primaryBlue.withAlpha(40), blurRadius: 15, offset: const Offset(0, 8))
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(color: Colors.white12, shape: BoxShape.circle),
                              child: const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'MEMBER STATUS',
                              style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(40),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'LEVEL 4',
                            style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Pristine Gold',
                      style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '${booking.userTier?.loyaltyPoints ?? 7500}',
                          style: GoogleFonts.outfit(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white, height: 1),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'points',
                          style: GoogleFonts.outfit(fontSize: 14, color: Colors.white.withAlpha(200)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '2,500 points until Platinum',
                      style: GoogleFonts.outfit(fontSize: 12, color: Colors.white.withAlpha(180)),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(30),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: 0.75, // 75%
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(colors: [Color(0xFF89F7FE), Color(0xFF66A6FF)]),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const LoyaltyHomeScreen()));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppTheme.primaryBlue,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            minimumSize: const Size(0, 36),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          child: Text('Redeem', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 3. Action Grid (2x2)
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.4,
                children: [
                  _actionCard(Icons.calendar_month_outlined, 'Book Now', () {
                    booking.resetBookingFlow();
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ServiceListScreen()));
                  }),
                  _actionCard(Icons.history_rounded, 'History', () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const MyBookingsScreen()));
                  }),
                  _actionCard(Icons.directions_car_outlined, 'My Garage', () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const MyVehiclesScreen()));
                  }),
                  _actionCard(Icons.card_giftcard_rounded, 'Offers', () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const LoyaltyHomeScreen()));
                  }),
                ],
              ),
              const SizedBox(height: 32),

              // 4. Popular Services
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Popular Services', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.pristineNavy)),
                  Text('View All', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
                ],
              ),
              const SizedBox(height: 16),
              
              if (booking.services.isNotEmpty)
                ...booking.services.take(3).map((service) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10, offset: const Offset(0, 4))
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppTheme.accentLightBlue,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.water_drop_outlined, color: AppTheme.pristineNavy),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(service.name, style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.access_time, size: 12, color: AppTheme.textSecondary),
                                  const SizedBox(width: 4),
                                  Text('30 mins', style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textSecondary)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${service.price.toStringAsFixed(0)}đ',
                              style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(color: AppTheme.accentLightBlue, borderRadius: BorderRadius.circular(10)),
                              child: Text('+50 pts', style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
                
              const SizedBox(height: 24),
              
              // 5. Summer Offer Banner
              Container(
                width: double.infinity,
                height: 140,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: AppTheme.pristineNavy,
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.asset(
                        'assets/images/background.png',
                        fit: BoxFit.cover,
                        color: Colors.black.withAlpha(100),
                        colorBlendMode: BlendMode.darken,
                        errorBuilder: (context, error, stackTrace) => Container(),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('SUMMER OFFER', style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.amber, letterSpacing: 1)),
                          const SizedBox(height: 8),
                          Text('20% Off\nInterior Packages', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white, height: 1.2)),
                          const SizedBox(height: 8),
                          Text('Keep your car fresh and cool this season.', style: GoogleFonts.outfit(fontSize: 11, color: Colors.white.withAlpha(200))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 80), // Space for bottom nav
            ],
          ),
        ),
      ),
      // Custom Bottom Navigation
      extendBody: true,
      bottomNavigationBar: Container(
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 20, offset: const Offset(0, -5))
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _navItem(0, Icons.home_rounded, 'Home'),
            _navItem(1, Icons.directions_car_rounded, 'Cars'),
            const SizedBox(width: 48), // Space for FAB
            _navItem(2, Icons.history_rounded, 'History'),
            _navItem(3, Icons.stars_rounded, 'Rewards'),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        margin: const EdgeInsets.only(top: 20),
        height: 60,
        width: 60,
        decoration: BoxDecoration(
          color: AppTheme.pristineDark,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: AppTheme.pristineDark.withAlpha(80), blurRadius: 15, offset: const Offset(0, 5))
          ],
        ),
        child: IconButton(
          icon: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
          onPressed: () {
            booking.resetBookingFlow();
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ServiceListScreen()));
          },
        ),
      ),
    );
  }

  Widget _actionCard(IconData icon, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10, offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.accentLightBlue,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppTheme.primaryBlue, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? AppTheme.primaryBlue : AppTheme.textMuted;
    return GestureDetector(
      onTap: () => _onNavTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(label, style: GoogleFonts.outfit(fontSize: 10, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, color: color)),
        ],
      ),
    );
  }
}
