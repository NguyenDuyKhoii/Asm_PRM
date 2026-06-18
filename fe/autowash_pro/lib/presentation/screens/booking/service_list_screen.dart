import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:autowash_pro/core/theme/app_theme.dart';
import 'package:autowash_pro/data/models/service_model.dart';
import 'package:autowash_pro/presentation/providers/booking_provider.dart';
import 'package:autowash_pro/presentation/screens/booking/calendar_screen.dart';

class ServiceListScreen extends StatefulWidget {
  const ServiceListScreen({super.key});

  @override
  State<ServiceListScreen> createState() => _ServiceListScreenState();
}

class _ServiceListScreenState extends State<ServiceListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BookingProvider>(context, listen: false).loadServices();
    });
  }

  IconData _getServiceIcon(int index) {
    final icons = [
      Icons.water_drop_rounded,
      Icons.auto_awesome,
      Icons.cleaning_services_rounded,
      Icons.diamond_rounded,
      Icons.star_rounded,
    ];
    return icons[index % icons.length];
  }

  List<Color> _getServiceColors(int index) {
    final colors = [
      [const Color(0xFF667EEA), const Color(0xFF764BA2)],
      [const Color(0xFF00BCD4), const Color(0xFF009688)],
      [const Color(0xFFFF6B6B), const Color(0xFFEE5A24)],
      [const Color(0xFFFFD700), const Color(0xFFFF8F00)],
      [const Color(0xFF7C4DFF), const Color(0xFFB388FF)],
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // AppBar
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.cardBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF2A2A3E)),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text('Chọn dịch vụ', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
                  ],
                ),
              ).animate().fadeIn(duration: 300.ms),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Chọn dịch vụ bạn muốn sử dụng',
                  style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary),
                ),
              ).animate().fadeIn(duration: 300.ms, delay: 100.ms),

              const SizedBox(height: 20),

              // Service List
              Expanded(
                child: Consumer<BookingProvider>(
                  builder: (context, provider, _) {
                    if (provider.isLoading) {
                      return const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue));
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: provider.services.length,
                      itemBuilder: (context, index) {
                        final service = provider.services[index];
                        final colors = _getServiceColors(index);
                        return _ServiceCard(
                          service: service,
                          icon: _getServiceIcon(index),
                          gradientColors: colors,
                          onTap: () {
                            provider.selectService(service);
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const CalendarScreen()));
                          },
                        ).animate().fadeIn(duration: 400.ms, delay: Duration(milliseconds: 100 + index * 80)).slideX(begin: 0.1);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final ServiceModel service;
  final IconData icon;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const _ServiceCard({required this.service, required this.icon, required this.gradientColors, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF2A2A3E)),
        ),
        child: Row(
          children: [
            Container(
              width: 60, height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradientColors),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [BoxShadow(color: gradientColors[0].withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(service.name, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                  const SizedBox(height: 6),
                  Text(service.description, style: TextStyle(fontSize: 13, color: AppTheme.textMuted), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: AppTheme.accentCyan.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                        child: Text(service.formattedDuration, style: GoogleFonts.inter(fontSize: 11, color: AppTheme.accentCyan, fontWeight: FontWeight.w600)),
                      ),
                      const Spacer(),
                      Text(service.formattedPrice, style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.accentCyan)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted, size: 24),
          ],
        ),
      ),
    );
  }
}
