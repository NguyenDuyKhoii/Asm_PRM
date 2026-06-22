
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:autowash_pro/core/theme/app_theme.dart';
import 'package:autowash_pro/data/models/service_model.dart';
import 'package:autowash_pro/presentation/providers/booking_provider.dart';
import 'package:autowash_pro/presentation/screens/vehicle/my_vehicles_screen.dart';

class ServiceListScreen extends StatefulWidget {
  const ServiceListScreen({super.key});

  @override
  State<ServiceListScreen> createState() => _ServiceListScreenState();
}

class _ServiceListScreenState extends State<ServiceListScreen> {
  String _selectedCategory = 'Tất cả';

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

  Color _getServiceColor(int index) {
    final colors = [
      const Color(0xFF3B82F6), // Blue
      const Color(0xFF14B8A6), // Teal
      const Color(0xFFEC4899), // Pink
      const Color(0xFFF59E0B), // Amber
      const Color(0xFF8B5CF6), // Purple
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Subtle background texture/image
          Positioned.fill(
            child: Opacity(
              opacity: 0.08,
              child: Image.asset(
                'assets/images/background.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey.shade50,
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(8),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textPrimary, size: 16),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dịch vụ của chúng tôi',
                            style: GoogleFonts.outfit(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.textPrimary,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Text(
                            'Chăm sóc xế yêu của bạn một cách tốt nhất',
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1),

                // Category Selector
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: SizedBox(
                    height: 42,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      physics: const BouncingScrollPhysics(),
                      children: [
                        _categoryChip('Tất cả', Icons.grid_view_rounded),
                        _categoryChip('Rửa xe', Icons.local_car_wash_rounded),
                        _categoryChip('Chăm sóc', Icons.auto_awesome_rounded),
                        _categoryChip('Đánh bóng', Icons.cleaning_services_rounded),
                      ],
                    ),
                  ),
                ).animate().fadeIn(duration: 400.ms, delay: 100.ms),

                const SizedBox(height: 12),

                // Service List
                Expanded(
                  child: Consumer<BookingProvider>(
                    builder: (context, provider, _) {
                      if (provider.isLoading) {
                        return const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue));
                      }

                      // Apply category filter
                      final filteredServices = provider.services.where((s) {
                        if (_selectedCategory == 'Tất cả') return true;
                        if (_selectedCategory == 'Rửa xe') {
                          return s.name.contains('Rửa xe');
                        }
                        if (_selectedCategory == 'Chăm sóc') {
                          return s.name.contains('Chăm sóc') || s.name.contains('Hút bụi');
                        }
                        if (_selectedCategory == 'Đánh bóng') {
                          return s.name.contains('Đánh bóng');
                        }
                        return true;
                      }).toList();

                      if (filteredServices.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off_rounded, size: 64, color: AppTheme.textMuted.withAlpha(100)),
                              const SizedBox(height: 16),
                              Text(
                                'Không tìm thấy dịch vụ phù hợp',
                                style: GoogleFonts.outfit(fontSize: 16, color: AppTheme.textSecondary, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                        physics: const BouncingScrollPhysics(),
                        itemCount: filteredServices.length,
                        itemBuilder: (context, index) {
                          final service = filteredServices[index];
                          final accentColor = _getServiceColor(index);
                          final isPopular = service.name.contains('cao cấp') || service.name.contains('toàn diện');

                          return _ServiceListItem(
                            service: service,
                            icon: _getServiceIcon(index),
                            accentColor: accentColor,
                            isPopular: isPopular,
                            onTap: () {
                              provider.selectService(service);
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const MyVehiclesScreen(isSelectionMode: true)));
                            },
                          ).animate().fadeIn(duration: 450.ms, delay: Duration(milliseconds: index * 60)).slideY(begin: 0.05);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryChip(String title, IconData icon) {
    final isSelected = _selectedCategory == title;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = title;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey.shade200,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withAlpha(50),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: isSelected ? Colors.white : AppTheme.textSecondary),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? Colors.white : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceListItem extends StatelessWidget {
  final ServiceModel service;
  final IconData icon;
  final Color accentColor;
  final bool isPopular;
  final VoidCallback onTap;

  const _ServiceListItem({
    required this.service,
    required this.icon,
    required this.accentColor,
    required this.isPopular,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isPopular ? accentColor.withAlpha(60) : Colors.grey.shade100,
            width: isPopular ? 2.0 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(5),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
            if (isPopular)
              BoxShadow(
                color: accentColor.withAlpha(12),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative background glowing aura
            Positioned(
              top: -30,
              right: -30,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: accentColor.withAlpha(15),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon container with dynamic visual glow
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: accentColor.withAlpha(30), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: accentColor.withAlpha(20),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(icon, color: accentColor, size: 28),
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Text Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                service.name,
                                style: GoogleFonts.outfit(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.textPrimary,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ),
                            if (isPopular)
                              Container(
                                margin: const EdgeInsets.only(left: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: accentColor.withAlpha(25),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: accentColor.withAlpha(50), width: 1),
                                ),
                                child: Text(
                                  'BÁN CHẠY',
                                  style: GoogleFonts.outfit(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    color: accentColor,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          service.description,
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Duration Badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.grey.shade200, width: 1),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.access_time_filled_rounded, size: 13, color: Colors.grey.shade600),
                                  const SizedBox(width: 4),
                                  Text(
                                    service.formattedDuration,
                                    style: GoogleFonts.outfit(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Pricing Badge
                            Text(
                              service.formattedPrice,
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.primaryBlue,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
