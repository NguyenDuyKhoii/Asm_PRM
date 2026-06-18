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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F0F23), Color(0xFF1A1A2E), Color(0xFF0A0A1A)],
          ),
        ),
        child: SafeArea(
          child: Consumer<BookingProvider>(
            builder: (context, provider, _) {
              final summary = provider.bookingSummary;
              if (summary == null) return const Center(child: CircularProgressIndicator());

              return Column(
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
                        Text('Xác nhận đặt lịch', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
                      ],
                    ),
                  ).animate().fadeIn(duration: 300.ms),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          // Receipt Card
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: AppTheme.cardBg,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: const Color(0xFF2A2A3E)),
                            ),
                            child: Column(
                              children: [
                                // Header
                                Container(
                                  width: 60, height: 60,
                                  decoration: BoxDecoration(
                                    gradient: AppTheme.primaryGradient,
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 30),
                                ),
                                const SizedBox(height: 16),
                                Text('Chi tiết đặt lịch', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),

                                const SizedBox(height: 24),
                                _divider(),

                                // Service
                                _infoRow(Icons.local_car_wash, 'Dịch vụ', summary.serviceName),
                                _divider(),

                                // Vehicle
                                _infoRow(Icons.directions_car, 'Xe', '${summary.vehiclePlate} (${summary.vehicleTypeName})'),
                                _divider(),

                                // Date
                                _infoRow(Icons.calendar_today, 'Ngày', DateFormat('dd/MM/yyyy').format(summary.bookingDate)),
                                _divider(),

                                // Time
                                _infoRow(Icons.access_time, 'Giờ', summary.timeSlotDisplay),
                                _divider(),

                                // Tier
                                _infoRow(Icons.workspace_premium, 'Hạng', summary.tierName),
                                _divider(),

                                const SizedBox(height: 16),

                                // Pricing
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Giá gốc', style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary)),
                                    Text(_formatCurrency(summary.originalPrice), style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary)),
                                  ],
                                ),

                                if (summary.discountAmount > 0) ...[
                                  const SizedBox(height: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: AppTheme.success.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: AppTheme.success.withValues(alpha: 0.3)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(Icons.discount, color: AppTheme.success, size: 16),
                                            const SizedBox(width: 6),
                                            Text(summary.perkApplied, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.success, fontWeight: FontWeight.w600)),
                                          ],
                                        ),
                                        Text(
                                          '-${_formatCurrency(summary.discountAmount)}',
                                          style: GoogleFonts.inter(fontSize: 14, color: AppTheme.success, fontWeight: FontWeight.w700),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],

                                const SizedBox(height: 16),
                                _divider(),
                                const SizedBox(height: 16),

                                // Total
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Tổng thanh toán', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
                                    Text(
                                      _formatCurrency(summary.finalPrice),
                                      style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.accentCyan),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ).animate().fadeIn(duration: 500.ms, delay: 200.ms).slideY(begin: 0.1),

                          const SizedBox(height: 16),

                          // Note
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.info.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppTheme.info.withValues(alpha: 0.2)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.info_outline, color: AppTheme.info, size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Thanh toán tại trạm. Vui lòng xuất trình mã QR khi đến.',
                                    style: GoogleFonts.inter(fontSize: 12, color: AppTheme.info),
                                  ),
                                ),
                              ],
                            ),
                          ).animate().fadeIn(duration: 400.ms, delay: 400.ms),

                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),

                  // Confirm Button
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: AppTheme.successGradient,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: AppTheme.success.withValues(alpha: 0.4), blurRadius: 15, offset: const Offset(0, 6))],
                        ),
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
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: provider.isLoading
                              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.check_circle, color: Colors.white),
                                    const SizedBox(width: 8),
                                    Text('Xác nhận đặt lịch', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                                  ],
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
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.textMuted, size: 20),
          const SizedBox(width: 12),
          Text(label, style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textMuted)),
          const Spacer(),
          Flexible(child: Text(value, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white), textAlign: TextAlign.right)),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(height: 1, color: const Color(0xFF2A2A3E));
  }
}
