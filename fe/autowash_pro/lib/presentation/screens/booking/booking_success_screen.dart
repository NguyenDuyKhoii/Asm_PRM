import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:autowash_pro/core/theme/app_theme.dart';
import 'package:autowash_pro/presentation/providers/booking_provider.dart';

class BookingSuccessScreen extends StatelessWidget {
  const BookingSuccessScreen({super.key});

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
                final confirm = provider.bookingConfirmation;
                if (confirm == null) return const Center(child: CircularProgressIndicator());

                return Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            
                            // Success Icon Circle
                            Container(
                              width: 80, height: 80,
                              decoration: BoxDecoration(
                                color: AppTheme.success.withAlpha(20),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Container(
                                  width: 60, height: 60,
                                  decoration: const BoxDecoration(
                                    color: AppTheme.success,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(color: Color(0x3D10B981), blurRadius: 16, offset: Offset(0, 6))
                                    ],
                                  ),
                                  child: const Icon(Icons.check_rounded, color: Colors.white, size: 36),
                                ),
                              ),
                            ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
                            
                            const SizedBox(height: 18),
                            
                            Text(
                              'Đặt lịch thành công!',
                              style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.textPrimary, letterSpacing: -0.5),
                            ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
                            
                            const SizedBox(height: 6),
                            
                            Text(
                              'Lịch đặt của bạn đã được xác nhận.',
                              style: GoogleFonts.outfit(fontSize: 14, color: AppTheme.textSecondary, fontWeight: FontWeight.w600),
                            ).animate().fadeIn(duration: 400.ms, delay: 250.ms),

                            const SizedBox(height: 28),

                            // Ticket Container (Frosted glass look + clean border)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(color: Colors.grey.shade100, width: 1.5),
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withAlpha(6), blurRadius: 24, offset: const Offset(0, 8))
                                ],
                              ),
                              child: Column(
                                children: [
                                  // QR Code with custom styling
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(24),
                                      border: Border.all(color: Colors.grey.shade100, width: 2),
                                      boxShadow: [
                                        BoxShadow(color: Colors.black.withAlpha(3), blurRadius: 10, offset: const Offset(0, 4))
                                      ],
                                    ),
                                    child: QrImageView(
                                      data: confirm.qrCode,
                                      version: QrVersions.auto,
                                      size: 180,
                                      eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: AppTheme.textPrimary),
                                      dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: AppTheme.textPrimary),
                                    ),
                                  ).animate().fadeIn(duration: 500.ms, delay: 350.ms),
                                  
                                  const SizedBox(height: 14),
                                  
                                  Text(
                                    'MÃ CHECK-IN',
                                    style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w900, color: AppTheme.textMuted, letterSpacing: 1.5),
                                  ),
                                  
                                  const SizedBox(height: 24),
                                  _divider(),

                                  // Details rows
                                  _successDetailRow(Icons.local_car_wash_rounded, 'Dịch vụ', confirm.serviceName),
                                  _divider(),
                                  _successDetailRow(Icons.directions_car_filled_rounded, 'Biển số xe', confirm.vehiclePlate),
                                  _divider(),
                                  _successDetailRow(Icons.calendar_month_rounded, 'Ngày', '${confirm.bookingDate.day}/${confirm.bookingDate.month}/${confirm.bookingDate.year}'),
                                  _divider(),
                                  _successDetailRow(Icons.access_time_filled_rounded, 'Thời gian', confirm.timeSlotDisplay),
                                  _divider(),

                                  const SizedBox(height: 16),

                                  // Price
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Tổng thanh toán',
                                        style: GoogleFonts.outfit(fontSize: 14, color: AppTheme.textSecondary, fontWeight: FontWeight.w700),
                                      ),
                                      Text(
                                        _formatCurrency(confirm.totalPrice),
                                        style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.primaryBlue),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ).animate().fadeIn(duration: 500.ms, delay: 300.ms).slideY(begin: 0.05),
                          ],
                        ),
                      ),
                    ),

                    // Back to Home Button
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: SizedBox(
                        width: double.infinity,
                        height: 58,
                        child: ElevatedButton(
                          onPressed: () {
                            provider.resetBookingFlow();
                            Navigator.popUntil(context, (route) => route.isFirst);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryBlue,
                            foregroundColor: Colors.white,
                            elevation: 8,
                            shadowColor: AppTheme.primaryBlue.withAlpha(80),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                          ),
                          child: Text(
                            'Về trang chủ',
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
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

  Widget _successDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppTheme.textSecondary),
          const SizedBox(width: 10),
          Text(label, style: GoogleFonts.outfit(fontSize: 13, color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
          const Spacer(),
          Text(value, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
        ],
      ),
    );
  }

  Widget _divider() {
    return const Divider(height: 1, thickness: 1, color: Color(0xFFF9FAFB));
  }
}
