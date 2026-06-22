import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:autowash_pro/core/theme/app_theme.dart';
import 'package:autowash_pro/presentation/providers/booking_provider.dart';

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _licensePlateController = TextEditingController();
  final _nameController = TextEditingController();
  final _colorController = TextEditingController();
  int _selectedType = 0; // 0 for Car, 1 for Motorcycle
  XFile? _selectedImage;
  bool _isUploading = false;

  @override
  void dispose() {
    _licensePlateController.dispose();
    _nameController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  Future<String?> _uploadToCloudinary(XFile imageFile) async {
    // Tạm thời thay bằng cloud name của bạn nếu cần
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
      } else {
        var errorData = await response.stream.bytesToString();
        print('Cloudinary Error: ${response.statusCode} - $errorData');
      }
    } catch (e) {
      print('Cloudinary Exception: $e');
    }
    return null;
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isUploading = true);
      
      String? uploadedUrl;
      if (_selectedImage != null) {
        uploadedUrl = await _uploadToCloudinary(_selectedImage!);
        if (uploadedUrl == null && mounted) {
          setState(() => _isUploading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Lỗi tải ảnh lên Cloudinary! Vui lòng thử lại.'), backgroundColor: AppTheme.error),
          );
          return;
        }
      }

      if (mounted) {
        final provider = Provider.of<BookingProvider>(context, listen: false);
        final success = await provider.addVehicle(
          _licensePlateController.text.trim(),
          _selectedType,
          name: _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : null,
          color: _colorController.text.trim().isNotEmpty ? _colorController.text.trim() : null,
          imageUrl: uploadedUrl,
        );

        setState(() => _isUploading = false);

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Thêm xe thành công!'),
              backgroundColor: AppTheme.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(provider.error ?? 'Có lỗi xảy ra'),
              backgroundColor: AppTheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      body: Stack(
        children: [
          // Background graphic
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [AppTheme.primaryBlue.withAlpha(40), Colors.transparent],
                  stops: const [0.2, 1.0],
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                // Custom App Bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10, offset: const Offset(0, 4))
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: AppTheme.textPrimary),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Thêm phương tiện',
                        style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w800, color: AppTheme.textPrimary, letterSpacing: -0.5),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    physics: const BouncingScrollPhysics(),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Loại phương tiện',
                            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                          ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.05),
                          const SizedBox(height: 16),
                          
                          Row(
                            children: [
                              Expanded(
                                child: _VehicleTypeCard(
                                  title: 'Ô tô',
                                  icon: Icons.directions_car_rounded,
                                  isSelected: _selectedType == 0,
                                  onTap: () => setState(() => _selectedType = 0),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _VehicleTypeCard(
                                  title: 'Xe máy',
                                  icon: Icons.two_wheeler_rounded,
                                  isSelected: _selectedType == 1,
                                  onTap: () => setState(() => _selectedType = 1),
                                ),
                              ),
                            ],
                          ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideX(begin: 0.05),

                          const SizedBox(height: 36),
                          
                          Text(
                            'Ảnh phương tiện',
                            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                          ).animate().fadeIn(duration: 400.ms, delay: 150.ms).slideX(begin: 0.05),
                          const SizedBox(height: 16),
                          
                          GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              height: 160,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppTheme.primaryBlue.withAlpha(50), width: 2, style: BorderStyle.solid),
                                boxShadow: [BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10, offset: const Offset(0, 4))],
                              ),
                              child: _selectedImage != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(18),
                                      child: kIsWeb 
                                          ? Image.network(_selectedImage!.path, fit: BoxFit.cover, width: double.infinity)
                                          : Image.file(File(_selectedImage!.path), fit: BoxFit.cover, width: double.infinity),
                                    )
                                  : Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(color: AppTheme.accentLightBlue, shape: BoxShape.circle),
                                          child: const Icon(Icons.add_a_photo_rounded, color: AppTheme.primaryBlue, size: 32),
                                        ),
                                        const SizedBox(height: 12),
                                        Text('Nhấn để tải ảnh lên', style: GoogleFonts.outfit(color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                            ),
                          ).animate().fadeIn(duration: 400.ms, delay: 180.ms).slideX(begin: 0.05),

                          const SizedBox(height: 36),

                          Text(
                            'Biển số xe',
                            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                          ).animate().fadeIn(duration: 400.ms, delay: 200.ms).slideX(begin: 0.05),
                          const SizedBox(height: 16),
                          
                          // Custom License Plate Input
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.grey.shade300, width: 2),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 16, offset: const Offset(0, 8))
                              ],
                            ),
                            child: Row(
                              children: [
                                // Vietnam Plate Indicator (Blue strip)
                                Container(
                                  width: 48,
                                  height: 64,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF0F4C81),
                                    borderRadius: BorderRadius.horizontal(left: Radius.circular(18)),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.star, color: Colors.yellow, size: 16),
                                      const SizedBox(height: 4),
                                      Text('VN', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: TextFormField(
                                    controller: _licensePlateController,
                                    textCapitalization: TextCapitalization.characters,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: 2, color: AppTheme.textPrimary),
                                    decoration: InputDecoration(
                                      hintText: '51A-123.45',
                                      hintStyle: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: 2, color: Colors.grey.shade300),
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'Vui lòng nhập biển số xe';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ).animate().fadeIn(duration: 400.ms, delay: 300.ms).slideX(begin: 0.05),
                          
                          const SizedBox(height: 24),

                          Text(
                            'Tên phương tiện (tùy chọn)',
                            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                          ).animate().fadeIn(duration: 400.ms, delay: 350.ms).slideX(begin: 0.05),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _nameController,
                            style: GoogleFonts.outfit(color: AppTheme.textPrimary),
                            decoration: InputDecoration(
                              hintText: 'VD: Sedan Luxury',
                              hintStyle: GoogleFonts.outfit(color: Colors.grey.shade400),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5)),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            ),
                          ).animate().fadeIn(duration: 400.ms, delay: 400.ms).slideX(begin: 0.05),

                          const SizedBox(height: 24),

                          Text(
                            'Màu sắc (tùy chọn)',
                            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                          ).animate().fadeIn(duration: 400.ms, delay: 450.ms).slideX(begin: 0.05),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _colorController,
                            style: GoogleFonts.outfit(color: AppTheme.textPrimary),
                            decoration: InputDecoration(
                              hintText: 'VD: Trắng ngọc trai',
                              hintStyle: GoogleFonts.outfit(color: Colors.grey.shade400),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5)),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            ),
                          ).animate().fadeIn(duration: 400.ms, delay: 500.ms).slideX(begin: 0.05),

                          const SizedBox(height: 80), // Padding for bottom button
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 20, offset: const Offset(0, -5))
          ],
        ),
        child: ElevatedButton(
          onPressed: _isUploading ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryBlue,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
          child: _isUploading 
              ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Text('Xác nhận & Lưu', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
      ),
    );
  }
}

class _VehicleTypeCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _VehicleTypeCard({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primaryBlue : Colors.grey.shade200,
            width: 2,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: AppTheme.primaryBlue.withAlpha(60), blurRadius: 16, offset: const Offset(0, 8))]
              : [BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: isSelected ? Colors.white : AppTheme.textMuted,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? Colors.white : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
