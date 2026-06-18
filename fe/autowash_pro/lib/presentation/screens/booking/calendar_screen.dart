import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:autowash_pro/core/theme/app_theme.dart';
import 'package:autowash_pro/presentation/providers/booking_provider.dart';
import 'package:autowash_pro/presentation/screens/booking/booking_summary_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<BookingProvider>(context, listen: false);
      provider.loadUserTier();
      provider.loadVehicles();
    });
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Chọn ngày & giờ',
                              style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.textPrimary, letterSpacing: -0.5),
                            ),
                            Consumer<BookingProvider>(
                              builder: (context, p, _) {
                                if (p.userTier != null) {
                                  return Container(
                                    margin: const EdgeInsets.only(top: 4),
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryBlue.withAlpha(15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Hạng ${p.userTier!.tierName} • Đặt trước ${p.userTier!.maxBookingDays} ngày',
                                      style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.primaryBlue, fontWeight: FontWeight.w800),
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 300.ms),

                Expanded(
                  child: Consumer<BookingProvider>(
                    builder: (context, provider, _) {
                      final maxDays = provider.userTier?.maxBookingDays ?? 7;
                      final lastDay = DateTime.now().add(Duration(days: maxDays));

                      return SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Calendar Card
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(color: Colors.grey.shade100, width: 1.5),
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withAlpha(4), blurRadius: 24, offset: const Offset(0, 8))
                                ],
                              ),
                              child: TableCalendar(
                                firstDay: DateTime.now(),
                                lastDay: lastDay,
                                focusedDay: _focusedDay,
                                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                                calendarFormat: CalendarFormat.month,
                                startingDayOfWeek: StartingDayOfWeek.monday,
                                onDaySelected: (selectedDay, focusedDay) {
                                  setState(() {
                                    _selectedDay = selectedDay;
                                    _focusedDay = focusedDay;
                                  });
                                  provider.selectDate(selectedDay);
                                },
                                enabledDayPredicate: (day) {
                                  return day.isAfter(DateTime.now().subtract(const Duration(days: 1))) &&
                                         day.isBefore(lastDay.add(const Duration(days: 1)));
                                },
                                headerStyle: HeaderStyle(
                                  formatButtonVisible: false,
                                  titleCentered: true,
                                  titleTextStyle: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                                  leftChevronIcon: const Icon(Icons.chevron_left_rounded, color: AppTheme.textPrimary),
                                  rightChevronIcon: const Icon(Icons.chevron_right_rounded, color: AppTheme.textPrimary),
                                ),
                                daysOfWeekStyle: DaysOfWeekStyle(
                                  weekdayStyle: GoogleFonts.outfit(fontSize: 13, color: AppTheme.textSecondary, fontWeight: FontWeight.w600),
                                  weekendStyle: GoogleFonts.outfit(fontSize: 13, color: AppTheme.textSecondary, fontWeight: FontWeight.w600),
                                ),
                                calendarStyle: CalendarStyle(
                                  todayDecoration: BoxDecoration(
                                    color: AppTheme.primaryBlue.withAlpha(20),
                                    shape: BoxShape.circle,
                                  ),
                                  todayTextStyle: GoogleFonts.outfit(color: AppTheme.primaryBlue, fontWeight: FontWeight.w800),
                                  selectedDecoration: const BoxDecoration(
                                    color: AppTheme.primaryBlue,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(color: Color(0x3D3B82F6), blurRadius: 10, offset: Offset(0, 4))
                                    ],
                                  ),
                                  selectedTextStyle: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w800),
                                  defaultTextStyle: GoogleFonts.outfit(color: AppTheme.textPrimary, fontWeight: FontWeight.w600),
                                  weekendTextStyle: GoogleFonts.outfit(color: AppTheme.textPrimary, fontWeight: FontWeight.w600),
                                  disabledTextStyle: GoogleFonts.outfit(color: AppTheme.textMuted.withAlpha(80)),
                                  outsideTextStyle: GoogleFonts.outfit(color: AppTheme.textMuted.withAlpha(40)),
                                ),
                              ),
                            ).animate().fadeIn(duration: 500.ms, delay: 100.ms),

                            const SizedBox(height: 24),

                            // Vehicle Selection
                            if (provider.vehicles.isNotEmpty) ...[
                              Text(
                                'Chọn xe của bạn',
                                style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w900, color: AppTheme.textPrimary, letterSpacing: -0.3),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 95,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: provider.vehicles.length,
                                  physics: const BouncingScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    final vehicle = provider.vehicles[index];
                                    final isSelected = provider.selectedVehicle?.id == vehicle.id;
                                    return GestureDetector(
                                      onTap: () => provider.selectVehicle(vehicle),
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        margin: const EdgeInsets.only(right: 12, bottom: 8, top: 4),
                                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                        decoration: BoxDecoration(
                                          color: isSelected ? AppTheme.primaryBlue : Colors.white,
                                          borderRadius: BorderRadius.circular(22),
                                          border: Border.all(
                                            color: isSelected ? Colors.transparent : Colors.grey.shade100,
                                            width: 1.5,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: isSelected ? AppTheme.primaryBlue.withAlpha(60) : Colors.black.withAlpha(4),
                                              blurRadius: isSelected ? 14 : 8,
                                              offset: isSelected ? const Offset(0, 6) : const Offset(0, 2),
                                            )
                                          ],
                                        ),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              vehicle.vehicleType == 0 ? Icons.directions_car_filled_rounded : Icons.two_wheeler_rounded,
                                              color: isSelected ? Colors.white : AppTheme.textSecondary,
                                              size: 26,
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              vehicle.licensePlate,
                                              style: GoogleFonts.outfit(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w800,
                                                color: isSelected ? Colors.white : AppTheme.textPrimary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
                              const SizedBox(height: 20),
                            ],

                            // Time Slots
                            if (_selectedDay != null) ...[
                              Text(
                                'Chọn khung giờ',
                                style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w900, color: AppTheme.textPrimary, letterSpacing: -0.3),
                              ),
                              const SizedBox(height: 12),

                              if (provider.isLoading)
                                const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: AppTheme.primaryBlue)))
                              else if (provider.error != null)
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppTheme.error.withAlpha(15),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: AppTheme.error.withAlpha(30), width: 1.5),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.error_outline_rounded, color: AppTheme.error),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          'Lỗi: ${provider.error}',
                                          style: GoogleFonts.outfit(color: AppTheme.error, fontSize: 13, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else if (provider.availableSlots.isEmpty)
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Text('Không có khung giờ trống nào', style: GoogleFonts.outfit(color: AppTheme.textSecondary, fontSize: 14, fontWeight: FontWeight.w500)),
                                  ),
                                )
                              else
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  children: provider.availableSlots.map((slot) {
                                    final isSelected = provider.selectedSlot?.timeSlotId == slot.timeSlotId;
                                    return GestureDetector(
                                      onTap: slot.isAvailable ? () => provider.selectSlot(slot) : null,
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                                        decoration: BoxDecoration(
                                          color: isSelected ? AppTheme.primaryBlue : (slot.isAvailable ? Colors.white : Colors.grey.shade50),
                                          borderRadius: BorderRadius.circular(18),
                                          border: Border.all(
                                            color: isSelected
                                                ? Colors.transparent
                                                : slot.isAvailable
                                                    ? Colors.grey.shade200
                                                    : Colors.grey.shade100,
                                            width: 1.5,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: isSelected ? AppTheme.primaryBlue.withAlpha(60) : Colors.black.withAlpha(4),
                                              blurRadius: isSelected ? 12 : 6,
                                              offset: isSelected ? const Offset(0, 4) : const Offset(0, 1),
                                            )
                                          ],
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              '${slot.startTime} - ${slot.endTime}',
                                              style: GoogleFonts.outfit(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w800,
                                                color: isSelected
                                                    ? Colors.white
                                                    : slot.isAvailable
                                                        ? AppTheme.textPrimary
                                                        : AppTheme.textMuted.withAlpha(120),
                                              ),
                                            ),
                                            if (!slot.isAvailable) ...[
                                              const SizedBox(height: 4),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: AppTheme.error.withAlpha(20),
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  'Hết chỗ',
                                                  style: GoogleFonts.outfit(fontSize: 9, color: AppTheme.error, fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ).animate().fadeIn(duration: 400.ms, delay: 300.ms),
                            ],

                            const SizedBox(height: 30),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Continue Button Area
                Consumer<BookingProvider>(
                  builder: (context, provider, _) {
                    final canContinue = provider.selectedDate != null && provider.selectedSlot != null && provider.selectedVehicle != null;
                    return Padding(
                      padding: const EdgeInsets.all(20),
                      child: SizedBox(
                        width: double.infinity,
                        height: 58,
                        child: ElevatedButton(
                          onPressed: canContinue
                              ? () async {
                                  final success = await provider.loadBookingSummary();
                                  if (success && context.mounted) {
                                    Navigator.push(context, MaterialPageRoute(builder: (_) => const BookingSummaryScreen()));
                                  }
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: canContinue ? AppTheme.primaryBlue : Colors.grey.shade200,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey.shade200,
                            disabledForegroundColor: Colors.grey.shade400,
                            elevation: canContinue ? 8 : 0,
                            shadowColor: AppTheme.primaryBlue.withAlpha(80),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                          ),
                          child: Text(
                            'Tiếp tục',
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: canContinue ? Colors.white : Colors.grey.shade400,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
