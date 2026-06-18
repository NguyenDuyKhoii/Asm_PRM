import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:autowash_pro/core/theme/app_theme.dart';
import 'package:autowash_pro/presentation/providers/booking_provider.dart';
import 'package:autowash_pro/presentation/screens/home/home_screen.dart';

class BookingSuccessScreen extends StatelessWidget {
  const BookingSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BookingProvider>(context);
    final confirmation = provider.bookingConfirmation;

    if (confirmation == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

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
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 40),

                // Success Icon
                Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(
                    gradient: AppTheme.successGradient,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: AppTheme.success.withValues(alpha: 0.4), blurRadius: 30, spreadRadius: 5)],
                  ),
                  child: const Icon(Icons.check_rounded, color: Colors.white, size: 56),
                ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),

                const SizedBox(height: 24),

                Text(
                  'Đặt lịch thành công!',
                  style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white),
                ).animate().fadeIn(duration: 400.ms, delay: 300.ms),

                const SizedBox(height: 8),
                Text(
                  'Xuất trình mã QR tại trạm rửa xe',
                  style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary),
                ).animate().fadeIn(duration: 400.ms, delay: 400.ms),

                const SizedBox(height: 36),

                // QR Code Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))],
                  ),
                  child: Column(
                    children: [
                      Text('MÃ QR CHECK-IN', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.grey[600], letterSpacing: 2)),
                      const SizedBox(height: 20),
                      QrImageView(
                        data: confirmation.qrCode,
                        version: QrVersions.auto,
                        size: 200,
                        backgroundColor: Colors.white,
                        eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Color(0xFF1A1A2E)),
                        dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: Color(0xFF1A1A2E)),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          confirmation.vehiclePlate,
                          style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w900, color: const Color(0xFF1A1A2E), letterSpacing: 2),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 600.ms, delay: 500.ms).slideY(begin: 0.15),

                const SizedBox(height: 24),

                // Booking Info
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF2A2A3E)),
                  ),
                  child: Column(
                    children: [
                      _infoItem(Icons.local_car_wash, 'Dịch vụ', confirmation.serviceName),
                      const SizedBox(height: 12),
                      _infoItem(Icons.calendar_today, 'Ngày', DateFormat('dd/MM/yyyy').format(confirmation.bookingDate)),
                      const SizedBox(height: 12),
                      _infoItem(Icons.access_time, 'Giờ', confirmation.timeSlotDisplay),
                      const SizedBox(height: 12),
                      _infoItem(Icons.payments, 'Tổng tiền', _formatCurrency(confirmation.totalPrice)),
                    ],
                  ),
                ).animate().fadeIn(duration: 500.ms, delay: 700.ms),

                const SizedBox(height: 32),

                // Home Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        provider.resetBookingFlow();
                        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const HomeScreen()), (r) => false);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text('Về trang chủ', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                    ),
                  ),
                ).animate().fadeIn(duration: 400.ms, delay: 900.ms),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.textMuted, size: 18),
        const SizedBox(width: 10),
        Text(label, style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textMuted)),
        const Spacer(),
        Text(value, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
      ],
    );
  }

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
}
