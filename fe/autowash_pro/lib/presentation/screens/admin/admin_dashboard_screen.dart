import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:autowash_pro/core/theme/app_theme.dart';
import 'package:autowash_pro/presentation/providers/auth_provider.dart';
import 'package:autowash_pro/presentation/screens/auth/login_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _currentIndex = 0;
  bool _isLoading = false;
  Map<String, dynamic>? _stats;
  List<dynamic> _bookings = [];
  List<dynamic> _users = [];
  List<dynamic> _timeslots = [];
  List<dynamic> _rewards = [];
  List<dynamic> _services = [];
  List<dynamic> _staffList = [];
  List<dynamic> _chemicals = [];
  List<dynamic> _adminReviews = [];
  String? _error;

  // Search & Filter State
  String _selectedStatusFilter = 'All';
  final _bookingSearchController = TextEditingController();
  final _userSearchController = TextEditingController();

  // Segment toggles for lists
  String _userSubTab = 'Customer'; // Customer | Staff
  String _configSubTab = 'Services'; // Services | TimeSlots | Rewards | Reviews
  String _chemicalSubTab = 'Inventory'; // Inventory | LowStock | ServiceMap

  // Calendar & Pagination limits
  DateTime _selectedTimeSlotDate = DateTime.now();
  int _bookingsLimit = 10;
  int _usersLimit = 10;

  // Custom Calendar state
  DateTime _currentMonthDate = DateTime.now();
  bool _isCalendarExpanded = true;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  @override
  void dispose() {
    _bookingSearchController.dispose();
    _userSearchController.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final apiService = authProvider.apiService;

      final statsRes = await apiService.getAdminStats();
      final bookingsRes = await apiService.getAdminBookings();
      final usersRes = await apiService.getAdminUsers();
      final servicesRes = await apiService.getServices();
      final timeslotsRes = await apiService.getAdminTimeSlots();
      final rewardsRes = await apiService.getAdminRewards();
      final staffRes = await apiService.getStaffList();
      final chemicalsRes = await apiService.getChemicals();
      final reviewsRes = await apiService.getAdminReviews();

      if (mounted) {
        setState(() {
          _stats = statsRes['data'];
          _bookings = bookingsRes['data'] ?? [];
          _users = usersRes['data'] ?? [];
          _services = servicesRes['data'] ?? [];
          _timeslots = timeslotsRes['data'] ?? [];
          _rewards = rewardsRes['data'] ?? [];
          _staffList = staffRes['data'] ?? [];
          _chemicals = chemicalsRes['data'] ?? [];
          _adminReviews = reviewsRes['data'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateStatus(String bookingId, int statusValue) async {
    setState(() => _isLoading = true);
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.apiService.updateBookingStatus(bookingId, statusValue);
      await _loadAllData();
      _showSnackbar('Cập nhật trạng thái thành công!', AppTheme.success);
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackbar('Lỗi: $e', AppTheme.error);
    }
  }

  void _showSnackbar(String msg, Color bg) {
    if (!mounted) return;
    final cleanMsg = msg
        .replaceAll('Exception:', '')
        .replaceAll('Exception', '')
        .replaceAll('Lỗi:', '')
        .replaceAll('Lỗi', '')
        .trim();

    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 24,
        right: 24,
        width: 320,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: bg.withAlpha(80), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(15),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                )
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  bg == AppTheme.error ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
                  color: bg,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        bg == AppTheme.error ? 'LỖI HỆ THỐNG' : 'THÀNH CÔNG',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w900,
                          color: bg,
                          fontSize: 11,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        cleanMsg,
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    if (overlayEntry.mounted) {
                      overlayEntry.remove();
                    }
                  },
                  child: const Icon(Icons.close_rounded, size: 16, color: AppTheme.textMuted),
                )
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry);

    Future.delayed(const Duration(seconds: 4), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  String _formatCurrency(dynamic amount) {
    if (amount == null) return '0 VND';
    final parsed = double.tryParse(amount.toString()) ?? 0.0;
    final formatter = parsed.toStringAsFixed(0);
    final chars = formatter.split('');
    final buffer = StringBuffer();
    for (int i = 0; i < chars.length; i++) {
      if (i > 0 && (chars.length - i) % 3 == 0) buffer.write('.');
      buffer.write(chars[i]);
    }
    return '$buffer VND';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppTheme.textSecondary;
      case 'confirmed':
        return AppTheme.info;
      case 'inprogress':
        return AppTheme.warning;
      case 'completed':
        return AppTheme.success;
      case 'cancelled':
        return AppTheme.error;
      default:
        return AppTheme.textMuted;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Chờ xác nhận';
      case 'confirmed':
        return 'Đã xác nhận';
      case 'inprogress':
        return 'Đang rửa';
      case 'completed':
        return 'Hoàn thành';
      case 'cancelled':
        return 'Đã hủy';
      default:
        return status;
    }
  }

  // Filtered lists
  List<dynamic> get _filteredBookings {
    var list = _bookings;
    if (_selectedStatusFilter != 'All') {
      list = list.where((b) => (b['status']?.toString().toLowerCase() ?? '') == _selectedStatusFilter.toLowerCase()).toList();
    }
    final query = _bookingSearchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      list = list.where((b) {
        final plate = b['vehiclePlate']?.toString().toLowerCase() ?? '';
        final name = b['customerName']?.toString().toLowerCase() ?? '';
        final service = b['serviceName']?.toString().toLowerCase() ?? '';
        return plate.contains(query) || name.contains(query) || service.contains(query);
      }).toList();
    }
    return list;
  }

  List<dynamic> get _filteredUsers {
    var list = _users.where((u) {
      final role = u['role']?.toString().toLowerCase() ?? 'customer';
      return role == _userSubTab.toLowerCase();
    }).toList();

    final query = _userSearchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      list = list.where((u) {
        final name = u['fullName']?.toString().toLowerCase() ?? '';
        final email = u['email']?.toString().toLowerCase() ?? '';
        final phone = u['phone']?.toString().toLowerCase() ?? '';
        return name.contains(query) || email.contains(query) || phone.contains(query);
      }).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: Text(
          _getAppBarTitle(),
          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.pristineNavy, letterSpacing: 1),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppTheme.error),
            onPressed: () async {
              await auth.logout();
              if (context.mounted) {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadAllData,
        color: AppTheme.primaryBlue,
        child: _isLoading && _bookings.isEmpty
            ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue))
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_error != null)
                      Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: AppTheme.error.withAlpha(20),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.error.withAlpha(50)),
                        ),
                        child: Text(_error!, style: GoogleFonts.outfit(color: AppTheme.error, fontWeight: FontWeight.bold)),
                      ),
                    _buildCurrentTabContent(),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppTheme.primaryBlue,
        unselectedItemColor: AppTheme.textMuted,
        selectedLabelStyle: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold),
        unselectedLabelStyle: GoogleFonts.outfit(fontSize: 11),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Tổng quan'),
          BottomNavigationBarItem(icon: Icon(Icons.book_online_rounded), label: 'Đặt lịch'),
          BottomNavigationBarItem(icon: Icon(Icons.people_rounded), label: 'Thành viên'),
          BottomNavigationBarItem(icon: Icon(Icons.science_rounded), label: 'Hóa chất'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_suggest_rounded), label: 'Cấu hình'),
        ],
      ),
    );
  }

  String _getAppBarTitle() {
    switch (_currentIndex) {
      case 0:
        return 'TỔNG QUAN HỆ THỐNG';
      case 1:
        return 'QUẢN LÝ LỊCH ĐẶT';
      case 2:
        return 'QUẢN LÝ THÀNH VIÊN';
      case 3:
        return 'QUẢN LÝ HÓA CHẤT';
      case 4:
        return 'CẤU HÌNH HỆ THỐNG';
      default:
        return 'ADMIN DASHBOARD';
    }
  }

  Widget _buildCurrentTabContent() {
    switch (_currentIndex) {
      case 0:
        return _buildOverviewTab();
      case 1:
        return _buildBookingsTab();
      case 2:
        return _buildUsersTab();
      case 3:
        return _buildChemicalsTab();
      case 4:
        return _buildConfigTab();
      default:
        return const SizedBox.shrink();
    }
  }

  // ==================== TAB 0: OVERVIEW ====================
  Widget _buildOverviewTab() {
    final totalUsers = _stats?['totalUsers'] ?? 0;
    final totalBookings = _stats?['totalBookings'] ?? 0;
    final todayRevenue = _stats?['todayRevenue'] ?? 0;
    final pendingWashes = _stats?['pendingWashes'] ?? 0;

    final todayBookings = _bookings.where((b) {
      if (b['bookingDate'] == null) return false;
      final date = DateTime.tryParse(b['bookingDate'].toString());
      if (date == null) return false;
      final today = DateTime.now();
      return date.year == today.year && date.month == today.month && date.day == today.day;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 2.1,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: [
            _buildCompactStatCard(
              title: 'Doanh thu hôm nay',
              value: _formatCurrency(todayRevenue),
              icon: Icons.monetization_on_rounded,
              color: Colors.green,
            ),
            _buildCompactStatCard(
              title: 'Chờ rửa hôm nay',
              value: pendingWashes.toString(),
              icon: Icons.local_car_wash_rounded,
              color: AppTheme.primaryBlue,
            ),
            _buildCompactStatCard(
              title: 'Tổng khách hàng',
              value: totalUsers.toString(),
              icon: Icons.people_alt_rounded,
              color: Colors.indigo,
            ),
            _buildCompactStatCard(
              title: 'Tổng lịch đặt',
              value: totalBookings.toString(),
              icon: Icons.book_online_rounded,
              color: Colors.orange,
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'LỊCH RỬA XE HÔM NAY (${todayBookings.length})',
              style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textSecondary, letterSpacing: 0.5),
            ),
            TextButton(
              onPressed: () => setState(() => _currentIndex = 1),
              child: Text('Xem tất cả', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
            )
          ],
        ),
        const SizedBox(height: 8),
        if (todayBookings.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            alignment: Alignment.center,
            child: Text('Hôm nay chưa có lịch hẹn nào', style: GoogleFonts.outfit(color: AppTheme.textSecondary, fontSize: 13)),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: todayBookings.length > 5 ? 5 : todayBookings.length,
            itemBuilder: (context, index) {
              return _buildBookingCard(todayBookings[index]);
            },
          ),
      ],
    );
  }

  Widget _buildCompactStatCard({required String title, required String value, required IconData icon, required Color color}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(3), blurRadius: 8, offset: const Offset(0, 2))
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w900, color: AppTheme.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w500, color: AppTheme.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // ==================== TAB 1: BOOKINGS ====================
  Widget _buildBookingsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _bookingSearchController,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'Tìm theo biển số, khách hàng, gói dịch vụ...',
            prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.textMuted),
            suffixIcon: _bookingSearchController.text.isNotEmpty
                ? IconButton(icon: const Icon(Icons.clear_rounded), onPressed: () => setState(() => _bookingSearchController.clear()))
                : null,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryBlue)),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 38,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: [
              _buildFilterTab('All', 'Tất cả'),
              _buildFilterTab('Confirmed', 'Đã xác nhận'),
              _buildFilterTab('InProgress', 'Đang rửa'),
              _buildFilterTab('Completed', 'Hoàn thành'),
              _buildFilterTab('Cancelled', 'Đã hủy'),
              _buildFilterTab('Pending', 'Chờ duyệt'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (_filteredBookings.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40),
            alignment: Alignment.center,
            child: Text('Không tìm thấy lịch đặt nào phù hợp', style: GoogleFonts.outfit(color: AppTheme.textSecondary)),
          )
        else ...[
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _filteredBookings.length > _bookingsLimit ? _bookingsLimit : _filteredBookings.length,
            itemBuilder: (context, index) {
              return _buildBookingCard(_filteredBookings[index]);
            },
          ),
          if (_filteredBookings.length > _bookingsLimit)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: TextButton.icon(
                  onPressed: () => setState(() => _bookingsLimit += 10),
                  icon: const Icon(Icons.arrow_downward_rounded, size: 16),
                  label: Text('Xem thêm đơn đặt (${_filteredBookings.length - _bookingsLimit} đơn)', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                ),
              ),
            ),
        ]
      ],
    );
  }

  Widget _buildBookingCard(dynamic booking) {
    final String status = booking['status'] ?? 'Pending';
    final String bookingId = booking['id'];
    final String customerName = booking['customerName'] ?? '';
    final String customerEmail = booking['customerEmail'] ?? '';
    final String serviceName = booking['serviceName'] ?? '';
    final String vehiclePlate = booking['vehiclePlate'] ?? '';
    final String timeSlotDisplay = booking['timeSlotDisplay'] ?? '';
    final dynamic totalPrice = booking['totalPrice'] ?? 0;

    DateTime? bDate;
    if (booking['bookingDate'] != null) {
      bDate = DateTime.tryParse(booking['bookingDate'].toString());
    }
    final dateStr = bDate != null ? DateFormat('dd/MM/yyyy').format(bDate) : '';

    bool isTimeReached = true;
    if (bDate != null && timeSlotDisplay.contains('-')) {
      try {
        final startPart = timeSlotDisplay.split('-')[0].trim();
        final timeParts = startPart.split(':');
        final scheduledStart = DateTime(
          bDate.year,
          bDate.month,
          bDate.day,
          int.parse(timeParts[0]),
          int.parse(timeParts[1]),
        );
        isTimeReached = DateTime.now().isAfter(scheduledStart);
      } catch (_) {}
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(3), blurRadius: 6, offset: const Offset(0, 2))
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(customerName, style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                    Text(customerEmail, style: GoogleFonts.outfit(fontSize: 11, color: AppTheme.textSecondary)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(status).withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getStatusText(status),
                  style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w800, color: _getStatusColor(status)),
                ),
              ),
            ],
          ),
          const Divider(height: 20, thickness: 0.8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: AppTheme.accentLightBlue, borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.cleaning_services_rounded, color: AppTheme.primaryBlue, size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(serviceName, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                    Text('Biển số: $vehiclePlate', style: GoogleFonts.outfit(fontSize: 11, color: AppTheme.textSecondary)),
                  ],
                ),
              ),
              Text(
                _formatCurrency(totalPrice),
                style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w900, color: AppTheme.primaryBlue),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.calendar_today_rounded, size: 12, color: AppTheme.textSecondary),
              const SizedBox(width: 4),
              Text(dateStr, style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textSecondary)),
              const SizedBox(width: 12),
              const Icon(Icons.access_time_rounded, size: 12, color: AppTheme.textSecondary),
              const SizedBox(width: 4),
              Text(timeSlotDisplay, style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textSecondary)),
            ],
          ),
          // Staff assignment row
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.person_outline_rounded, size: 12, color: AppTheme.textSecondary),
              const SizedBox(width: 4),
              if (booking['staffName'] != null)
                Text('Thợ: ${booking['staffName']}', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.success))
              else if (booking['staffId'] != null)
                Text('Đã phân công', style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.success))
              else ...[
                Text('Chưa phân công', style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.warning)),
                const SizedBox(width: 8),
                if (status.toLowerCase() != 'completed' && status.toLowerCase() != 'cancelled')
                  GestureDetector(
                    onTap: () => _showAssignStaffDialog(bookingId),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withAlpha(15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppTheme.primaryBlue.withAlpha(40)),
                      ),
                      child: Text('Phân công', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.primaryBlue)),
                    ),
                  ),
              ],
            ],
          ),
          if (status.toLowerCase() != 'completed' && status.toLowerCase() != 'cancelled') ...[
            const Divider(height: 20, thickness: 0.8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (status.toLowerCase() == 'pending')
                  _buildActionButton(
                    label: 'Duyệt',
                    color: AppTheme.info,
                    onPressed: () => _updateStatus(bookingId, 1),
                  ),
                if (status.toLowerCase() == 'confirmed')
                  isTimeReached
                      ? _buildActionButton(
                          label: 'Bắt đầu',
                          color: AppTheme.warning,
                          onPressed: () => _updateStatus(bookingId, 2),
                        )
                      : _buildActionButton(
                          label: 'Chưa tới giờ',
                          color: Colors.grey.shade400,
                          textColor: Colors.white,
                          onPressed: null,
                        ),

                const SizedBox(width: 8),
                _buildActionButton(
                  label: 'Hủy đơn',
                  color: AppTheme.error.withAlpha(20),
                  textColor: AppTheme.error,
                  onPressed: () => _updateStatus(bookingId, 4),
                ),
              ],
            )
          ]
        ],
      ),
    );
  }

  // ==================== TAB 2: USERS & STAFF ====================
  Widget _buildUsersTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sub-tabs segment
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              Expanded(child: _buildSubTabButton('Customer', 'Khách hàng', _userSubTab == 'Customer', () => setState(() => _userSubTab = 'Customer'))),
              Expanded(child: _buildSubTabButton('Staff', 'Nhân viên', _userSubTab == 'Staff', () => setState(() => _userSubTab = 'Staff'))),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Action controls
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _userSearchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Tìm theo tên, email, SĐT...',
                  prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.textMuted),
                  suffixIcon: _userSearchController.text.isNotEmpty
                      ? IconButton(icon: const Icon(Icons.clear_rounded), onPressed: () => setState(() => _userSearchController.clear()))
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryBlue)),
                ),
              ),
            ),
            if (_userSubTab == 'Staff') ...[
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: _showCreateStaffDialog,
                icon: const Icon(Icons.person_add_rounded, size: 18, color: Colors.white),
                label: Text('Thêm thợ', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ]
          ],
        ),
        const SizedBox(height: 16),

        if (_filteredUsers.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40),
            alignment: Alignment.center,
            child: Text('Không tìm thấy người dùng nào', style: GoogleFonts.outfit(color: AppTheme.textSecondary)),
          )
        else ...[
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _filteredUsers.length > _usersLimit ? _usersLimit : _filteredUsers.length,
            itemBuilder: (context, index) {
              final user = _filteredUsers[index];
              return _buildUserCard(user);
            },
          ),
          if (_filteredUsers.length > _usersLimit)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: TextButton.icon(
                  onPressed: () => setState(() => _usersLimit += 10),
                  icon: const Icon(Icons.arrow_downward_rounded, size: 16),
                  label: Text('Xem thêm thành viên (${_filteredUsers.length - _usersLimit} người)', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                ),
              ),
            ),
        ]
      ],
    );
  }

  Widget _buildSubTabButton(String value, String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildUserCard(dynamic user) {
    final String fullName = user['fullName'] ?? 'Khách hàng';
    final String email = user['email'] ?? '';
    final String phone = user['phone'] ?? 'Không có SĐT';
    final String tier = user['tier'] ?? 'Member';
    final int points = user['loyaltyPoints'] ?? 0;
    final String role = user['role'] ?? 'Customer';

    DateTime? regDate;
    if (user['createdAt'] != null) {
      regDate = DateTime.tryParse(user['createdAt'].toString());
    }
    final regDateStr = regDate != null ? DateFormat('dd/MM/yyyy').format(regDate) : '';

    Color roleColor = Colors.grey;
    if (role.toLowerCase() == 'staff') roleColor = Colors.blueGrey;
    if (role.toLowerCase() == 'admin') roleColor = Colors.red;

    Color tierColor = Colors.grey;
    if (tier.toLowerCase() == 'silver') tierColor = Colors.blueGrey;
    if (tier.toLowerCase() == 'gold') tierColor = Colors.amber;
    if (tier.toLowerCase() == 'platinum') tierColor = Colors.purple;
    if (tier.toLowerCase() == 'vip') tierColor = Colors.redAccent;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(2), blurRadius: 6, offset: const Offset(0, 2))
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: (role.toLowerCase() == 'staff' ? Colors.blueGrey : AppTheme.primaryBlue).withAlpha(20),
            child: Text(
              fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U',
              style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: role.toLowerCase() == 'staff' ? Colors.blueGrey : AppTheme.primaryBlue),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(fullName, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                const SizedBox(height: 2),
                Text(email, style: GoogleFonts.outfit(fontSize: 11, color: AppTheme.textSecondary)),
                Text('SĐT: $phone', style: GoogleFonts.outfit(fontSize: 11, color: AppTheme.textSecondary)),
                const SizedBox(height: 4),
                Text('Đăng ký: $regDateStr', style: GoogleFonts.outfit(fontSize: 10, color: AppTheme.textMuted)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (role.toLowerCase() == 'staff')
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: roleColor.withAlpha(20), borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    'NHÂN VIÊN',
                    style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.w900, color: roleColor),
                  ),
                )
              else ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: tierColor.withAlpha(20), borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    tier.toUpperCase(),
                    style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.w900, color: tierColor),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                    const SizedBox(width: 2),
                    Text('$points đ', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                  ],
                ),
              ]
            ],
          )
        ],
      ),
    );
  }

  // Dialog to Create Staff Account
  void _showCreateStaffDialog() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Thêm nhân viên mới', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18)),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Họ và tên'),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Nhập họ tên' : null,
                ),
                TextFormField(
                  controller: emailCtrl,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Nhập email' : null,
                ),
                TextFormField(
                  controller: passCtrl,
                  decoration: const InputDecoration(labelText: 'Mật khẩu'),
                  obscureText: true,
                  validator: (v) => v == null || v.length < 6 ? 'Mật khẩu tối thiểu 6 ký tự' : null,
                ),
                TextFormField(
                  controller: phoneCtrl,
                  decoration: const InputDecoration(labelText: 'Số điện thoại'),
                  keyboardType: TextInputType.phone,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Nhập số điện thoại' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(ctx);
              setState(() => _isLoading = true);
              try {
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                await authProvider.apiService.createStaffAccount(
                  nameCtrl.text.trim(),
                  emailCtrl.text.trim(),
                  passCtrl.text,
                  phoneCtrl.text.trim(),
                );
                await _loadAllData();
                _showSnackbar('Tạo tài khoản nhân viên thành công!', AppTheme.success);
              } catch (e) {
                setState(() => _isLoading = false);
                _showSnackbar('Lỗi: $e', AppTheme.error);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue),
            child: const Text('Tạo', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ==================== TAB 3: SYSTEM CONFIGS ====================
  Widget _buildConfigTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sub-tabs segment
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              Expanded(child: _buildSubTabButton('Services', 'Dịch vụ', _configSubTab == 'Services', () => setState(() => _configSubTab = 'Services'))),
              Expanded(child: _buildSubTabButton('TimeSlots', 'Khung giờ', _configSubTab == 'TimeSlots', () => setState(() => _configSubTab = 'TimeSlots'))),
              Expanded(child: _buildSubTabButton('Rewards', 'Quà tặng', _configSubTab == 'Rewards', () => setState(() => _configSubTab = 'Rewards'))),
              Expanded(child: _buildSubTabButton('Reviews', 'Đánh giá', _configSubTab == 'Reviews', () => setState(() => _configSubTab = 'Reviews'))),
            ],
          ),
        ),
        const SizedBox(height: 16),

        if (_configSubTab != 'Reviews')
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _configSubTab == 'Services' ? 'GÓI DỊCH VỤ' : (_configSubTab == 'TimeSlots' ? 'LỊCH LÀM VIỆC' : 'QUÀ TẶNG ĐỔI ĐIỂM'),
                style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textSecondary, letterSpacing: 0.5),
              ),
              ElevatedButton.icon(
                onPressed: _handleAddNewConfig,
                icon: const Icon(Icons.add_rounded, size: 16, color: Colors.white),
                label: Text('Thêm mới', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        const SizedBox(height: 16),

        if (_configSubTab == 'TimeSlots') ...[
          _buildGridCalendar(),
        ],

        _buildConfigListContent(),
      ],
    );
  }

  Widget _buildConfigListContent() {
    if (_configSubTab == 'Services') {
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _services.length,
        itemBuilder: (context, index) => _buildServiceConfigCard(_services[index]),
      );
    } else if (_configSubTab == 'TimeSlots') {
      final filteredSlots = _timeslots.where((slot) {
        if (slot['date'] == null) return false;
        final sDate = DateTime.tryParse(slot['date'].toString());
        if (sDate == null) return false;
        return sDate.year == _selectedTimeSlotDate.year &&
            sDate.month == _selectedTimeSlotDate.month &&
            sDate.day == _selectedTimeSlotDate.day;
      }).toList();

      if (filteredSlots.isEmpty) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 40),
          alignment: Alignment.center,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Text('Không có khung giờ làm việc nào cho ngày này', style: GoogleFonts.outfit(color: AppTheme.textSecondary)),
        );
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: filteredSlots.length,
        itemBuilder: (context, index) => _buildTimeSlotConfigCard(filteredSlots[index]),
      );
    } else if (_configSubTab == 'Rewards') {
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _rewards.length,
        itemBuilder: (context, index) => _buildRewardConfigCard(_rewards[index]),
      );
    } else {
      return _buildAdminReviewsList();
    }
  }

  Widget _buildAdminReviewsList() {
    if (_adminReviews.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40),
        alignment: Alignment.center,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Text('Chưa có đánh giá nào', style: GoogleFonts.outfit(color: AppTheme.textSecondary)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('TẤT CẢ ĐÁNH GIÁ (${_adminReviews.length})', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textSecondary, letterSpacing: 0.5)),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _adminReviews.length,
          itemBuilder: (context, index) {
            final review = _adminReviews[index];
            final int rating = review['rating'] ?? 0;
            DateTime? dt;
            if (review['createdAt'] != null) dt = DateTime.tryParse(review['createdAt'].toString());

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(review['customerName'] ?? '', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                            Text(review['serviceName'] ?? '', style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textSecondary)),
                          ],
                        ),
                      ),
                      Row(
                        children: List.generate(5, (i) => Icon(
                          i < rating ? Icons.star_rounded : Icons.star_border_rounded,
                          color: Colors.amber,
                          size: 16,
                        )),
                      ),
                    ],
                  ),
                  if (review['comment'] != null && review['comment'].toString().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(review['comment'], style: GoogleFonts.outfit(fontSize: 13, color: AppTheme.textPrimary, height: 1.4)),
                  ],
                  if (dt != null) ...[
                    const SizedBox(height: 6),
                    Text(DateFormat('dd/MM/yyyy HH:mm').format(dt), style: GoogleFonts.outfit(fontSize: 10, color: AppTheme.textMuted)),
                  ],
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  void _handleAddNewConfig() {
    if (_configSubTab == 'Services') {
      _showServiceFormDialog(null);
    } else if (_configSubTab == 'TimeSlots') {
      _showTimeSlotFormDialog();
    } else {
      _showRewardFormDialog(null);
    }
  }

  // ==================== CONFIGS: SERVICES CRUD UI ====================
  Widget _buildServiceConfigCard(dynamic service) {
    final String id = service['id'];
    final String name = service['name'] ?? '';
    final String description = service['description'] ?? '';
    final dynamic price = service['price'] ?? 0;
    final int duration = service['durationMinutes'] ?? 0;
    final bool isActive = service['isActive'] ?? true;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppTheme.primaryBlue.withAlpha(10), borderRadius: BorderRadius.circular(10)),
            child: Icon(Icons.local_car_wash_rounded, color: isActive ? AppTheme.primaryBlue : Colors.grey, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: isActive ? AppTheme.textPrimary : Colors.grey)),
                Text('$duration phút • ${_formatCurrency(price)}', style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textSecondary)),
                Text(description, style: GoogleFonts.outfit(fontSize: 11, color: AppTheme.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          IconButton(icon: const Icon(Icons.edit_rounded, color: AppTheme.primaryBlue, size: 18), onPressed: () => _showServiceFormDialog(service)),
          IconButton(
            icon: Icon(isActive ? Icons.toggle_on_rounded : Icons.toggle_off_rounded, color: isActive ? Colors.green : Colors.grey, size: 24),
            onPressed: () => _toggleServiceActive(id, name, description, double.tryParse(price.toString()) ?? 0, duration, service['imageUrl'] ?? '', isActive),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleServiceActive(String id, String name, String desc, double price, int duration, String img, bool currentActive) async {
    setState(() => _isLoading = true);
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.apiService.updateService(id, name, desc, price, duration, img, !currentActive);
      await _loadAllData();
      _showSnackbar('Cập nhật trạng thái hoạt động dịch vụ thành công!', AppTheme.success);
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackbar('Lỗi: $e', AppTheme.error);
    }
  }

  void _showServiceFormDialog(dynamic existing) {
    final nameCtrl = TextEditingController(text: existing?['name']);
    final descCtrl = TextEditingController(text: existing?['description']);
    final priceCtrl = TextEditingController(text: existing?['price']?.toString());
    final durCtrl = TextEditingController(text: existing?['durationMinutes']?.toString());
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existing == null ? 'Thêm dịch vụ mới' : 'Cập nhật dịch vụ', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18)),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Tên dịch vụ'),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Nhập tên' : null,
                ),
                TextFormField(
                  controller: descCtrl,
                  decoration: const InputDecoration(labelText: 'Mô tả dịch vụ'),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Nhập mô tả' : null,
                ),
                TextFormField(
                  controller: priceCtrl,
                  decoration: const InputDecoration(labelText: 'Giá tiền (VND)'),
                  keyboardType: TextInputType.number,
                  validator: (v) => v == null || double.tryParse(v) == null || double.parse(v) <= 0 ? 'Giá phải > 0' : null,
                ),
                TextFormField(
                  controller: durCtrl,
                  decoration: const InputDecoration(labelText: 'Thời gian rửa (phút)'),
                  keyboardType: TextInputType.number,
                  validator: (v) => v == null || int.tryParse(v) == null || int.parse(v) <= 0 ? 'Thời lượng phải > 0' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(ctx);
              setState(() => _isLoading = true);
              try {
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                if (existing == null) {
                  await authProvider.apiService.createService(
                    nameCtrl.text.trim(),
                    descCtrl.text.trim(),
                    double.parse(priceCtrl.text),
                    int.parse(durCtrl.text),
                    '',
                  );
                } else {
                  await authProvider.apiService.updateService(
                    existing['id'],
                    nameCtrl.text.trim(),
                    descCtrl.text.trim(),
                    double.parse(priceCtrl.text),
                    int.parse(durCtrl.text),
                    existing['imageUrl'] ?? '',
                    existing['isActive'] ?? true,
                  );
                }
                await _loadAllData();
                _showSnackbar('Lưu dịch vụ thành công!', AppTheme.success);
              } catch (e) {
                setState(() => _isLoading = false);
                _showSnackbar('Lỗi: $e', AppTheme.error);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue),
            child: const Text('Lưu', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ==================== CONFIGS: TIMESLOTS CRUD UI ====================
  Widget _buildTimeSlotConfigCard(dynamic slot) {
    final String id = slot['id'];
    final String startTime = slot['startTime'] ?? '';
    final String endTime = slot['endTime'] ?? '';
    final int capacity = slot['maxCapacity'] ?? 0;
    final int bookingsCount = slot['bookingsCount'] ?? 0;
    
    DateTime? slotDate;
    if (slot['date'] != null) {
      slotDate = DateTime.tryParse(slot['date'].toString());
    }
    final dateStr = slotDate != null ? DateFormat('dd/MM/yyyy').format(slotDate) : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.orange.withAlpha(10), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.access_time_filled_rounded, color: Colors.orange, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$startTime - $endTime', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                Text('Ngày: $dateStr • Sức chứa: $bookingsCount/$capacity xe', style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textSecondary)),
              ],
            ),
          ),
          IconButton(icon: const Icon(Icons.edit_rounded, color: AppTheme.primaryBlue, size: 18), onPressed: () => _showTimeSlotEditDialog(id, startTime, endTime, capacity)),
          IconButton(
            icon: const Icon(Icons.delete_forever_rounded, color: AppTheme.error, size: 18),
            onPressed: () => _deleteTimeSlotConfirm(id, bookingsCount),
          ),
        ],
      ),
    );
  }

  void _showTimeSlotEditDialog(String id, String currentStart, String currentEnd, int currentCap) {
    final startCtrl = TextEditingController(text: currentStart);
    final endCtrl = TextEditingController(text: currentEnd);
    final capCtrl = TextEditingController(text: currentCap.toString());
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Cập nhật khung giờ', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18)),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: startCtrl,
                decoration: const InputDecoration(labelText: 'Giờ bắt đầu (hh:mm)'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Nhập giờ bắt đầu' : null,
              ),
              TextFormField(
                controller: endCtrl,
                decoration: const InputDecoration(labelText: 'Giờ kết thúc (hh:mm)'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Nhập giờ kết thúc' : null,
              ),
              TextFormField(
                controller: capCtrl,
                decoration: const InputDecoration(labelText: 'Số lượng xe tối đa'),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || int.tryParse(v) == null || int.parse(v) <= 0 ? 'Phải lớn hơn 0' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(ctx);
              setState(() => _isLoading = true);
              try {
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                await authProvider.apiService.updateTimeSlot(
                  id,
                  _selectedTimeSlotDate.toIso8601String(),
                  startCtrl.text.trim(),
                  endCtrl.text.trim(),
                  int.parse(capCtrl.text),
                );
                await _loadAllData();
                _showSnackbar('Cập nhật khung giờ thành công!', AppTheme.success);
              } catch (e) {
                setState(() => _isLoading = false);
                _showSnackbar('Lỗi: $e', AppTheme.error);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue),
            child: const Text('Lưu', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _deleteTimeSlotConfirm(String id, int bookingsCount) {
    if (bookingsCount > 0) {
      _showSnackbar('Không thể xóa khung giờ đã có xe đặt trước!', AppTheme.error);
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Xác nhận xóa', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18)),
        content: Text('Bạn có chắc chắn muốn xóa khung giờ làm việc này không?', style: GoogleFonts.outfit()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _isLoading = true);
              try {
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                await authProvider.apiService.deleteTimeSlot(id);
                await _loadAllData();
                _showSnackbar('Xóa khung giờ thành công!', AppTheme.success);
              } catch (e) {
                setState(() => _isLoading = false);
                _showSnackbar('Lỗi: $e', AppTheme.error);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showTimeSlotFormDialog() {
    DateTime selectedDate = _selectedTimeSlotDate;
    final startCtrl = TextEditingController(text: '08:00');
    final endCtrl = TextEditingController(text: '09:00');
    final capCtrl = TextEditingController(text: '3');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Tạo khung giờ làm việc', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18)),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text('Ngày: ${DateFormat('dd/MM/yyyy').format(selectedDate)}', style: GoogleFonts.outfit(fontSize: 14)),
                    trailing: const Icon(Icons.calendar_today_rounded, size: 18),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now().subtract(const Duration(days: 1)),
                        lastDate: DateTime.now().add(const Duration(days: 60)),
                      );
                      if (picked != null) {
                        setDialogState(() => selectedDate = picked);
                      }
                    },
                  ),
                  TextFormField(
                    controller: startCtrl,
                    decoration: const InputDecoration(labelText: 'Giờ bắt đầu (hh:mm)'),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Nhập giờ bắt đầu' : null,
                  ),
                  TextFormField(
                    controller: endCtrl,
                    decoration: const InputDecoration(labelText: 'Giờ kết thúc (hh:mm)'),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Nhập giờ kết thúc' : null,
                  ),
                  TextFormField(
                    controller: capCtrl,
                    decoration: const InputDecoration(labelText: 'Sức chứa xe'),
                    keyboardType: TextInputType.number,
                    validator: (v) => v == null || int.tryParse(v) == null || int.parse(v) <= 0 ? 'Phải lớn hơn 0' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                Navigator.pop(ctx);
                setState(() => _isLoading = true);
                try {
                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                  await authProvider.apiService.createTimeSlot(
                    selectedDate.toIso8601String(),
                    startCtrl.text.trim(),
                    endCtrl.text.trim(),
                    int.parse(capCtrl.text),
                  );
                  await _loadAllData();
                  _showSnackbar('Tạo khung giờ thành công!', AppTheme.success);
                } catch (e) {
                  setState(() => _isLoading = false);
                  _showSnackbar('Lỗi: $e', AppTheme.error);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue),
              child: const Text('Tạo', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== CONFIGS: REWARDS CRUD UI ====================
  Widget _buildRewardConfigCard(dynamic reward) {
    final String id = reward['id'];
    final String name = reward['name'] ?? '';
    final String description = reward['description'] ?? '';
    final int cost = reward['pointsCost'] ?? 0;
    final dynamic discountVal = reward['discountValue'] ?? 0;
    final int typeVal = reward['type'] ?? 0;
    final bool isActive = reward['isActive'] ?? true;

    String typeStr = 'Giảm giá';
    if (typeVal == 1) typeStr = 'Rửa miễn phí';
    if (typeVal == 2) typeStr = 'Quà tặng kèm';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.teal.withAlpha(10), borderRadius: BorderRadius.circular(10)),
            child: Icon(Icons.redeem_rounded, color: isActive ? Colors.teal : Colors.grey, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: isActive ? AppTheme.textPrimary : Colors.grey)),
                Text('$cost điểm • Loai: $typeStr • Trị giá: ${_formatCurrency(discountVal)}', style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textSecondary)),
                Text(description, style: GoogleFonts.outfit(fontSize: 11, color: AppTheme.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          IconButton(icon: const Icon(Icons.edit_rounded, color: AppTheme.primaryBlue, size: 18), onPressed: () => _showRewardFormDialog(reward)),
          IconButton(
            icon: Icon(isActive ? Icons.toggle_on_rounded : Icons.toggle_off_rounded, color: isActive ? Colors.green : Colors.grey, size: 24),
            onPressed: () => _toggleRewardActive(id, name, description, typeVal, cost, double.tryParse(discountVal.toString()) ?? 0, reward['imageUrl'] ?? '', isActive),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleRewardActive(String id, String name, String desc, int type, int cost, double discount, String img, bool currentActive) async {
    setState(() => _isLoading = true);
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.apiService.updateReward(id, name, desc, type, cost, discount, img, !currentActive);
      await _loadAllData();
      _showSnackbar('Cập nhật trạng thái phần thưởng thành công!', AppTheme.success);
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackbar('Lỗi: $e', AppTheme.error);
    }
  }

  void _showRewardFormDialog(dynamic existing) {
    final nameCtrl = TextEditingController(text: existing?['name']);
    final descCtrl = TextEditingController(text: existing?['description']);
    final costCtrl = TextEditingController(text: existing?['pointsCost']?.toString());
    final discountCtrl = TextEditingController(text: existing?['discountValue']?.toString());
    int selectedType = existing?['type'] ?? 0;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(existing == null ? 'Tạo quà tặng mới' : 'Cập nhật quà tặng', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18)),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Tên quà tặng/Voucher'),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Nhập tên' : null,
                  ),
                  TextFormField(
                    controller: descCtrl,
                    decoration: const InputDecoration(labelText: 'Mô tả chi tiết'),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Nhập mô tả' : null,
                  ),
                  DropdownButtonFormField<int>(
                    initialValue: selectedType,
                    decoration: const InputDecoration(labelText: 'Loại quà tặng'),
                    items: const [
                      DropdownMenuItem(value: 0, child: Text('Giảm giá hóa đơn (VND)')),
                      DropdownMenuItem(value: 1, child: Text('Rửa miễn phí')),
                      DropdownMenuItem(value: 2, child: Text('Quà tặng kèm vật lý')),
                    ],
                    onChanged: (v) {
                      if (v != null) setDialogState(() => selectedType = v);
                    },
                  ),
                  TextFormField(
                    controller: costCtrl,
                    decoration: const InputDecoration(labelText: 'Số điểm cần đổi'),
                    keyboardType: TextInputType.number,
                    validator: (v) => v == null || int.tryParse(v) == null || int.parse(v) < 0 ? 'Điểm phải >= 0' : null,
                  ),
                  TextFormField(
                    controller: discountCtrl,
                    decoration: const InputDecoration(labelText: 'Trị giá chiết khấu (VND)'),
                    keyboardType: TextInputType.number,
                    validator: (v) => v == null || double.tryParse(v) == null || double.parse(v) < 0 ? 'Giá trị phải >= 0' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                Navigator.pop(ctx);
                setState(() => _isLoading = true);
                try {
                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                  if (existing == null) {
                    await authProvider.apiService.createReward(
                      nameCtrl.text.trim(),
                      descCtrl.text.trim(),
                      selectedType,
                      int.parse(costCtrl.text),
                      double.parse(discountCtrl.text),
                      '',
                    );
                  } else {
                    await authProvider.apiService.updateReward(
                      existing['id'],
                      nameCtrl.text.trim(),
                      descCtrl.text.trim(),
                      selectedType,
                      int.parse(costCtrl.text),
                      double.parse(discountCtrl.text),
                      existing['imageUrl'] ?? '',
                      existing['isActive'] ?? true,
                    );
                  }
                  await _loadAllData();
                  _showSnackbar('Lưu quà tặng thành công!', AppTheme.success);
                } catch (e) {
                  setState(() => _isLoading = false);
                  _showSnackbar('Lỗi: $e', AppTheme.error);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue),
              child: const Text('Lưu', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showAssignStaffDialog(String bookingId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Phân công nhân viên', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18)),
        content: SizedBox(
          width: double.maxFinite,
          child: _staffList.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text('Chưa có nhân viên nào', style: GoogleFonts.outfit(color: AppTheme.textSecondary)),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: _staffList.length,
                  itemBuilder: (context, index) {
                    final staff = _staffList[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.primaryBlue.withAlpha(20),
                        child: Text(
                          (staff['fullName'] ?? 'S')[0].toUpperCase(),
                          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                        ),
                      ),
                      title: Text(staff['fullName'] ?? '', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: Text(staff['phone'] ?? '', style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textSecondary)),
                      onTap: () {
                        Navigator.pop(ctx);
                        _assignStaff(bookingId, staff['id']);
                      },
                    );
                  },
                ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
        ],
      ),
    );
  }

  Future<void> _assignStaff(String bookingId, String staffId) async {
    setState(() => _isLoading = true);
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.apiService.assignStaffToBooking(bookingId, staffId);
      await _loadAllData();
      _showSnackbar('Phân công nhân viên thành công!', AppTheme.success);
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackbar('Lỗi: $e', AppTheme.error);
    }
  }

  Widget _buildFilterTab(String filterValue, String label) {
    final isSelected = _selectedStatusFilter == filterValue;
    return GestureDetector(
      onTap: () => setState(() => _selectedStatusFilter = filterValue),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppTheme.primaryBlue : Colors.grey.shade200),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({required String label, required Color color, Color? textColor, VoidCallback? onPressed}) {
    final bool isOutline = textColor != null;
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isOutline ? color : color,
        foregroundColor: isOutline ? textColor : Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        minimumSize: const Size(50, 30),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(label, style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  // ==================== TAB 3: CHEMICALS ====================
  Widget _buildChemicalsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sub-tabs
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              Expanded(child: _buildSubTabButton('Inventory', 'Kho hàng', _chemicalSubTab == 'Inventory', () => setState(() => _chemicalSubTab = 'Inventory'))),
              Expanded(child: _buildSubTabButton('LowStock', 'Sắp hết', _chemicalSubTab == 'LowStock', () => setState(() => _chemicalSubTab = 'LowStock'))),
              Expanded(child: _buildSubTabButton('ServiceMap', 'Dịch vụ', _chemicalSubTab == 'ServiceMap', () => setState(() => _chemicalSubTab = 'ServiceMap'))),
            ],
          ),
        ),
        const SizedBox(height: 16),

        if (_chemicalSubTab == 'Inventory' || _chemicalSubTab == 'LowStock') ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _chemicalSubTab == 'Inventory' ? 'TẤT CẢ HÓA CHẤT' : 'HÓA CHẤT SẮP HẾT',
                style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textSecondary, letterSpacing: 0.5),
              ),
              if (_chemicalSubTab == 'Inventory')
                ElevatedButton.icon(
                  onPressed: _showCreateChemicalDialog,
                  icon: const Icon(Icons.add_rounded, size: 16, color: Colors.white),
                  label: Text('Thêm mới', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          _buildChemicalList(),
        ],

        if (_chemicalSubTab == 'ServiceMap') ...[
          Text('LIÊN KẾT HÓA CHẤT - DỊCH VỤ', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textSecondary, letterSpacing: 0.5)),
          const SizedBox(height: 12),
          _buildServiceChemicalMapping(),
        ],
      ],
    );
  }

  Widget _buildChemicalList() {
    final list = _chemicalSubTab == 'LowStock'
        ? _chemicals.where((c) => c['isLowStock'] == true).toList()
        : _chemicals;

    if (list.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40),
        alignment: Alignment.center,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Text(
          _chemicalSubTab == 'LowStock' ? 'Không có hóa chất nào sắp hết' : 'Chưa có hóa chất nào',
          style: GoogleFonts.outfit(color: AppTheme.textSecondary),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final c = list[index];
        final bool isLow = c['isLowStock'] == true;
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: isLow ? Border.all(color: AppTheme.error.withAlpha(40), width: 1.5) : null,
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (isLow ? AppTheme.error : Colors.teal).withAlpha(15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.science_rounded, color: isLow ? AppTheme.error : Colors.teal, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            c['name'] ?? '',
                            style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isLow) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: AppTheme.error.withAlpha(20), borderRadius: BorderRadius.circular(4)),
                            child: Text('SẮP HẾT', style: GoogleFonts.outfit(fontSize: 8, fontWeight: FontWeight.w900, color: AppTheme.error)),
                          ),
                        ]
                      ],
                    ),
                    Text('Tồn kho: ${_formatStock(c['currentStock'])} ${c['unit']} • Tối thiểu: ${_formatStock(c['minimumStock'])} ${c['unit']}',
                        style: GoogleFonts.outfit(fontSize: 11, color: AppTheme.textSecondary)),
                  ],
                ),
              ),
              IconButton(icon: const Icon(Icons.edit_rounded, color: AppTheme.primaryBlue, size: 16), onPressed: () => _showEditChemicalDialog(c)),
              IconButton(icon: const Icon(Icons.add_circle_outline_rounded, color: Colors.teal, size: 16), onPressed: () => _showRestockDialog(c['id'])),
              IconButton(icon: const Icon(Icons.history_rounded, color: Colors.blueGrey, size: 16), onPressed: () => _showChemicalLogsDialog(c['id'], c['name'] ?? '')),
            ],
          ),
        );
      },
    );
  }

  String _formatStock(dynamic val) {
    if (val == null) return '0';
    final d = double.tryParse(val.toString()) ?? 0;
    return d == d.truncateToDouble() ? d.toInt().toString() : d.toStringAsFixed(1);
  }

  Widget _buildServiceChemicalMapping() {
    if (_services.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40),
        alignment: Alignment.center,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Text('Chưa có dịch vụ nào', style: GoogleFonts.outfit(color: AppTheme.textSecondary)),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _services.length,
      itemBuilder: (context, index) {
        final svc = _services[index];
        final serviceId = svc['id'];
        final serviceName = svc['name'] ?? '';

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(serviceName, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                  GestureDetector(
                    onTap: () => _showAddServiceChemicalDialog(serviceId),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: AppTheme.primaryBlue.withAlpha(15), borderRadius: BorderRadius.circular(6)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.add_rounded, size: 14, color: AppTheme.primaryBlue),
                          const SizedBox(width: 2),
                          Text('Thêm', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              FutureBuilder<Map<String, dynamic>>(
                future: Provider.of<AuthProvider>(context, listen: false).apiService.getServiceChemicals(serviceId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(padding: EdgeInsets.all(8), child: Center(child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))));
                  }
                  if (!snapshot.hasData || snapshot.data!['data'] == null || (snapshot.data!['data'] as List).isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 4),
                      child: Text('Chưa có hóa chất nào', style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textMuted)),
                    );
                  }
                  final scList = snapshot.data!['data'] as List;
                  return Column(
                    children: scList.map<Widget>((sc) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.circle, size: 6, color: Colors.teal),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text('${sc['chemicalName']} - ${_formatStock(sc['quantityPerWash'])} ${sc['unit']}/lần rửa',
                                  style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textPrimary)),
                            ),
                            GestureDetector(
                              onTap: () => _showEditServiceChemicalDialog(sc),
                              child: const Icon(Icons.edit_rounded, size: 14, color: AppTheme.primaryBlue),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => _deleteServiceChemical(sc['id']),
                              child: const Icon(Icons.delete_outline_rounded, size: 14, color: AppTheme.error),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ==================== CHEMICAL DIALOGS ====================
  void _showCreateChemicalDialog() {
    final nameCtrl = TextEditingController();
    final unitCtrl = TextEditingController();
    final stockCtrl = TextEditingController();
    final minCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Thêm hóa chất mới', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18)),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Tên hóa chất'), validator: (v) => v == null || v.trim().isEmpty ? 'Nhập tên' : null),
                TextFormField(controller: unitCtrl, decoration: const InputDecoration(labelText: 'Đơn vị (lít, ml, kg...)'), validator: (v) => v == null || v.trim().isEmpty ? 'Nhập đơn vị' : null),
                TextFormField(controller: stockCtrl, decoration: const InputDecoration(labelText: 'Số lượng hiện có'), keyboardType: TextInputType.number, validator: (v) => v == null || double.tryParse(v) == null ? 'Nhập số hợp lệ' : null),
                TextFormField(controller: minCtrl, decoration: const InputDecoration(labelText: 'Mức tối thiểu'), keyboardType: TextInputType.number, validator: (v) => v == null || double.tryParse(v) == null ? 'Nhập số hợp lệ' : null),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(ctx);
              setState(() => _isLoading = true);
              try {
                final api = Provider.of<AuthProvider>(context, listen: false).apiService;
                await api.createChemical(nameCtrl.text.trim(), unitCtrl.text.trim(), double.parse(stockCtrl.text), double.parse(minCtrl.text));
                await _loadAllData();
                _showSnackbar('Thêm hóa chất thành công!', AppTheme.success);
              } catch (e) {
                setState(() => _isLoading = false);
                _showSnackbar('Lỗi: $e', AppTheme.error);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue),
            child: const Text('Tạo', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditChemicalDialog(dynamic chemical) {
    final nameCtrl = TextEditingController(text: chemical['name']);
    final unitCtrl = TextEditingController(text: chemical['unit']);
    final minCtrl = TextEditingController(text: chemical['minimumStock']?.toString());
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Cập nhật hóa chất', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18)),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Tên hóa chất'), validator: (v) => v == null || v.trim().isEmpty ? 'Nhập tên' : null),
              TextFormField(controller: unitCtrl, decoration: const InputDecoration(labelText: 'Đơn vị'), validator: (v) => v == null || v.trim().isEmpty ? 'Nhập đơn vị' : null),
              TextFormField(controller: minCtrl, decoration: const InputDecoration(labelText: 'Mức tối thiểu'), keyboardType: TextInputType.number, validator: (v) => v == null || double.tryParse(v) == null ? 'Nhập số hợp lệ' : null),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(ctx);
              setState(() => _isLoading = true);
              try {
                final api = Provider.of<AuthProvider>(context, listen: false).apiService;
                await api.updateChemical(chemical['id'], nameCtrl.text.trim(), unitCtrl.text.trim(), double.parse(minCtrl.text));
                await _loadAllData();
                _showSnackbar('Cập nhật hóa chất thành công!', AppTheme.success);
              } catch (e) {
                setState(() => _isLoading = false);
                _showSnackbar('Lỗi: $e', AppTheme.error);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue),
            child: const Text('Lưu', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showRestockDialog(String chemicalId) {
    final amountCtrl = TextEditingController();
    final reasonCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Nhập thêm hóa chất', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18)),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(controller: amountCtrl, decoration: const InputDecoration(labelText: 'Số lượng nhập'), keyboardType: TextInputType.number, validator: (v) => v == null || (double.tryParse(v) ?? 0) <= 0 ? 'Phải > 0' : null),
              TextFormField(controller: reasonCtrl, decoration: const InputDecoration(labelText: 'Lý do (tùy chọn)')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(ctx);
              setState(() => _isLoading = true);
              try {
                final api = Provider.of<AuthProvider>(context, listen: false).apiService;
                await api.restockChemical(chemicalId, double.parse(amountCtrl.text), reasonCtrl.text.trim().isEmpty ? null : reasonCtrl.text.trim());
                await _loadAllData();
                _showSnackbar('Nhập thêm hóa chất thành công!', AppTheme.success);
              } catch (e) {
                setState(() => _isLoading = false);
                _showSnackbar('Lỗi: $e', AppTheme.error);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            child: const Text('Nhập kho', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showChemicalLogsDialog(String chemicalId, String chemicalName) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Lịch sử: $chemicalName', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: FutureBuilder<Map<String, dynamic>>(
            future: Provider.of<AuthProvider>(context, listen: false).apiService.getChemicalLogs(chemicalId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue));
              }
              if (!snapshot.hasData || snapshot.data!['data'] == null || (snapshot.data!['data'] as List).isEmpty) {
                return Center(child: Text('Chưa có lịch sử', style: GoogleFonts.outfit(color: AppTheme.textSecondary)));
              }
              final logs = snapshot.data!['data'] as List;
              return ListView.builder(
                itemCount: logs.length,
                itemBuilder: (context, index) {
                  final log = logs[index];
                  final amount = (log['changeAmount'] ?? 0).toDouble();
                  final isPositive = amount > 0;
                  DateTime? dt;
                  if (log['createdAt'] != null) dt = DateTime.tryParse(log['createdAt'].toString());

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: (isPositive ? Colors.teal : AppTheme.error).withAlpha(8),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: (isPositive ? Colors.teal : AppTheme.error).withAlpha(30)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isPositive ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                          size: 16,
                          color: isPositive ? Colors.teal : AppTheme.error,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${isPositive ? '+' : ''}${_formatStock(amount)}',
                                style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: isPositive ? Colors.teal : AppTheme.error),
                              ),
                              Text(log['reason'] ?? '', style: GoogleFonts.outfit(fontSize: 11, color: AppTheme.textSecondary)),
                            ],
                          ),
                        ),
                        if (dt != null) Text(DateFormat('dd/MM HH:mm').format(dt), style: GoogleFonts.outfit(fontSize: 10, color: AppTheme.textMuted)),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Đóng')),
        ],
      ),
    );
  }

  void _showAddServiceChemicalDialog(String serviceId) {
    String? selectedChemicalId;
    final qtyCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Thêm hóa chất cho dịch vụ', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Chọn hóa chất'),
                  value: selectedChemicalId,
                  items: _chemicals.map<DropdownMenuItem<String>>((c) {
                    return DropdownMenuItem(value: c['id'] as String, child: Text('${c['name']} (${c['unit']})'));
                  }).toList(),
                  onChanged: (v) => setDialogState(() => selectedChemicalId = v),
                  validator: (v) => v == null ? 'Chọn hóa chất' : null,
                ),
                TextFormField(controller: qtyCtrl, decoration: const InputDecoration(labelText: 'Lượng dùng mỗi lần rửa'), keyboardType: TextInputType.number, validator: (v) => v == null || (double.tryParse(v) ?? 0) <= 0 ? 'Phải > 0' : null),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                Navigator.pop(ctx);
                setState(() => _isLoading = true);
                try {
                  final api = Provider.of<AuthProvider>(context, listen: false).apiService;
                  await api.addServiceChemical(serviceId, selectedChemicalId!, double.parse(qtyCtrl.text));
                  await _loadAllData();
                  _showSnackbar('Gán hóa chất cho dịch vụ thành công!', AppTheme.success);
                } catch (e) {
                  setState(() => _isLoading = false);
                  _showSnackbar('Lỗi: $e', AppTheme.error);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue),
              child: const Text('Thêm', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditServiceChemicalDialog(dynamic sc) {
    final qtyCtrl = TextEditingController(text: sc['quantityPerWash']?.toString());
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Cập nhật lượng hóa chất', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Hóa chất: ${sc['chemicalName']}', style: GoogleFonts.outfit(fontSize: 14, color: AppTheme.textSecondary)),
              const SizedBox(height: 8),
              TextFormField(controller: qtyCtrl, decoration: const InputDecoration(labelText: 'Lượng dùng mỗi lần rửa'), keyboardType: TextInputType.number, validator: (v) => v == null || (double.tryParse(v) ?? 0) <= 0 ? 'Phải > 0' : null),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(ctx);
              setState(() => _isLoading = true);
              try {
                final api = Provider.of<AuthProvider>(context, listen: false).apiService;
                await api.updateServiceChemical(sc['id'], double.parse(qtyCtrl.text));
                await _loadAllData();
                _showSnackbar('Cập nhật thành công!', AppTheme.success);
              } catch (e) {
                setState(() => _isLoading = false);
                _showSnackbar('Lỗi: $e', AppTheme.error);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue),
            child: const Text('Lưu', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteServiceChemical(String id) async {
    setState(() => _isLoading = true);
    try {
      final api = Provider.of<AuthProvider>(context, listen: false).apiService;
      await api.deleteServiceChemical(id);
      await _loadAllData();
      _showSnackbar('Xóa liên kết hóa chất thành công!', AppTheme.success);
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackbar('Lỗi: $e', AppTheme.error);
    }
  }

  List<DateTime> _generateCalendarDays() {
    final firstDayOfMonth = DateTime(_currentMonthDate.year, _currentMonthDate.month, 1);
    final int firstWeekday = firstDayOfMonth.weekday; // Mon = 1, Sun = 7
    final DateTime startGridDate = firstDayOfMonth.subtract(Duration(days: firstWeekday - 1));

    final List<DateTime> days = [];
    for (int i = 0; i < 42; i++) {
      days.add(startGridDate.add(Duration(days: i)));
    }
    return days;
  }

  List<DateTime> _generateCollapsedWeekDays() {
    final int weekday = _selectedTimeSlotDate.weekday; // Mon = 1, Sun = 7
    final DateTime monday = _selectedTimeSlotDate.subtract(Duration(days: weekday - 1));
    final List<DateTime> days = [];
    for (int i = 0; i < 7; i++) {
      days.add(monday.add(Duration(days: i)));
    }
    return days;
  }

  Widget _buildCalendarHeaderRow() {
    final headers = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1.5),
        ),
      ),
      child: Row(
        children: headers.map((day) => Expanded(
          child: Center(
            child: Text(
              day,
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w900,
                color: AppTheme.pristineNavy,
                fontSize: 12,
              ),
            ),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildGridCalendar() {
    final List<DateTime> days = _isCalendarExpanded ? _generateCalendarDays() : _generateCollapsedWeekDays();
    final monthStr = DateFormat('MM / yyyy').format(_currentMonthDate);

    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          // Month navigation header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tháng $monthStr',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.pristineNavy,
                    fontSize: 15,
                  ),
                ),
                Row(
                  children: [
                    if (_isCalendarExpanded) ...[
                      IconButton(
                        icon: const Icon(Icons.chevron_left_rounded, size: 20),
                        onPressed: () {
                          setState(() {
                            _currentMonthDate = DateTime(_currentMonthDate.year, _currentMonthDate.month - 1, 1);
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right_rounded, size: 20),
                        onPressed: () {
                          setState(() {
                            _currentMonthDate = DateTime(_currentMonthDate.year, _currentMonthDate.month + 1, 1);
                          });
                        },
                      ),
                    ],
                    IconButton(
                      icon: Icon(
                        _isCalendarExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                        color: AppTheme.primaryBlue,
                        size: 22,
                      ),
                      onPressed: () => setState(() => _isCalendarExpanded = !_isCalendarExpanded),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Day-of-week headers
          _buildCalendarHeaderRow(),
          
          // Days grid
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1.2,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: days.length,
              itemBuilder: (context, index) {
                final date = days[index];
                final isSelected = date.year == _selectedTimeSlotDate.year &&
                    date.month == _selectedTimeSlotDate.month &&
                    date.day == _selectedTimeSlotDate.day;
                final isCurrentMonth = date.month == _currentMonthDate.month;
                final isToday = date.year == DateTime.now().year &&
                    date.month == DateTime.now().month &&
                    date.day == DateTime.now().day;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTimeSlotDate = date;
                      if (date.month != _currentMonthDate.month) {
                        _currentMonthDate = DateTime(date.year, date.month, 1);
                      }
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primaryBlue
                          : (isToday ? AppTheme.primaryBlue.withAlpha(20) : Colors.transparent),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      date.day.toString(),
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : (isCurrentMonth
                                ? (isToday ? AppTheme.primaryBlue : AppTheme.textPrimary)
                                : AppTheme.textMuted),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
