import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:autowash_pro/core/theme/app_theme.dart';
import 'package:autowash_pro/presentation/providers/booking_provider.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BookingProvider>(context, listen: false).loadMyBookings();
    });
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed': return AppTheme.success;
      case 'pending': return AppTheme.warning;
      case 'inprogress': return AppTheme.info;
      case 'completed': return AppTheme.accentCyan;
      case 'cancelled': return AppTheme.error;
      default: return AppTheme.textMuted;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed': return 'Đã xác nhận';
      case 'pending': return 'Đang chờ';
      case 'inprogress': return 'Đang rửa';
      case 'completed': return 'Hoàn thành';
      case 'cancelled': return 'Đã hủy';
      default: return status;
    }
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
            children: [
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
                    Text('Lịch sử đặt lịch', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
                  ],
                ),
              ).animate().fadeIn(duration: 300.ms),

              Expanded(
                child: Consumer<BookingProvider>(
                  builder: (context, provider, _) {
                    if (provider.isLoading) {
                      return const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue));
                    }

                    if (provider.myBookings.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.calendar_today_outlined, size: 64, color: AppTheme.textMuted),
                            const SizedBox(height: 16),
                            Text('Chưa có lịch đặt nào', style: GoogleFonts.inter(fontSize: 16, color: AppTheme.textMuted)),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: provider.myBookings.length,
                      itemBuilder: (context, index) {
                        final booking = provider.myBookings[index];
                        final statusColor = _getStatusColor(booking.status);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: AppTheme.cardBg,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: const Color(0xFF2A2A3E)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      booking.serviceName,
                                      style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: statusColor.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      _getStatusText(booking.status),
                                      style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: statusColor),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(Icons.directions_car, size: 16, color: AppTheme.textMuted),
                                  const SizedBox(width: 6),
                                  Text(booking.vehiclePlate, style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                                  const SizedBox(width: 16),
                                  Icon(Icons.calendar_today, size: 14, color: AppTheme.textMuted),
                                  const SizedBox(width: 6),
                                  Text(DateFormat('dd/MM/yyyy').format(booking.bookingDate), style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                                  const SizedBox(width: 16),
                                  Icon(Icons.access_time, size: 14, color: AppTheme.textMuted),
                                  const SizedBox(width: 6),
                                  Text(booking.timeSlotDisplay, style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _formatCurrency(booking.totalPrice),
                                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.accentCyan),
                              ),
                            ],
                          ),
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
