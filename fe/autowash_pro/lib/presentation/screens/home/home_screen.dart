import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:autowash_pro/core/theme/app_theme.dart';
import 'package:autowash_pro/presentation/providers/auth_provider.dart';
import 'package:autowash_pro/presentation/providers/booking_provider.dart';
import 'package:autowash_pro/presentation/screens/booking/service_list_screen.dart';
import 'package:autowash_pro/presentation/screens/booking/calendar_screen.dart';
import 'package:autowash_pro/presentation/screens/booking/my_bookings_screen.dart';
import 'package:autowash_pro/presentation/screens/vehicle/my_vehicles_screen.dart';
import 'package:autowash_pro/presentation/screens/loyalty/loyalty_home_screen.dart';
import 'package:autowash_pro/presentation/screens/auth/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final int _currentIndex = 0;

  // Fallback asset images for service cards
  static const List<String> _serviceAssets = [
    'assets/images/service_carwash.jpg',
    'assets/images/service_interior.jpg',
    'assets/images/service_inspection.jpg',
  ];

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

  // ── Tier-based color scheme ──
  _TierColors _getTierColors(String tierName) {
    final t = tierName.toLowerCase();
    if (t.contains('platinum') || t.contains('diamond')) {
      return _TierColors(
        cardBg: const Color(0xFFE8EFF5),
        pillBg: const Color(0xFFB0C4DE),
        pillText: const Color(0xFF2C3E6B),
        accent: const Color(0xFF5B7FA5),
        progressBar: const Color(0xFF5B7FA5),
      );
    } else if (t.contains('gold')) {
      return _TierColors(
        cardBg: const Color(0xFFF5E6B8),
        pillBg: const Color(0xFFE6B800),
        pillText: const Color(0xFF5C3D00),
        accent: const Color(0xFFB8860B),
        progressBar: const Color(0xFFB8860B),
      );
    } else if (t.contains('silver')) {
      return _TierColors(
        cardBg: const Color(0xFFF1F2F4),
        pillBg: const Color(0xFFD6D9DF),
        pillText: const Color(0xFF4B5563),
        accent: const Color(0xFF8993A4),
        progressBar: const Color(0xFF8993A4),
      );
    } else {
      // Bronze / Member / default
      return _TierColors(
        cardBg: const Color(0xFFF5EFE6),
        pillBg: const Color(0xFFE2D5C3),
        pillText: const Color(0xFF6B5B47),
        accent: const Color(0xFFA8906E),
        progressBar: const Color(0xFFA8906E),
      );
    }
  }

  String _translateTier(String tier) {
    final t = tier.toLowerCase();
    if (t.contains('platinum')) return 'Bạch kim';
    if (t.contains('gold')) return 'Vàng';
    if (t.contains('silver')) return 'Bạc';
    return 'Thành viên';
  }

  // ── Dynamic Progress Calculation ──
  Map<String, dynamic> _getTierProgress(int points, String actualTier) {
    int nextThreshold = 100;
    int currentBase = 0;
    String nextTierName = 'Bạc';
    String membershipTitle = 'Thành viên\nTiêu chuẩn';
    
    final t = actualTier.toLowerCase();
    if (t.contains('platinum') || t.contains('diamond')) {
      nextThreshold = points > 0 ? points : 1; 
      currentBase = 1000;
      nextTierName = 'Hạng tối đa';
      membershipTitle = 'Thành viên\nBạch kim';
    } else if (t.contains('gold')) {
      nextThreshold = 1000;
      currentBase = 300;
      nextTierName = 'Bạch kim';
      membershipTitle = 'Thành viên\nVàng';
    } else if (t.contains('silver')) {
      nextThreshold = 300;
      currentBase = 100;
      nextTierName = 'Vàng';
      membershipTitle = 'Thành viên\nBạc';
    } else {
      nextThreshold = 100;
      currentBase = 0;
      nextTierName = 'Bạc';
      membershipTitle = 'Thành viên\nTiêu chuẩn';
    }

    double progress = 1.0;
    if (nextThreshold > currentBase) {
      progress = (points - currentBase) / (nextThreshold - currentBase);
    }
    if (progress > 1.0) progress = 1.0;
    if (progress < 0.0) progress = 0.0;
    
    int percent = (progress * 100).toInt();
    if (t.contains('platinum') || t.contains('diamond')) {
      return {
        'progress': 1.0,
        'text': 'Đã đạt hạng cao nhất',
        'title': membershipTitle,
      };
    }
    
    return {
      'progress': progress,
      'text': 'Còn $percent% để lên $nextTierName',
      'title': membershipTitle,
    };
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final booking = Provider.of<BookingProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // ═══════════════ 1. HEADER ═══════════════
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      // Avatar
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.accentLightBlue,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withAlpha(15), blurRadius: 8, offset: const Offset(0, 3)),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            auth.user?.fullName.substring(0, 1).toUpperCase() ?? 'K',
                            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.pristineNavy),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                          'CHÀO MỪNG QUAY LẠI',
                            style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.w700, color: AppTheme.textMuted, letterSpacing: 1.5),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            auth.user?.fullName ?? 'Khoi',
                            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.pristineNavy),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      // Logout Button
                      GestureDetector(
                        onTap: () async {
                          await auth.logout();
                          if (context.mounted) {
                            Navigator.pushAndRemoveUntil(
                              context, 
                              MaterialPageRoute(builder: (_) => const LoginScreen()),
                              (route) => false,
                            );
                          }
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 10, offset: const Offset(0, 3)),
                            ],
                          ),
                          child: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Notifications
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 10, offset: const Offset(0, 3)),
                          ],
                        ),
                        child: const Icon(Icons.notifications_none_rounded, color: AppTheme.pristineNavy, size: 22),
                      ),
                    ],
                  ),
                ],
              ).animate().fadeIn(duration: 400.ms),

              const SizedBox(height: 24),

              // ═══════════════ 2. MEMBERSHIP CARD ═══════════════
              _buildMembershipCard(booking, auth).animate().fadeIn(duration: 500.ms, delay: 100.ms).slideY(begin: 0.08),

              const SizedBox(height: 28),

              // ═══════════════ 3. QUICK ACTIONS (4 circles) ═══════════════
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _actionCircle(Icons.calendar_month_outlined, 'Đặt lịch', () {
                    booking.resetBookingFlow();
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ServiceListScreen()));
                  }),
                  _actionCircle(Icons.history_rounded, 'Lịch sử', () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const MyBookingsScreen()));
                  }),
                  _actionCircle(Icons.directions_car_outlined, 'Nhà xe', () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const MyVehiclesScreen()));
                  }),
                  _actionCircle(Icons.local_offer_outlined, 'Ưu đãi', () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const LoyaltyHomeScreen()));
                  }),
                ],
              ).animate().fadeIn(duration: 500.ms, delay: 200.ms),

              const SizedBox(height: 28),

              // ═══════════════ 4. SUMMER COLLECTION BANNER ═══════════════
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ServiceListScreen()));
                },
                child: Container(
                  width: double.infinity,
                  height: 160,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withAlpha(18), blurRadius: 20, offset: const Offset(0, 8)),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        'assets/images/banner_summer.jpg',
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(
                          color: AppTheme.pristineNavy,
                          child: Image.asset('assets/images/background.png', fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => const SizedBox(),
                          ),
                        ),
                      ),
                      // Dark gradient overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.black.withAlpha(190), Colors.black.withAlpha(40)],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                      ),
                      // Content
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'DỊCH VỤ NỔI BẬT',
                              style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white.withAlpha(180), letterSpacing: 2),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Bộ sưu tập mùa hè',
                              style: GoogleFonts.playfairDisplay(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white),
                            ),
                            const SizedBox(height: 14),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'KHÁM PHÁ NGAY',
                                style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.pristineNavy, letterSpacing: 0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: 600.ms, delay: 300.ms).slideY(begin: 0.08),

              const SizedBox(height: 32),

              // ═══════════════ 5. POPULAR SERVICES ═══════════════
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Dịch vụ phổ biến', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.pristineNavy)),
                  GestureDetector(
                    onTap: () {
                      booking.resetBookingFlow();
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ServiceListScreen()));
                    },
                    child: Text('Xem tất cả', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.primaryBlue)),
                  ),
                ],
              ).animate().fadeIn(duration: 500.ms, delay: 400.ms),

              const SizedBox(height: 16),

              // Service cards
              if (booking.services.isNotEmpty)
                ...booking.services.take(3).toList().asMap().entries.map((entry) {
                  final idx = entry.key;
                  final service = entry.value;
                  final assetImage = _serviceAssets[idx % _serviceAssets.length];

                  return _buildServiceCard(service, assetImage, booking, idx)
                      .animate()
                      .fadeIn(duration: 500.ms, delay: Duration(milliseconds: 450 + idx * 120))
                      .slideY(begin: 0.06);
                }),

              const SizedBox(height: 90), // Space for bottom nav
            ],
          ),
        ),
      ),

      // ═══════════════ BOTTOM NAVIGATION ═══════════════
      extendBody: true,
      bottomNavigationBar: Container(
        height: 72,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 20, offset: const Offset(0, -4)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _navItem(0, Icons.home_outlined, Icons.home_rounded, 'Trang chủ'),
            _navItem(1, Icons.directions_car_outlined, Icons.directions_car_rounded, 'Nhà xe'),
            const SizedBox(width: 16),
            _navItem(2, Icons.history_outlined, Icons.history_rounded, 'Lịch sử'),
            _navItem(3, Icons.stars_outlined, Icons.stars_rounded, 'Ưu đãi'),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        margin: const EdgeInsets.only(top: 16),
        height: 56,
        width: 56,
        child: FloatingActionButton(
          onPressed: () {
            booking.resetBookingFlow();
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ServiceListScreen()));
          },
          backgroundColor: AppTheme.primaryBlue,
          elevation: 6,
          shape: const CircleBorder(),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  MEMBERSHIP CARD — color adapts to tier
  // ─────────────────────────────────────────────
  Widget _buildMembershipCard(BookingProvider booking, AuthProvider auth) {
    final points = auth.user?.loyaltyPoints ?? booking.userTier?.loyaltyPoints ?? 0;
    
    // Resolve actual tier dynamically from points
    String actualTier = 'Member';
    if (points >= 1000) {
      actualTier = 'Platinum';
    } else if (points >= 300) {
      actualTier = 'Gold';
    } else if (points >= 100) {
      actualTier = 'Silver';
    }

    final colors = _getTierColors(actualTier);
    final progressData = _getTierProgress(points, actualTier);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: colors.cardBg,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: colors.cardBg.withAlpha(120), blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left side
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tier pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: colors.pillBg,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        'HẠNG ${_translateTier(actualTier).toUpperCase()}',
                        style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.w800, color: colors.pillText, letterSpacing: 0.8),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      progressData['title'],
                      style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.pristineNavy, height: 1.25),
                    ),
                  ],
                ),
              ),
              // Right side — points
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$points',
                    style: GoogleFonts.outfit(fontSize: 30, fontWeight: FontWeight.w900, color: colors.accent, height: 1),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ĐIỂM\nTÍCH LŨY',
                    textAlign: TextAlign.right,
                    style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.w800, color: AppTheme.textSecondary, letterSpacing: 0.6, height: 1.3),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 22),

          // Progress bar + label
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(12),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progressData['progress'],
                    child: Container(
                      decoration: BoxDecoration(
                        color: colors.progressBar,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Text(
                progressData['text'],
                style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.pristineNavy),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  SERVICE CARD
  // ─────────────────────────────────────────────
  Widget _buildServiceCard(dynamic service, String assetImage, BookingProvider booking, int index) {
    // Points earned per service (example mapping)
    final ptsLabels = ['+650 pts', '+1,200 pts', '+900 pts'];
    final ptsLabel = ptsLabels[index % ptsLabels.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 20, offset: const Offset(0, 6)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Image ──
          SizedBox(
            height: 180,
            width: double.infinity,
            child: Image.asset(
                    assetImage,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(color: Colors.grey[200]),
                  ),
          ),

          // ── Content ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name + Price row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        service.name,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.italic,
                          color: AppTheme.pristineNavy,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          service.formattedPrice,
                          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.pristineNavy),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          ptsLabel,
                          style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w700, color: const Color(0xFFD4A517)),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Description (uppercase blue)
                Text(
                  service.description.isNotEmpty
                      ? service.description.toUpperCase()
                      : 'PREMIUM CAR CARE SERVICE',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.primaryBlue, letterSpacing: 0.5),
                ),

                const SizedBox(height: 10),

                // Duration
                Row(
                  children: [
                    Icon(Icons.access_time_rounded, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 5),
                    Text(
                      service.formattedDuration,
                      style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey[600]),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Book now + arrow
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        booking.resetBookingFlow();
                        booking.selectService(service);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const CalendarScreen()));
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F4FD),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Book now',
                          style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.primaryBlue),
                        ),
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey[400]),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  ACTION CIRCLE
  // ─────────────────────────────────────────────
  Widget _actionCircle(IconData icon, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 12, offset: const Offset(0, 4)),
              ],
            ),
            child: Icon(icon, color: AppTheme.pristineNavy, size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  BOTTOM NAV ITEM
  // ─────────────────────────────────────────────
  Widget _navItem(int index, IconData outlineIcon, IconData filledIcon, String label) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? AppTheme.primaryBlue : AppTheme.textMuted;
    final icon = isSelected ? filledIcon : outlineIcon;
    return GestureDetector(
      onTap: () => _onNavTapped(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.outfit(fontSize: 10, fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500, color: color),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  TIER COLORS DATA CLASS
// ─────────────────────────────────────────────
class _TierColors {
  final Color cardBg;
  final Color pillBg;
  final Color pillText;
  final Color accent;
  final Color progressBar;

  const _TierColors({
    required this.cardBg,
    required this.pillBg,
    required this.pillText,
    required this.accent,
    required this.progressBar,
  });
}
