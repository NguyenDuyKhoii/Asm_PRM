import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:autowash_pro/core/theme/app_theme.dart';
import 'package:autowash_pro/presentation/providers/auth_provider.dart';
import 'package:autowash_pro/presentation/providers/booking_provider.dart';
import 'package:autowash_pro/presentation/screens/auth/login_screen.dart';
import 'package:autowash_pro/data/models/booking_model.dart';

class StaffDashboardScreen extends StatefulWidget {
  const StaffDashboardScreen({super.key});

  @override
  State<StaffDashboardScreen> createState() => _StaffDashboardScreenState();
}

class _StaffDashboardScreenState extends State<StaffDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<BookingProvider>(context, listen: false);
      provider.fetchTodayBookings();
      provider.fetchStaffStats();
    });
  }

  Map<String, String> _getChecklistForService(String serviceName) {
    final lower = serviceName.toLowerCase();
    if (lower.contains('basic')) {
      return {
        'exterior_high': 'Rửa ngoại thất áp suất cao',
        'hand_dry': 'Lau khô bằng tay',
        'tire_shine': 'Xịt bóng lốp'
      };
    } else if (lower.contains('premium')) {
      return {
        'exterior_wash': 'Rửa ngoại thất',
        'interior_basic': 'Vệ sinh nội thất cơ bản',
        'vacuum_seats': 'Hút bụi sàn và ghế'
      };
    } else if (lower.contains('wash & vacuum') || lower.contains('wash and vacuum')) {
      return {
        'exterior_full': 'Rửa ngoại thất toàn diện',
        'vacuum_full': 'Hút bụi nội thất toàn diện',
        'dashboard': 'Vệ sinh bảng điều khiển'
      };
    } else if (lower.contains('comprehensive')) {
      return {
        'wash_vacuum': 'Rửa và Hút bụi',
        'paint_polish': 'Đánh bóng sơn',
        'plastic_trim': 'Dưỡng nhựa nhám',
        'fragrance': 'Khử mùi, tạo hương thơm'
      };
    } else if (lower.contains('interior')) {
      return {
        'interior_deep': 'Vệ sinh nội thất sâu',
        'seat_wash': 'Giặt ghế',
        'ceiling_clean': 'Vệ sinh trần xe',
        'leather_cond': 'Dưỡng da'
      };
    } else {
      return {
        'exterior': 'Rửa ngoại thất',
        'interior': 'Hút bụi nội thất',
        'tires': 'Xịt bóng lốp'
      };
    }
  }

  Future<void> _claimBooking(String bookingId) async {
    final success = await Provider.of<BookingProvider>(context, listen: false).claimBooking(bookingId);
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nhận việc thành công!')));
    } else {
      final error = Provider.of<BookingProvider>(context, listen: false).error;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error ?? 'Có lỗi xảy ra')));
    }
  }

  Future<void> _updateStatus(String bookingId, int newStatus) async {
    final success = await Provider.of<BookingProvider>(context, listen: false).updateBookingStatus(bookingId, newStatus);
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cập nhật trạng thái thành công')));
    } else {
      final error = Provider.of<BookingProvider>(context, listen: false).error;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error ?? 'Có lỗi xảy ra')));
    }
  }

  Future<void> _toggleChecklist(BookingListModel booking, String itemKey, bool currentValue) async {
    Map<String, dynamic> currentChecklist = {};
    if (booking.checklist != null && booking.checklist!.isNotEmpty) {
      try {
        currentChecklist = jsonDecode(booking.checklist!);
      } catch (_) {}
    }
    currentChecklist[itemKey] = !currentValue;

    final success = await Provider.of<BookingProvider>(context, listen: false).updateChecklist(booking.id, currentChecklist);
    if (!mounted) return;
    if (!success) {
      final error = Provider.of<BookingProvider>(context, listen: false).error;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error ?? 'Không thể lưu kiểm tra')));
    }
  }

  Future<String?> _uploadToCloudinary(XFile imageFile) async {
    const String cloudName = 'dpcjk1tab';
    const String apiKey = '263482225152376';
    const String apiSecret = '8za2qN0Xehd_2cen7tWq0bgCTXE';

    int timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    String toSign = 'timestamp=$timestamp$apiSecret';
    String signature = sha1.convert(utf8.encode(toSign)).toString();

    var uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
    var request = http.MultipartRequest('POST', uri)
      ..fields['api_key'] = apiKey
      ..fields['timestamp'] = timestamp.toString()
      ..fields['signature'] = signature
      ..files.add(kIsWeb
          ? http.MultipartFile.fromBytes('file', await imageFile.readAsBytes(), filename: imageFile.name.contains('.') ? imageFile.name : '${imageFile.name}.jpg')
          : await http.MultipartFile.fromPath('file', imageFile.path));

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var json = jsonDecode(responseData);
        return json['secure_url'];
      }
    } catch (e) {
      debugPrint('Cloudinary Exception: $e');
    }
    return null;
  }

  Future<void> _completeBookingWithPhoto(String bookingId) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image == null) return;

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final imageUrl = await _uploadToCloudinary(image);
    if (!mounted) return;
    Navigator.pop(context); // close dialog

    if (imageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lỗi tải ảnh lên. Vui lòng thử lại.')));
      return;
    }

    final success = await Provider.of<BookingProvider>(context, listen: false).completeBooking(bookingId, imageUrl);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Hoàn thành công việc thành công!')));
    } else {
      final error = Provider.of<BookingProvider>(context, listen: false).error;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error ?? 'Có lỗi xảy ra')));
    }
  }

  Widget _buildChecklist(BookingListModel booking) {
    Map<String, dynamic> parsed = {};
    if (booking.checklist != null && booking.checklist!.isNotEmpty) {
      try { parsed = jsonDecode(booking.checklist!); } catch (_) {}
    }

    final items = _getChecklistForService(booking.serviceName);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const Text('Danh sách kiểm tra (Checklist):', style: TextStyle(fontWeight: FontWeight.bold)),
        ...items.entries.map((e) {
          final isChecked = parsed[e.key] == true;
          return CheckboxListTile(
            title: Text(e.value),
            value: isChecked,
            dense: true,
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            onChanged: booking.status == 'InProgress' ? (val) => _toggleChecklist(booking, e.key, isChecked) : null,
          );
        }),
      ],
    );
  }

  Widget _buildStatusButton(BookingListModel booking, String currentUserId) {
    if (booking.staffId == null && (booking.status == 'Pending' || booking.status == 'Confirmed')) {
      return ElevatedButton(
        onPressed: () => _claimBooking(booking.id),
        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue),
        child: const Text('Nhận việc', style: TextStyle(color: Colors.white)),
      );
    }

    if (booking.staffId != currentUserId && booking.staffId != null) {
      return const Text('Đã có nhân viên khác nhận', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic));
    }

    if (booking.status == 'Pending' || booking.status == 'Confirmed') {
      return ElevatedButton(
        onPressed: () => _updateStatus(booking.id, 2), // InProgress
        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
        child: const Text('Bắt đầu rửa', style: TextStyle(color: Colors.white)),
      );
    } 
    
    if (booking.status == 'InProgress') {
      // Check if all checklist items are done
      Map<String, dynamic> parsed = {};
      if (booking.checklist != null && booking.checklist!.isNotEmpty) {
        try { parsed = jsonDecode(booking.checklist!); } catch (_) {}
      }
      
      final items = _getChecklistForService(booking.serviceName);
      bool allChecked = true;
      for (var key in items.keys) {
        if (parsed[key] != true) {
          allChecked = false;
          break;
        }
      }

      return ElevatedButton(
        onPressed: allChecked ? () => _completeBookingWithPhoto(booking.id) : null,
        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
        child: const Text('Chụp ảnh & Hoàn thành', style: TextStyle(color: Colors.white)),
      );
    }

    return Text(booking.status, style: const TextStyle(color: Colors.grey));
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final bookingProvider = Provider.of<BookingProvider>(context);
    final stats = bookingProvider.staffStats;
    final currentUserId = authProvider.user?.userId ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.logout();
              if (!mounted) return;
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
          ),
        ],
      ),
      body: bookingProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await bookingProvider.fetchTodayBookings();
                await bookingProvider.fetchStaffStats();
              },
              child: Column(
                children: [
                  if (stats != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: AppTheme.primaryBlue.withOpacity(0.1),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem('Hôm nay', '${stats['todayCompleted'] ?? 0} xe', Colors.green),
                          _buildStatItem('Tuần này', '${stats['weekCompleted'] ?? 0} xe', AppTheme.primaryBlue),
                          _buildStatItem('Đang chờ', '${stats['activeJobs'] ?? 0} xe', Colors.orange),
                        ],
                      ),
                    ),
                  Expanded(
                    child: bookingProvider.todayBookings.isEmpty
                        ? ListView(children: const [SizedBox(height: 100), Center(child: Text('Hiện tại không có công việc nào.'))])
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: bookingProvider.todayBookings.length,
                            itemBuilder: (context, index) {
                              final booking = bookingProvider.todayBookings[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 16),
                                elevation: 2,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            booking.timeSlotDisplay,
                                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: booking.status == 'Completed' ? Colors.green.withOpacity(0.1) : AppTheme.primaryBlue.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              booking.status,
                                              style: TextStyle(
                                                color: booking.status == 'Completed' ? Colors.green : AppTheme.primaryBlue,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Text('Dịch vụ: ${booking.serviceName}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                      const SizedBox(height: 8),
                                      Text('Biển số xe: ${booking.vehiclePlate}', style: const TextStyle(fontSize: 14)),
                                      
                                      // Show checklist if claimed by this staff and not completed
                                      if (booking.staffId == currentUserId && booking.status != 'Completed')
                                        _buildChecklist(booking),
                                        
                                      if (booking.status == 'Completed' && booking.completionImageUrl != null)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 12),
                                          child: Text('Đã hoàn thành (Có ảnh nghiệm thu)', style: TextStyle(color: Colors.green.shade700, fontStyle: FontStyle.italic)),
                                        ),

                                      const SizedBox(height: 16),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: _buildStatusButton(booking, currentUserId),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }
}
