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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Chọn ngày & giờ', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
                          Consumer<BookingProvider>(
                            builder: (context, p, _) {
                              if (p.userTier != null) {
                                return Text(
                                  '${p.userTier!.tierName} • Đặt trước ${p.userTier!.maxBookingDays} ngày',
                                  style: GoogleFonts.inter(fontSize: 12, color: AppTheme.accentCyan, fontWeight: FontWeight.w500),
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
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Calendar
                          Container(
                            decoration: BoxDecoration(
                              color: AppTheme.cardBg,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFF2A2A3E)),
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
                                titleTextStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                                leftChevronIcon: const Icon(Icons.chevron_left, color: Colors.white),
                                rightChevronIcon: const Icon(Icons.chevron_right, color: Colors.white),
                              ),
                              daysOfWeekStyle: DaysOfWeekStyle(
                                weekdayStyle: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted, fontWeight: FontWeight.w600),
                                weekendStyle: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted, fontWeight: FontWeight.w600),
                              ),
                              calendarStyle: CalendarStyle(
                                todayDecoration: BoxDecoration(
                                  color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                                  shape: BoxShape.circle,
                                ),
                                todayTextStyle: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600),
                                selectedDecoration: const BoxDecoration(
                                  gradient: AppTheme.primaryGradient,
                                  shape: BoxShape.circle,
                                ),
                                selectedTextStyle: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700),
                                defaultTextStyle: GoogleFonts.inter(color: Colors.white),
                                weekendTextStyle: GoogleFonts.inter(color: Colors.white70),
                                disabledTextStyle: GoogleFonts.inter(color: Colors.white24),
                                outsideTextStyle: GoogleFonts.inter(color: Colors.white10),
                              ),
                            ),
                          ).animate().fadeIn(duration: 500.ms, delay: 200.ms),

                          const SizedBox(height: 20),

                          // Vehicle Selection
                          if (provider.vehicles.isNotEmpty) ...[
                            Text('Chọn xe', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 80,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: provider.vehicles.length,
                                itemBuilder: (context, index) {
                                  final vehicle = provider.vehicles[index];
                                  final isSelected = provider.selectedVehicle?.id == vehicle.id;
                                  return GestureDetector(
                                    onTap: () => provider.selectVehicle(vehicle),
                                    child: Container(
                                      margin: const EdgeInsets.only(right: 12),
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                      decoration: BoxDecoration(
                                        gradient: isSelected ? AppTheme.primaryGradient : null,
                                        color: isSelected ? null : AppTheme.cardBg,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: isSelected ? Colors.transparent : const Color(0xFF2A2A3E)),
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            vehicle.vehicleType == 0 ? Icons.directions_car : Icons.two_wheeler,
                                            color: isSelected ? Colors.white : AppTheme.textMuted,
                                            size: 24,
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            vehicle.licensePlate,
                                            style: GoogleFonts.inter(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: isSelected ? Colors.white : AppTheme.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ).animate().fadeIn(duration: 400.ms, delay: 300.ms),
                            const SizedBox(height: 20),
                          ],

                          // Time Slots
                          if (_selectedDay != null) ...[
                            Text('Chọn giờ', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                            const SizedBox(height: 12),

                            if (provider.isLoading)
                              const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: AppTheme.primaryBlue)))
                            else if (provider.availableSlots.isEmpty)
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Text('Không có khung giờ', style: TextStyle(color: AppTheme.textMuted)),
                                ),
                              )
                            else
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: provider.availableSlots.map((slot) {
                                  final isSelected = provider.selectedSlot?.timeSlotId == slot.timeSlotId;
                                  return GestureDetector(
                                    onTap: slot.isAvailable ? () => provider.selectSlot(slot) : null,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      decoration: BoxDecoration(
                                        gradient: isSelected ? AppTheme.primaryGradient : null,
                                        color: isSelected ? null : (slot.isAvailable ? AppTheme.cardBg : AppTheme.cardBg.withValues(alpha: 0.4)),
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: isSelected
                                              ? Colors.transparent
                                              : slot.isAvailable
                                                  ? const Color(0xFF2A2A3E)
                                                  : Colors.transparent,
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                            '${slot.startTime} - ${slot.endTime}',
                                            style: GoogleFonts.inter(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: isSelected
                                                  ? Colors.white
                                                  : slot.isAvailable
                                                      ? AppTheme.textSecondary
                                                      : AppTheme.textMuted.withValues(alpha: 0.4),
                                            ),
                                          ),
                                          if (!slot.isAvailable)
                                            Text('Hết chỗ', style: GoogleFonts.inter(fontSize: 10, color: AppTheme.error)),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ).animate().fadeIn(duration: 400.ms, delay: 400.ms),
                          ],

                          const SizedBox(height: 30),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Continue Button
              Consumer<BookingProvider>(
                builder: (context, provider, _) {
                  final canContinue = provider.selectedDate != null && provider.selectedSlot != null && provider.selectedVehicle != null;
                  return Padding(
                    padding: const EdgeInsets.all(20),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: canContinue ? AppTheme.primaryGradient : null,
                          color: canContinue ? null : AppTheme.cardBg,
                          borderRadius: BorderRadius.circular(16),
                        ),
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
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            disabledBackgroundColor: Colors.transparent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: Text(
                            'Tiếp tục',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: canContinue ? Colors.white : AppTheme.textMuted,
                            ),
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
      ),
    );
  }
}
