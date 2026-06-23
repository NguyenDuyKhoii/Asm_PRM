import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:autowash_pro/core/theme/app_theme.dart';
import 'package:autowash_pro/data/models/booking_model.dart';
import 'package:autowash_pro/presentation/providers/booking_provider.dart';
import 'package:autowash_pro/presentation/screens/vehicle/add_vehicle_screen.dart';
import 'package:autowash_pro/presentation/screens/booking/calendar_screen.dart';

class MyVehiclesScreen extends StatefulWidget {
  final bool isSelectionMode;
  final bool isFromServiceList;
  
  const MyVehiclesScreen({super.key, this.isSelectionMode = false, this.isFromServiceList = false});

  @override
  State<MyVehiclesScreen> createState() => _MyVehiclesScreenState();
}

class _MyVehiclesScreenState extends State<MyVehiclesScreen> {
  void _confirmDelete(BuildContext context, VehicleModel vehicle, BookingProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete Vehicle', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete vehicle ${vehicle.licensePlate}?', style: GoogleFonts.outfit()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.outfit(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await provider.deleteVehicle(vehicle.id);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vehicle deleted successfully!'), backgroundColor: AppTheme.success));
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Delete failed!'), backgroundColor: AppTheme.error));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: Text('Delete', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BookingProvider>(context, listen: false).loadVehicles();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isSelectionMode) {
      return _buildSelectionMode(context);
    }
    return _buildGarageMode(context);
  }

  Widget _buildGarageMode(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      appBar: AppBar(
        title: const Text('My Garage'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Manage your registered vehicles for quick booking and personalized service care.',
              style: GoogleFonts.outfit(fontSize: 14, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 20),
            
            // Search Bar
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10, offset: const Offset(0, 4))
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search your vehicles...',
                  hintStyle: GoogleFonts.outfit(color: AppTheme.textMuted),
                  prefixIcon: const Icon(Icons.search, color: AppTheme.textMuted),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 24),

            Consumer<BookingProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue));
                }

                if (provider.vehicles.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Column(
                        children: [
                          Icon(Icons.directions_car_rounded, size: 64, color: AppTheme.textMuted.withAlpha(100)),
                          const SizedBox(height: 16),
                          Text('No vehicles found', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const AddVehicleScreen()));
                            },
                            child: const Text('Add Vehicle'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Column(
                  children: provider.vehicles.map((v) => _buildGarageCard(v, provider)).toList(),
                );
              },
            ),
            
            const SizedBox(height: 16),
            
            // Loyalty Rewards Banner
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.pristineDark,
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.all(24),
              child: Stack(
                children: [
                  Positioned(
                    right: -20, top: -20,
                    child: Icon(Icons.star_rounded, size: 120, color: Colors.white.withAlpha(10)),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('LOYALTY REWARDS', style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white.withAlpha(200), letterSpacing: 1)),
                      const SizedBox(height: 8),
                      Text('Premium Member', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Progress to free wash', style: GoogleFonts.outfit(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold)),
                          Text('850 / 1000 pts', style: GoogleFonts.outfit(fontSize: 12, color: Colors.amber, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(30),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: 0.85,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryBlue,
        shape: const CircleBorder(),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AddVehicleScreen()));
        },
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildGarageCard(VehicleModel vehicle, BookingProvider provider) {
    final isCar = vehicle.vehicleType == 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 15, offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Simulated Vehicle Image
          Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isCar ? AppTheme.pristineNavy : const Color(0xFF2B5876),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            ),
            child: Stack(
              children: [
                if (vehicle.imageUrl != null)
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                      child: Image.network(vehicle.imageUrl!, fit: BoxFit.cover),
                    ),
                  )
                else
                  Positioned.fill(
                    child: Icon(
                      isCar ? Icons.directions_car_rounded : Icons.motorcycle_rounded,
                      size: 100,
                      color: Colors.white.withAlpha(30),
                    ),
                  ),
                Positioned(
                  top: 16, left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('PRIMARY', style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      vehicle.name?.isNotEmpty == true ? vehicle.name! : vehicle.vehicleTypeName,
                      style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.textSecondary),
                      onPressed: () {
                        provider.deleteVehicle(vehicle.id);
                      },
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(6)),
                      child: Text('ID: ${vehicle.licensePlate}${vehicle.color?.isNotEmpty == true ? ' • ${vehicle.color}' : ''}', style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
                    ),
                    const SizedBox(width: 8),
                    const CircleAvatar(radius: 3, backgroundColor: AppTheme.success),
                    const SizedBox(width: 4),
                    Text('Active Service Plan', style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textPrimary)),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Integrity Bar
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppTheme.scaffoldBg, borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Ceramic Coating Integrity', style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textPrimary)),
                          Text('94%', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: 0.94,
                        backgroundColor: Colors.white,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
                        borderRadius: BorderRadius.circular(4),
                        minHeight: 6,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                
                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppTheme.primaryBlue),
                          foregroundColor: AppTheme.primaryBlue,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Manage Asset'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          provider.selectVehicle(vehicle);
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const CalendarScreen()));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBlue,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                        ),
                        child: const Text('Book Service'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // === SELECTION MODE (Select Your Vehicle) ===
  Widget _buildSelectionMode(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      appBar: AppBar(
        title: const Text('Select Your Vehicle'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.pristineNavy),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.help_outline_rounded, color: AppTheme.pristineNavy), onPressed: () {}),
        ],
      ),
      body: Consumer<BookingProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              // Progress Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Step 1 of 4', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
                        Text('Vehicle Details', style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textSecondary)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: Container(height: 4, color: AppTheme.primaryBlue)),
                        Expanded(child: Container(height: 4, color: Colors.grey.shade300)),
                        Expanded(child: Container(height: 4, color: Colors.grey.shade300)),
                        Expanded(child: Container(height: 4, color: Colors.grey.shade300)),
                      ],
                    ),
                  ],
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Your Garage', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.pristineNavy)),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const AddVehicleScreen()));
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: AppTheme.accentLightBlue, borderRadius: BorderRadius.circular(20)),
                        child: Row(
                          children: [
                            const Icon(Icons.add, size: 14, color: AppTheme.primaryBlue),
                            const SizedBox(width: 4),
                            Text('Add New', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  physics: const BouncingScrollPhysics(),
                  itemCount: provider.vehicles.length,
                  itemBuilder: (context, index) {
                    final vehicle = provider.vehicles[index];
                    final isSelected = provider.selectedVehicle?.id == vehicle.id;
                    final isCar = vehicle.vehicleType == 0;
                    
                    return GestureDetector(
                      onTap: () {
                        provider.selectVehicle(vehicle);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: isSelected ? AppTheme.primaryBlue : Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10, offset: const Offset(0, 4))
                          ],
                        ),
                        child: Stack(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 120,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: isCar ? AppTheme.pristineNavy : const Color(0xFF2B5876),
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                                  ),
                                  child: vehicle.imageUrl != null
                                      ? ClipRRect(
                                          borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                                          child: Image.network(vehicle.imageUrl!, fit: BoxFit.cover),
                                        )
                                      : Icon(
                                          isCar ? Icons.directions_car_rounded : Icons.motorcycle_rounded,
                                          size: 60, color: Colors.white.withAlpha(40),
                                        ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(vehicle.name?.isNotEmpty == true ? vehicle.name! : vehicle.vehicleTypeName, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                                              Text('ID: ${vehicle.licensePlate}${vehicle.color?.isNotEmpty == true ? ' • ${vehicle.color}' : ''}', style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textSecondary)),
                                            ],
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.error),
                                            onPressed: () => _confirmDelete(context, vehicle, provider),
                                            tooltip: 'Delete Vehicle',
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                        decoration: BoxDecoration(color: AppTheme.scaffoldBg, borderRadius: BorderRadius.circular(8)),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.history, size: 14, color: AppTheme.primaryBlue),
                                            const SizedBox(width: 6),
                                            Text('Last Service: Oct 12, 2023', style: GoogleFonts.outfit(fontSize: 10, color: AppTheme.textSecondary)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (isSelected)
                              Positioned(
                                top: 12, right: 12,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(color: AppTheme.primaryBlue, shape: BoxShape.circle),
                                  child: const Icon(Icons.check, color: Colors.white, size: 16),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              // Bottom Floating Action Area
              if (provider.selectedVehicle != null)
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 20, offset: const Offset(0, -5))],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Selected', style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textSecondary)),
                          Text(provider.selectedVehicle!.licensePlate, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.pristineNavy)),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (widget.isFromServiceList) {
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const CalendarScreen()));
                          } else if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          } else {
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const CalendarScreen()));
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBlue,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Row(
                          children: [
                            Text('Confirm', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                            const SizedBox(width: 8),
                            const Icon(Icons.check_circle_rounded, size: 18, color: Colors.white),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
