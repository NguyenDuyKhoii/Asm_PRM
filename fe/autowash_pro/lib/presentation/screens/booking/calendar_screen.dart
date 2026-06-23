import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:autowash_pro/core/theme/app_theme.dart';
import 'package:autowash_pro/presentation/providers/booking_provider.dart';
import 'package:autowash_pro/presentation/screens/booking/booking_summary_screen.dart';
import 'package:autowash_pro/presentation/screens/vehicle/my_vehicles_screen.dart';

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
    final serviceName = Provider.of<BookingProvider>(context).selectedService?.name ?? 'Service';
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      appBar: AppBar(
        title: Text('Book - $serviceName', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        backgroundColor: AppTheme.scaffoldBg,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Consumer<BookingProvider>(
          builder: (context, provider, _) {
            final maxDays = provider.userTier?.maxBookingDays ?? 7;
            final lastDay = DateTime.now().add(Duration(days: maxDays));

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Select Date & Time', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.pristineNavy)),
                        const SizedBox(height: 4),
                        Text('Choose a suitable time to take care of your car.', style: GoogleFonts.outfit(fontSize: 14, color: AppTheme.textSecondary)),
                        const SizedBox(height: 24),

                        // Calendar Card
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 20, offset: const Offset(0, 4))
                            ],
                          ),
                          padding: const EdgeInsets.all(16),
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
                              titleCentered: false,
                              titleTextStyle: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.pristineNavy),
                              leftChevronIcon: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade300)),
                                child: const Icon(Icons.chevron_left_rounded, size: 16, color: AppTheme.pristineNavy),
                              ),
                              rightChevronIcon: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade300)),
                                child: const Icon(Icons.chevron_right_rounded, size: 16, color: AppTheme.pristineNavy),
                              ),
                            ),
                            calendarBuilders: CalendarBuilders(
                              dowBuilder: (context, day) {
                                final text = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'][day.weekday == 7 ? 0 : day.weekday];
                                return Center(
                                  child: Text(text, style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textMuted, fontWeight: FontWeight.bold)),
                                );
                              },
                              headerTitleBuilder: (context, day) {
                                return Text(
                                  'Month ${day.month}, ${day.year}',
                                  style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.pristineNavy),
                                );
                              },
                            ),
                            calendarStyle: CalendarStyle(
                              todayDecoration: const BoxDecoration(color: Colors.transparent),
                              todayTextStyle: GoogleFonts.outfit(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold),
                              selectedDecoration: BoxDecoration(color: AppTheme.primaryBlue, borderRadius: BorderRadius.circular(12)),
                              selectedTextStyle: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
                              defaultTextStyle: GoogleFonts.outfit(color: AppTheme.textPrimary, fontWeight: FontWeight.w500),
                              weekendTextStyle: GoogleFonts.outfit(color: AppTheme.textPrimary, fontWeight: FontWeight.w500),
                              disabledTextStyle: GoogleFonts.outfit(color: AppTheme.textMuted.withAlpha(80)),
                              outsideDaysVisible: false,
                              cellMargin: const EdgeInsets.all(6),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Selected Vehicle
                        Text('SELECT VEHICLE', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textSecondary, letterSpacing: 1)),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.scaffoldBg,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 50, height: 50,
                                decoration: BoxDecoration(
                                  color: AppTheme.accentLightBlue,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  provider.selectedVehicle?.vehicleType == 0 ? Icons.directions_car_rounded : Icons.two_wheeler_rounded,
                                  color: AppTheme.primaryBlue,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      provider.selectedVehicle?.name?.isNotEmpty == true 
                                          ? provider.selectedVehicle!.name! 
                                          : (provider.selectedVehicle?.vehicleTypeName ?? 'No vehicle selected'),
                                      style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      provider.selectedVehicle != null 
                                          ? 'ID: ${provider.selectedVehicle!.licensePlate}${provider.selectedVehicle!.color?.isNotEmpty == true ? ' • ${provider.selectedVehicle!.color}' : ''}' 
                                          : 'Please select a vehicle',
                                      style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => const MyVehiclesScreen(isSelectionMode: true)));
                                },
                                child: Text('Change', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Time Slots
                        Text('SELECT TIME SLOT', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textSecondary, letterSpacing: 1)),
                        const SizedBox(height: 12),
                        if (_selectedDay == null)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text('Please select a date first', style: GoogleFonts.outfit(color: AppTheme.textSecondary, fontSize: 14)),
                            ),
                          )
                        else if (provider.isLoading)
                          const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: AppTheme.primaryBlue)))
                        else if (provider.error != null)
                          Text('Error: ${provider.error}', style: GoogleFonts.outfit(color: AppTheme.error))
                        else if (provider.availableSlots.isEmpty)
                          Text('No available time slots', style: GoogleFonts.outfit(color: AppTheme.textSecondary))
                        else
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 2.8,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            itemCount: provider.availableSlots.length,
                            itemBuilder: (context, index) {
                              final slot = provider.availableSlots[index];
                              final isSelected = provider.selectedSlot?.timeSlotId == slot.timeSlotId;
                              
                              return GestureDetector(
                                onTap: slot.isAvailable ? () => provider.selectSlot(slot) : null,
                                child: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: isSelected ? AppTheme.primaryBlue : Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isSelected ? AppTheme.primaryBlue : Colors.grey.shade300,
                                    ),
                                  ),
                                  child: Text(
                                    '${slot.startTime} - ${slot.endTime}${!slot.isAvailable ? ' (Full)' : ''}',
                                    style: GoogleFonts.outfit(
                                      fontSize: 14,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                      color: isSelected ? Colors.white : (slot.isAvailable ? AppTheme.textPrimary : AppTheme.textMuted),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          
                        const SizedBox(height: 24),
                        
                        // Ad Banner
                        Container(
                          width: double.infinity,
                          height: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: AppTheme.pristineNavy,
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: Image.asset(
                                  'assets/images/background.png',
                                  fit: BoxFit.cover,
                                  color: Colors.black.withAlpha(80),
                                  colorBlendMode: BlendMode.darken,
                                  errorBuilder: (_,__,___) => Container(),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(8)),
                                      child: Text('PREMIUM SERVICE', style: GoogleFonts.outfit(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.black)),
                                    ),
                                    const SizedBox(height: 8),
                                    Text('Ensure perfect shine', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
                
                // Bottom Button
                Consumer<BookingProvider>(
                  builder: (context, provider, _) {
                    final canContinue = provider.selectedDate != null && provider.selectedSlot != null && provider.selectedVehicle != null;
                    return Container(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 20, offset: const Offset(0, -5))
                        ],
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
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
                            backgroundColor: AppTheme.primaryBlue,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey.shade300,
                            disabledForegroundColor: Colors.grey.shade500,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Continue', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward, size: 20),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
