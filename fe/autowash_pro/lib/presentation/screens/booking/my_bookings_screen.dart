
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
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
      case 'completed': return AppTheme.primaryBlue;
      case 'cancelled': return AppTheme.error;
      default: return AppTheme.textMuted;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed': return 'Confirmed';
      case 'pending': return 'Pending';
      case 'inprogress': return 'In Progress';
      case 'completed': return 'Completed';
      case 'cancelled': return 'Cancelled';
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
    return '$buffer VND';
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
            child: Column(
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Booking History',
                            style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.textPrimary, letterSpacing: -0.5),
                          ),
                          Text(
                            'Manage your bookings',
                            style: GoogleFonts.outfit(fontSize: 13, color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 300.ms),

                // Booking Statistics Bar (detailing UI)
                Consumer<BookingProvider>(
                  builder: (context, provider, _) {
                    if (provider.myBookings.isEmpty || provider.isLoading) return const SizedBox.shrink();
                    final completedCount = provider.myBookings.where((b) => b.status.toLowerCase() == 'completed').length;
                    final activeCount = provider.myBookings.where((b) => b.status.toLowerCase() == 'confirmed' || b.status.toLowerCase() == 'inprogress').length;
                    
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade100, width: 1.5),
                        boxShadow: [BoxShadow(color: Colors.black.withAlpha(4), blurRadius: 16, offset: const Offset(0, 4))],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _statItem(activeCount.toString(), 'Active', AppTheme.primaryBlue),
                          Container(width: 1, height: 30, color: Colors.grey.shade200),
                          _statItem(completedCount.toString(), 'Completed', AppTheme.success),
                          Container(width: 1, height: 30, color: Colors.grey.shade200),
                          _statItem(provider.myBookings.length.toString(), 'Total', AppTheme.textPrimary),
                        ],
                      ),
                    ).animate().fadeIn(duration: 400.ms, delay: 150.ms);
                  },
                ),

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
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.calendar_today_rounded, size: 64, color: AppTheme.textMuted.withAlpha(100)),
                              ),
                              const SizedBox(height: 20),
                              Text('No bookings yet', style: GoogleFonts.outfit(fontSize: 18, color: AppTheme.textSecondary, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 6),
                              Text('Your bookings will appear here', style: GoogleFonts.outfit(fontSize: 14, color: AppTheme.textMuted)),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                        physics: const BouncingScrollPhysics(),
                        itemCount: provider.myBookings.length,
                        itemBuilder: (context, index) {
                          final booking = provider.myBookings[index];
                          final statusColor = _getStatusColor(booking.status);

                          return GestureDetector(
                            onTap: () {
                              _showETicket(context, booking);
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 18),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: Colors.grey.shade100, width: 1.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(4),
                                    blurRadius: 20,
                                    offset: const Offset(0, 6),
                                  )
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                              child: Stack(
                                children: [
                                  // Accent bar at the left edge
                                  Positioned(
                                    left: 0, top: 0, bottom: 0,
                                    child: Container(width: 6, color: statusColor),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Header
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                booking.serviceName,
                                                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textPrimary, letterSpacing: -0.2),
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: statusColor.withAlpha(20),
                                                borderRadius: BorderRadius.circular(10),
                                                border: Border.all(color: statusColor.withAlpha(40), width: 1),
                                              ),
                                              child: Text(
                                                _getStatusText(booking.status),
                                                style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w900, color: statusColor),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        
                                        // Details Grid
                                        Row(
                                          children: [
                                            _detailBadge(Icons.directions_car_filled_rounded, booking.vehiclePlate),
                                            const SizedBox(width: 12),
                                            _detailBadge(Icons.calendar_month_rounded, DateFormat('dd/MM/yyyy').format(booking.bookingDate)),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            _detailBadge(Icons.access_time_filled_rounded, booking.timeSlotDisplay),
                                          ],
                                        ),
                                        
                                        // Dynamic dash line divider
                                        const SizedBox(height: 16),
                                        Row(
                                          children: List.generate(
                                            25,
                                            (index) => Expanded(
                                              child: Container(
                                                color: index % 2 == 0 ? Colors.transparent : Colors.grey.shade200,
                                                height: 1.5,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 12),

                                        // Total Price
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Total Cost',
                                              style: GoogleFonts.outfit(fontSize: 13, color: AppTheme.textSecondary, fontWeight: FontWeight.w600),
                                            ),
                                            Text(
                                              _formatCurrency(booking.totalPrice),
                                              style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.primaryBlue),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ).animate().fadeIn(duration: 400.ms, delay: Duration(milliseconds: index * 60)).slideY(begin: 0.05);
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

  void _showETicket(BuildContext context, dynamic booking) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 40, offset: const Offset(0, 10))
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'E-Ticket',
                style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                'Scan this code at the station to check-in',
                style: GoogleFonts.outfit(fontSize: 14, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppTheme.primaryBlue.withAlpha(50), width: 2),
                  boxShadow: [
                    BoxShadow(color: AppTheme.primaryBlue.withAlpha(10), blurRadius: 16, offset: const Offset(0, 8))
                  ],
                ),
                child: QrImageView(
                  data: booking.qrCode,
                  version: QrVersions.auto,
                  size: 200,
                  eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: AppTheme.primaryBlue),
                  dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: AppTheme.textPrimary),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Service:', style: GoogleFonts.outfit(fontSize: 14, color: AppTheme.textSecondary)),
                  Text(booking.serviceName, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('License Plate:', style: GoogleFonts.outfit(fontSize: 14, color: AppTheme.textSecondary)),
                  Text(booking.vehiclePlate, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 300.ms).scale(begin: const Offset(0.9, 0.9)),
      ),
    );
  }

  Widget _statItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w900, color: color),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _detailBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.textSecondary),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.outfit(fontSize: 13, color: AppTheme.textPrimary, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
