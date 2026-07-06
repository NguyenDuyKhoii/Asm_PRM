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
  List<dynamic> _services = [];
  String? _error;

  // Search & Filter State
  String _selectedStatusFilter = 'All';
  final _bookingSearchController = TextEditingController();
  final _userSearchController = TextEditingController();

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

      if (mounted) {
        setState(() {
          _stats = statsRes['data'];
          _bookings = bookingsRes['data'] ?? [];
          _users = usersRes['data'] ?? [];
          _services = servicesRes['data'] ?? [];
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật trạng thái thành công!'), backgroundColor: AppTheme.success),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: AppTheme.error),
        );
      }
    }
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

  // Filtered lists based on search/filters
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
    var list = _users;
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
          BottomNavigationBarItem(icon: Icon(Icons.people_rounded), label: 'Khách hàng'),
          BottomNavigationBarItem(icon: Icon(Icons.design_services_rounded), label: 'Dịch vụ'),
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
        return 'QUẢN LÝ KHÁCH HÀNG';
      case 3:
        return 'DANH MỤC DỊCH VỤ';
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
        return _buildServicesTab();
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

    // Filter today's queue
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
        // KPI Stats Grid (Row-based compact design)
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

        // Today's Wash Queue Header
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
        // Search Bar
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

        // Filter Tabs
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
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _filteredBookings.length,
            itemBuilder: (context, index) {
              return _buildBookingCard(_filteredBookings[index]);
            },
          ),
      ],
    );
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
                  _buildActionButton(
                    label: 'Bắt đầu',
                    color: AppTheme.warning,
                    onPressed: () => _updateStatus(bookingId, 2),
                  ),
                if (status.toLowerCase() == 'inprogress')
                  _buildActionButton(
                    label: 'Hoàn thành',
                    color: AppTheme.success,
                    onPressed: () => _updateStatus(bookingId, 3),
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

  Widget _buildActionButton({required String label, required Color color, Color? textColor, required VoidCallback onPressed}) {
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

  // ==================== TAB 2: USERS ====================
  Widget _buildUsersTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // User Search Bar
        TextField(
          controller: _userSearchController,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'Tìm khách hàng theo tên, email, SĐT...',
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
        const SizedBox(height: 16),

        if (_filteredUsers.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40),
            alignment: Alignment.center,
            child: Text('Không tìm thấy khách hàng nào', style: GoogleFonts.outfit(color: AppTheme.textSecondary)),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _filteredUsers.length,
            itemBuilder: (context, index) {
              final user = _filteredUsers[index];
              return _buildUserCard(user);
            },
          ),
      ],
    );
  }

  Widget _buildUserCard(dynamic user) {
    final String fullName = user['fullName'] ?? 'Khách hàng';
    final String email = user['email'] ?? '';
    final String phone = user['phone'] ?? 'Không có SĐT';
    final String tier = user['tier'] ?? 'Member';
    final int points = user['loyaltyPoints'] ?? 0;

    DateTime? regDate;
    if (user['createdAt'] != null) {
      regDate = DateTime.tryParse(user['createdAt'].toString());
    }
    final regDateStr = regDate != null ? DateFormat('dd/MM/yyyy').format(regDate) : '';

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
          // Initial Circle Avatar
          CircleAvatar(
            radius: 22,
            backgroundColor: AppTheme.primaryBlue.withAlpha(20),
            child: Text(
              fullName.isNotEmpty ? fullName[0].toUpperCase() : 'C',
              style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
            ),
          ),
          const SizedBox(width: 14),

          // User Details
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

          // Badge & Points
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
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
                  Text('$points điểm', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }

  // ==================== TAB 3: SERVICES ====================
  Widget _buildServicesTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _services.length,
          itemBuilder: (context, index) {
            final service = _services[index];
            return _buildServiceCard(service);
          },
        ),
      ],
    );
  }

  Widget _buildServiceCard(dynamic service) {
    final String name = service['name'] ?? '';
    final String description = service['description'] ?? '';
    final dynamic price = service['price'] ?? 0;
    final int duration = service['durationMinutes'] ?? 0;
    final bool isActive = service['isActive'] ?? true;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          // Service Icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppTheme.primaryBlue.withAlpha(10), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.local_car_wash_rounded, color: AppTheme.primaryBlue, size: 24),
          ),
          const SizedBox(width: 14),

          // Service details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(name, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: (isActive ? Colors.green : Colors.red).withAlpha(20),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isActive ? 'Hoạt động' : 'Tạm dừng',
                        style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.bold, color: isActive ? Colors.green : Colors.red),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 2),
                Text(description, style: GoogleFonts.outfit(fontSize: 11, color: AppTheme.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.timer_outlined, size: 12, color: AppTheme.textSecondary),
                    const SizedBox(width: 4),
                    Text('$duration phút', style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textSecondary)),
                    const SizedBox(width: 16),
                    const Icon(Icons.monetization_on_outlined, size: 12, color: AppTheme.textSecondary),
                    const SizedBox(width: 4),
                    Text(_formatCurrency(price), style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.primaryBlue, fontWeight: FontWeight.bold)),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
