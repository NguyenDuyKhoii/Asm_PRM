import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:intl/intl.dart';
import 'package:autowash_pro/core/theme/app_theme.dart';
import 'package:autowash_pro/presentation/providers/auth_provider.dart';
import 'package:autowash_pro/presentation/providers/booking_provider.dart';
import 'package:autowash_pro/presentation/screens/auth/login_screen.dart';
import 'package:autowash_pro/data/models/booking_model.dart';
import 'package:autowash_pro/data/models/checklist_task_model.dart';

class StaffDashboardScreen extends StatefulWidget {
  const StaffDashboardScreen({super.key});

  @override
  State<StaffDashboardScreen> createState() => _StaffDashboardScreenState();
}

class _StaffDashboardScreenState extends State<StaffDashboardScreen> {
  int _selectedTab = 0;

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
    if (lower.contains('basic') || lower.contains('cơ bản')) {
      return {
        'exterior_high': 'Rửa ngoại thất áp suất cao',
        'hand_dry': 'Lau khô bằng tay',
        'tire_shine': 'Xịt bóng lốp'
      };
    } else if (lower.contains('premium') || lower.contains('cao cấp')) {
      return {
        'exterior_wash': 'Rửa ngoại thất',
        'interior_basic': 'Vệ sinh nội thất cơ bản',
        'vacuum_seats': 'Hút bụi sàn và ghế'
      };
    } else if (lower.contains('wash & vacuum') || lower.contains('wash and vacuum') || lower.contains('hút bụi')) {
      return {
        'exterior_full': 'Rửa ngoại thất toàn diện',
        'vacuum_full': 'Hút bụi nội thất toàn diện',
        'dashboard': 'Vệ sinh bảng điều khiển'
      };
    } else if (lower.contains('comprehensive') || lower.contains('toàn diện')) {
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

  Future<void> _completeBooking(BookingListModel booking, List<ChecklistTaskModel> tasks) async {
    String firstPhoto = '';
    for (var t in tasks) {
      if (t.photos.isNotEmpty) {
        firstPhoto = t.photos.first;
        break;
      }
    }

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final success = await Provider.of<BookingProvider>(context, listen: false).completeBooking(booking.id, firstPhoto);
    if (!mounted) return;
    Navigator.pop(context); // close spinner

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Hoàn thành đơn hàng thành công!')));
    } else {
      final error = Provider.of<BookingProvider>(context, listen: false).error;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error ?? 'Có lỗi xảy ra')));
    }
  }

  Widget _buildChecklist(BookingListModel booking) {
    final defaultItems = _getChecklistForService(booking.serviceName);
    final tasks = ChecklistTaskModel.fromJsonString(booking.checklist, defaultItems);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const Text(
          'Danh sách kiểm tra & Ảnh nghiệm thu:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(height: 8),
        ...tasks.map((task) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            color: Colors.grey.shade50,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: task.completed,
                        activeColor: AppTheme.success,
                        onChanged: booking.status == 'InProgress'
                            ? (val) async {
                                task.completed = val == true;
                                final checklistMap = ChecklistTaskModel.toJsonMap(tasks);
                                final success = await Provider.of<BookingProvider>(context, listen: false)
                                    .updateChecklist(booking.id, checklistMap);
                                if (!mounted) return;
                                if (!success) {
                                  final error = Provider.of<BookingProvider>(context, listen: false).error;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(error ?? 'Không thể cập nhật')),
                                  );
                                }
                              }
                            : null,
                      ),
                      Expanded(
                        child: Text(
                          task.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            decoration: task.completed ? TextDecoration.lineThrough : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 12, right: 12, bottom: 8),
                    child: Text(
                      task.hint,
                      style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey.shade600),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: SizedBox(
                      height: 80,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          ...task.photos.map((photoUrl) {
                            return Stack(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(photoUrl, fit: BoxFit.cover),
                                  ),
                                ),
                                if (booking.status == 'InProgress')
                                  Positioned(
                                    top: 2,
                                    right: 10,
                                    child: GestureDetector(
                                      onTap: () async {
                                        task.photos.remove(photoUrl);
                                        if (task.photos.isEmpty) {
                                          task.completed = false;
                                        }
                                        final checklistMap = ChecklistTaskModel.toJsonMap(tasks);
                                        final success = await Provider.of<BookingProvider>(context, listen: false)
                                            .updateChecklist(booking.id, checklistMap);
                                        if (!mounted) return;
                                        if (!success) {
                                          final error = Provider.of<BookingProvider>(context, listen: false).error;
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text(error ?? 'Không thể xóa ảnh')),
                                          );
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.close, size: 12, color: Colors.white),
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          }),
                          if (booking.status == 'InProgress')
                            GestureDetector(
                              onTap: () async {
                                final ImagePicker picker = ImagePicker();
                                final XFile? image = await picker.pickImage(source: ImageSource.camera);
                                if (image == null) return;

                                if (!mounted) return;
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) => const Center(child: CircularProgressIndicator()),
                                );

                                final uploadedUrl = await _uploadToCloudinary(image);
                                if (!mounted) return;
                                Navigator.pop(context); // Close spinner

                                if (uploadedUrl == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Lỗi tải ảnh lên. Vui lòng thử lại.')),
                                  );
                                  return;
                                }

                                task.photos.add(uploadedUrl);
                                task.completed = true;
                                final checklistMap = ChecklistTaskModel.toJsonMap(tasks);
                                final success = await Provider.of<BookingProvider>(context, listen: false)
                                    .updateChecklist(booking.id, checklistMap);
                                if (!mounted) return;
                                if (!success) {
                                  final error = Provider.of<BookingProvider>(context, listen: false).error;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(error ?? 'Không thể lưu ảnh')),
                                  );
                                }
                              },
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                child: const Icon(Icons.add_a_photo_rounded, color: Colors.grey),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
      bool isTimeReached = true;
      if (booking.timeSlotDisplay.contains('-')) {
        try {
          final startPart = booking.timeSlotDisplay.split('-')[0].trim();
          final timeParts = startPart.split(':');
          final scheduledStart = DateTime(
            booking.bookingDate.year,
            booking.bookingDate.month,
            booking.bookingDate.day,
            int.parse(timeParts[0]),
            int.parse(timeParts[1]),
          );
          isTimeReached = DateTime.now().isAfter(scheduledStart);
        } catch (_) {}
      }

      return ElevatedButton(
        onPressed: isTimeReached ? () => _updateStatus(booking.id, 2) : null, // InProgress
        style: ElevatedButton.styleFrom(
          backgroundColor: isTimeReached ? Colors.orange : Colors.grey.shade400,
        ),
        child: Text(
          isTimeReached ? 'Bắt đầu làm việc' : 'Chưa tới giờ',
          style: const TextStyle(color: Colors.white),
        ),
      );
    } 
    
    if (booking.status == 'InProgress') {
      final defaultItems = _getChecklistForService(booking.serviceName);
      final tasks = ChecklistTaskModel.fromJsonString(booking.checklist, defaultItems);
      bool canComplete = tasks.every((t) => t.completed && t.photos.isNotEmpty);

      return ElevatedButton(
        onPressed: canComplete ? () => _completeBooking(booking, tasks) : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: canComplete ? Colors.green : Colors.grey.shade400,
        ),
        child: const Text('Hoàn thành đơn hàng', style: TextStyle(color: Colors.white)),
      );
    }

    return Text(booking.status, style: const TextStyle(color: Colors.grey));
  }

  Widget _buildTabItem(int index, String label) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? AppTheme.primaryBlue : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? AppTheme.primaryBlue : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final bookingProvider = Provider.of<BookingProvider>(context);
    final stats = bookingProvider.staffStats;
    final currentUserId = authProvider.user?.userId ?? '';

    final filteredBookings = bookingProvider.todayBookings.where((booking) {
      if (_selectedTab == 0) {
        return booking.staffId == null;
      } else {
        return booking.staffId == currentUserId;
      }
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.logout();
              if (!context.mounted) return;
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
                      color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem('Hôm nay', '${stats['todayCompleted'] ?? 0} xe', Colors.green),
                          _buildStatItem('Tuần này', '${stats['weekCompleted'] ?? 0} xe', AppTheme.primaryBlue),
                          _buildStatItem('Đang chờ', '${stats['activeJobs'] ?? 0} xe', Colors.orange),
                        ],
                      ),
                    ),
                  // Tabs
                  Container(
                    color: Colors.white,
                    child: Row(
                      children: [
                        _buildTabItem(0, 'Việc chưa nhận (${bookingProvider.todayBookings.where((b) => b.staffId == null).length})'),
                        _buildTabItem(1, 'Việc của tôi (${bookingProvider.todayBookings.where((b) => b.staffId == currentUserId).length})'),
                      ],
                    ),
                  ),
                  Expanded(
                    child: filteredBookings.isEmpty
                        ? ListView(children: const [SizedBox(height: 100), Center(child: Text('Hiện tại không có công việc nào.'))])
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredBookings.length,
                            itemBuilder: (context, index) {
                              final booking = filteredBookings[index];
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
                                            '${DateFormat('dd/MM/yyyy').format(booking.bookingDate)}  |  ${booking.timeSlotDisplay}',
                                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: booking.status == 'Completed' ? Colors.green.withValues(alpha: 0.1) : AppTheme.primaryBlue.withValues(alpha: 0.1),
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
                                      
                                      // Show checklist if claimed by this staff and status is InProgress
                                      if (booking.staffId == currentUserId && booking.status == 'InProgress')
                                        _buildChecklist(booking),
                                        
                                      if (booking.status == 'Completed' && booking.completionImageUrl != null)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 12),
                                          child: Text('Đã hoàn thành (Có ảnh nghiệm thu)', style: TextStyle(color: Colors.green.shade700, fontStyle: FontStyle.italic)),
                                        ),

                                      // Show customer feedback review if available
                                      if (booking.status == 'Completed' && booking.rating != null)
                                        Container(
                                          margin: const EdgeInsets.only(top: 12),
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.amber.withValues(alpha: 0.08),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    'Khách đánh giá: ${booking.rating} / 5',
                                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.orange),
                                                  ),
                                                ],
                                              ),
                                              if (booking.reviewComment != null && booking.reviewComment!.isNotEmpty) ...[
                                                const SizedBox(height: 6),
                                                Text(
                                                  'Phản hồi: "${booking.reviewComment}"',
                                                  style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 12, color: Colors.black87),
                                                ),
                                              ]
                                            ],
                                          ),
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
