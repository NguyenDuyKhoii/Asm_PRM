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
    return '${buffer}đ';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background photo subtle texture
          Positioned.fill(
            child: Opacity(
              opacity: 0.08,
              child: Image.asset(
                'assets/images/background.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey.shade50),
              ),
            ),
          ),
          
          SafeArea(
            child: Consumer<BookingProvider>(
              builder: (context, provider, _) {
                final summary = provider.bookingSummary;
                if (summary == null) return const Center(child: CircularProgressIndicator());

                return Column(
                  children: [
                    // AppBar Header
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
                                  BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 16, offset: const Offset(0, 4))
                                ],
                              ),
                              child: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textPrimary, size: 16),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'Xác nhận đặt lịch',
                            style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.textPrimary, letterSpacing: -0.5),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 300.ms),

                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          children: [
                            // Receipt Card
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(color: Colors.grey.shade100, width: 1.5),
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 24, offset: const Offset(0, 8))
                                ],
                              ),
                              child: Column(
                                children: [
                                  // Header Icon
                                  Container(
                                    width: 64, height: 64,
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryBlue.withAlpha(15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Center(
                                      child: Icon(Icons.receipt_long_rounded, color: AppTheme.primaryBlue, size: 32),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Chi tiết đặt lịch',
                                    style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.textPrimary, letterSpacing: -0.3),
                                  ),
                                  const SizedBox(height: 24),
                                  _divider(),

                                  // Details list with modern layout
                                  _infoRow(Icons.local_car_wash_rounded, 'Dịch vụ', summary.serviceName, Colors.blue),
                                  _divider(),
                                  _infoRow(Icons.directions_car_filled_rounded, 'Xe', '${summary.vehiclePlate} (${summary.vehicleTypeName})', Colors.teal),
                                  _divider(),
                                  _infoRow(Icons.calendar_month_rounded, 'Ngày', DateFormat('dd/MM/yyyy').format(summary.bookingDate), Colors.orange),
                                  _divider(),
                                  _infoRow(Icons.access_time_filled_rounded, 'Giờ', summary.timeSlotDisplay, Colors.purple),
                                  _divider(),
                                  _infoRow(Icons.workspace_premium_rounded, 'Hạng thành viên', summary.tierName, Colors.amber),
                                  _divider(),

                                  const SizedBox(height: 20),

                                  // Original Pricing
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Giá gốc', style: GoogleFonts.outfit(fontSize: 14, color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
                                      Text(_formatCurrency(summary.originalPrice), style: GoogleFonts.outfit(fontSize: 14, color: AppTheme.textSecondary, fontWeight: FontWeight.w700)),
                                    ],
                                  ),

                                  if (summary.discountAmount > 0) ...[
                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: AppTheme.success.withAlpha(15),
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(color: AppTheme.success.withAlpha(30), width: 1.5),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(Icons.discount_rounded, color: AppTheme.success, size: 16),
                                              const SizedBox(width: 8),
                                              Text(summary.perkApplied, style: GoogleFonts.outfit(fontSize: 13, color: AppTheme.success, fontWeight: FontWeight.w800)),
                                            ],
                                          ),
                                          Text(
                                            '-${_formatCurrency(summary.discountAmount)}',
                                            style: GoogleFonts.outfit(fontSize: 14, color: AppTheme.success, fontWeight: FontWeight.w900),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],

                                  const SizedBox(height: 18),
                                  
                                  // Coupon dotted line divider
                                  Row(
                                    children: List.generate(
                                      20,
                                      (index) => Expanded(
                                        child: Container(
                                          color: index % 2 == 0 ? Colors.transparent : Colors.grey.shade300,
                                          height: 1.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 18),

                                  // Final Total
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Tổng thanh toán', style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w900, color: AppTheme.textPrimary, letterSpacing: -0.2)),
                                      Text(
                                        _formatCurrency(summary.finalPrice),
                                        style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.primaryBlue),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ).animate().fadeIn(duration: 500.ms, delay: 150.ms).slideY(begin: 0.05),

                            const SizedBox(height: 20),

                            // Note Banner
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryBlue.withAlpha(15),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: AppTheme.primaryBlue.withAlpha(30), width: 1.5),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.info_outline_rounded, color: AppTheme.primaryBlue, size: 22),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Thanh toán tại trạm. Vui lòng xuất trình mã QR khi đến trạm.',
                                      style: GoogleFonts.outfit(fontSize: 13, color: AppTheme.primaryBlue, fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ],
                              ),
                            ).animate().fadeIn(duration: 400.ms, delay: 300.ms),

                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ),

                    // Confirm Action Button Area
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: SizedBox(
                        width: double.infinity,
                        height: 58,
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
                            backgroundColor: AppTheme.primaryBlue,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey.shade200,
                            elevation: 8,
                            shadowColor: AppTheme.primaryBlue.withAlpha(80),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                          ),
                          child: provider.isLoading
                              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.check_circle_rounded, color: Colors.white),
                                    const SizedBox(width: 8),
                                    Text('Xác nhận đặt lịch', style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white)),
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
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withAlpha(15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Text(label, style: GoogleFonts.outfit(fontSize: 14, color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return const Divider(height: 1, thickness: 1, color: Color(0xFFF9FAFB));
  }
}
