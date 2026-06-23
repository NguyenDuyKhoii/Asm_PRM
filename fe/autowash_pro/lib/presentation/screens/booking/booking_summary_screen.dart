import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:autowash_pro/core/theme/app_theme.dart';
import 'package:autowash_pro/presentation/providers/booking_provider.dart';
import 'package:autowash_pro/presentation/screens/booking/booking_success_screen.dart';

class BookingSummaryScreen extends StatelessWidget {
  const BookingSummaryScreen({super.key});

  String _formatCurrency(double amount) {
    final formatter = amount.toStringAsFixed(0);
    final chars = formatter.split('');
    final buffer = StringBuffer();
    for (int i = 0; i < chars.length; i++) {
      if (i > 0 && (chars.length - i) % 3 == 0) buffer.write('.');
      buffer.write(chars[i]);
    }
    return '${buffer} VND';
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5E9ED), // Light grey/slate background
      body: SafeArea(
        child: Consumer<BookingProvider>(
          builder: (context, provider, _) {
            final summary = provider.bookingSummary;
            final selectedService = provider.selectedService;
            if (summary == null) return const Center(child: CircularProgressIndicator());

            return Column(
              children: [
                // AppBar Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          child: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.pristineNavy, size: 18),
                        ),
                      ),
                      Text(
                        'NEXUS DETAILING',
                        style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w900, color: AppTheme.pristineNavy, letterSpacing: 0.5),
                      ),
                      Container(
                        width: 40, height: 40,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: AssetImage('assets/images/avatar.png'), // Or network image placeholder
                            fit: BoxFit.cover,
                          ),
                          color: AppTheme.pristineNavy,
                        ),
                        child: const Icon(Icons.person, color: Colors.white, size: 20), // Fallback
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        // Titles
                        Text(
                          'Confirm Booking',
                          style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.w800, color: AppTheme.pristineNavy),
                        ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),
                        const SizedBox(height: 6),
                        Text(
                          'Please review the details',
                          style: GoogleFonts.outfit(fontSize: 14, color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
                        ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideY(begin: 0.1),
                        const SizedBox(height: 24),

                        // Service Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(220),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                right: -10,
                                top: -10,
                                bottom: -10,
                                child: Icon(Icons.water_drop_rounded, size: 120, color: Colors.grey.shade200),
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 56, height: 56,
                                    decoration: BoxDecoration(
                                      color: AppTheme.pristineNavy,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Icon(Icons.cleaning_services_rounded, color: Colors.white, size: 28),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('SERVICE', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.textSecondary, letterSpacing: 1)),
                                        const SizedBox(height: 4),
                                        Text(summary.serviceName, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.pristineNavy)),
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            const Icon(Icons.timer_outlined, size: 16, color: AppTheme.primaryBlue),
                                            const SizedBox(width: 6),
                                            Text('${selectedService?.durationMinutes ?? 60} mins', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.primaryBlue)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ).animate().fadeIn(duration: 400.ms, delay: 150.ms).slideY(begin: 0.1),
                        const SizedBox(height: 16),

                        // Two info cards row
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(220),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.directions_car_rounded, color: AppTheme.pristineNavy, size: 22),
                                    const SizedBox(height: 12),
                                    Text('Vehicle', style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
                                    const SizedBox(height: 4),
                                    Text('${summary.vehiclePlate} (${summary.vehicleTypeName})', style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.pristineNavy)),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(220),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.workspace_premium_rounded, color: Colors.amber, size: 22),
                                    const SizedBox(height: 12),
                                    Text('Membership Tier', style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
                                    const SizedBox(height: 4),
                                    Text(summary.tierName, style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.pristineNavy)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ).animate().fadeIn(duration: 400.ms, delay: 200.ms).slideY(begin: 0.1),
                        const SizedBox(height: 16),

                        // Appointment Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(220),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryBlue.withAlpha(20),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.calendar_month_rounded, color: AppTheme.primaryBlue, size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Text('Appointment', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.pristineNavy)),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryBlue.withAlpha(20),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text('Pending', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.primaryBlue)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Date', style: GoogleFonts.outfit(fontSize: 13, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
                                        const SizedBox(height: 6),
                                        Text(DateFormat('dd / MM / yyyy').format(summary.bookingDate), style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.pristineNavy)),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Time', style: GoogleFonts.outfit(fontSize: 13, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
                                        const SizedBox(height: 6),
                                        Text(summary.timeSlotDisplay, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.pristineNavy)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ).animate().fadeIn(duration: 400.ms, delay: 250.ms).slideY(begin: 0.1),
                        const SizedBox(height: 32),

                        // Pricing Section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Original Price', style: GoogleFonts.outfit(fontSize: 14, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
                            Text(
                              _formatCurrency(summary.originalPrice),
                              style: GoogleFonts.outfit(
                                fontSize: 14, color: AppTheme.textSecondary, fontWeight: FontWeight.w600,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ),
                        if (summary.discountAmount > 0) ...[
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Member Discount (${summary.tierName})', style: GoogleFonts.outfit(fontSize: 14, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
                              Text(
                                '- ${_formatCurrency(summary.discountAmount)}',
                                style: GoogleFonts.outfit(fontSize: 14, color: AppTheme.primaryBlue, fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 24),

                        // Final Total
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Total\nPayment',
                              style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.pristineNavy, height: 1.1),
                            ),
                            Text(
                              _formatCurrency(summary.finalPrice),
                              style: GoogleFonts.outfit(fontSize: 36, fontWeight: FontWeight.w900, color: AppTheme.primaryBlue, height: 1.0),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Note Banner
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(150),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 2),
                                child: Icon(Icons.info_outline_rounded, color: AppTheme.primaryBlue, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    style: GoogleFonts.outfit(fontSize: 13, color: AppTheme.textSecondary, fontWeight: FontWeight.w500, height: 1.5),
                                    children: [
                                      const TextSpan(text: 'Pay at the station. Please present the '),
                                      TextSpan(text: 'QR', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: AppTheme.pristineNavy)),
                                      const TextSpan(text: ' code when you arrive to start the service.'),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(duration: 400.ms, delay: 350.ms),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),

                // Confirm Action Button Area
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: provider.isLoading
                          ? null
                          : () async {
                              final success = await provider.confirmBooking();
                              if (success && context.mounted) {
                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const BookingSuccessScreen()));
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.pristineNavy, // Wait, image shows Dark Blue button!
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade300,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                      ),
                      child: provider.isLoading
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 20),
                                const SizedBox(width: 8),
                                Text('Confirm Booking', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                              ],
                            ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
