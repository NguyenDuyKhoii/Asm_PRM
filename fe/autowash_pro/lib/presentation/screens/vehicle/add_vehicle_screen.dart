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

  String _selectedProvinceCode = '51';
  String _selectedName = 'Toyota Vios';
  String _selectedColor = 'Trắng';

  final List<Map<String, String>> _provinces = [
    {'code': '51', 'name': 'TP. HCM (51)'},
    {'code': '50', 'name': 'TP. HCM (50)'},
    {'code': '29', 'name': 'Hà Nội (29)'},
    {'code': '30', 'name': 'Hà Nội (30)'},
    {'code': '43', 'name': 'Đà Nẵng (43)'},
    {'code': '15', 'name': 'Hải Phòng (15)'},
    {'code': '72', 'name': 'Bà Rịa - Vũng Tàu (72)'},
    {'code': '98', 'name': 'Bắc Giang (98)'},
    {'code': '97', 'name': 'Bắc Kạn (97)'},
    {'code': '94', 'name': 'Bạc Liêu (94)'},
    {'code': '99', 'name': 'Bắc Ninh (99)'},
    {'code': '71', 'name': 'Bến Tre (71)'},
    {'code': '77', 'name': 'Bình Định (77)'},
    {'code': '61', 'name': 'Bình Dương (61)'},
    {'code': '93', 'name': 'Bình Phước (93)'},
    {'code': '86', 'name': 'Bình Thuận (86)'},
    {'code': '69', 'name': 'Cà Mau (69)'},
    {'code': '65', 'name': 'Cần Thơ (65)'},
    {'code': '11', 'name': 'Cao Bằng (11)'},
    {'code': '48', 'name': 'Đắk Nông (48)'},
    {'code': '47', 'name': 'Đắk Lắk (47)'},
    {'code': '27', 'name': 'Điện Biên (27)'},
    {'code': '60', 'name': 'Đồng Nai (60)'},
    {'code': '66', 'name': 'Đồng Tháp (66)'},
    {'code': '81', 'name': 'Gia Lai (81)'},
    {'code': '23', 'name': 'Hà Giang (23)'},
    {'code': '35', 'name': 'Ninh Bình (35)'},
    {'code': '34', 'name': 'Hải Dương (34)'},
    {'code': '38', 'name': 'Hà Tĩnh (38)'},
    {'code': '95', 'name': 'Hậu Giang (95)'},
    {'code': '28', 'name': 'Hòa Bình (28)'},
    {'code': '79', 'name': 'Khánh Hòa (79)'},
    {'code': '68', 'name': 'Kiên Giang (68)'},
    {'code': '82', 'name': 'Kon Tum (82)'},
    {'code': '25', 'name': 'Lai Châu (25)'},
    {'code': '49', 'name': 'Lâm Đồng (49)'},
    {'code': '12', 'name': 'Lạng Sơn (12)'},
    {'code': '24', 'name': 'Lào Cai (24)'},
    {'code': '62', 'name': 'Long An (62)'},
    {'code': '18', 'name': 'Nam Định (18)'},
    {'code': '37', 'name': 'Nghệ An (37)'},
    {'code': '85', 'name': 'Ninh Thuận (85)'},
    {'code': '19', 'name': 'Phú Thọ (19)'},
    {'code': '78', 'name': 'Phú Yên (78)'},
    {'code': '73', 'name': 'Quảng Bình (73)'},
    {'code': '92', 'name': 'Quảng Nam (92)'},
    {'code': '76', 'name': 'Quảng Ngãi (76)'},
    {'code': '14', 'name': 'Quảng Ninh (14)'},
    {'code': '74', 'name': 'Quảng Trị (74)'},
    {'code': '83', 'name': 'Sóc Trăng (83)'},
    {'code': '26', 'name': 'Sơn La (26)'},
    {'code': '70', 'name': 'Tây Ninh (70)'},
    {'code': '17', 'name': 'Thái Bình (17)'},
    {'code': '20', 'name': 'Thái Nguyên (20)'},
    {'code': '36', 'name': 'Thanh Hóa (36)'},
    {'code': '75', 'name': 'Thừa Thiên Huế (75)'},
    {'code': '63', 'name': 'Tiền Giang (63)'},
    {'code': '84', 'name': 'Trà Vinh (84)'},
    {'code': '22', 'name': 'Tuyên Quang (22)'},
    {'code': '64', 'name': 'Vĩnh Long (64)'},
    {'code': '21', 'name': 'Yên Bái (21)'},
  ];

  final List<String> _carNameSuggestions = [
    'Toyota Vios', 'Honda Civic', 'Hyundai Accent', 'Mazda 3', 'VinFast VF8',
    'VinFast VF5', 'Ford Ranger', 'Mitsubishi Xpander', 'Honda City', 'Kia Morning',
  ];
  final List<String> _motoNameSuggestions = [
    'Honda SH', 'Honda Vision', 'Honda Air Blade', 'Yamaha Exciter',
    'Honda Wave Alpha', 'Honda Lead', 'Yamaha Grande', 'Vespa Sprint',
  ];
  final List<String> _colorSuggestions = [
    'Trắng', 'Đen', 'Đỏ', 'Xám', 'Xanh dương', 'Bạc', 'Vàng', 'Nâu',
  ];

  List<String> getNameOptions() {
    return _selectedType == 0 
        ? [..._carNameSuggestions, 'Khác (Tự điền)']
        : [..._motoNameSuggestions, 'Khác (Tự điền)'];
  }

  @override
  void initState() {
    super.initState();
    _selectedName = _carNameSuggestions[0];
    _selectedColor = _colorSuggestions[0];
  }

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
        debugPrint('Cloudinary Error: ${response.statusCode} - $errorData');
      }
    } catch (e) {
      debugPrint('Cloudinary Exception: $e');
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

      final fullPlate = '$_selectedProvinceCode${_licensePlateController.text.trim()}'.toUpperCase();
      final finalName = _selectedName == 'Khác (Tự điền)' 
          ? _nameController.text.trim() 
          : _selectedName;
      final finalColor = _selectedColor == 'Khác (Tự điền)' 
          ? _colorController.text.trim() 
          : _selectedColor;

      if (mounted) {
        final provider = Provider.of<BookingProvider>(context, listen: false);
        final success = await provider.addVehicle(
          fullPlate,
          _selectedType,
          name: finalName.isNotEmpty ? finalName : null,
          color: finalColor.isNotEmpty ? finalColor : null,
          imageUrl: uploadedUrl,
        );

        if (!mounted) return;
        setState(() => _isUploading = false);

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã thêm phương tiện thành công!'),
              backgroundColor: AppTheme.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(provider.error ?? 'Đã có lỗi xảy ra'),
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
                                  onTap: () => setState(() {
                                    _selectedType = 0;
                                    _selectedName = _carNameSuggestions[0];
                                    _nameController.text = _carNameSuggestions[0];
                                  }),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _VehicleTypeCard(
                                  title: 'Xe máy',
                                  icon: Icons.two_wheeler_rounded,
                                  isSelected: _selectedType == 1,
                                  onTap: () => setState(() {
                                    _selectedType = 1;
                                    _selectedName = _motoNameSuggestions[0];
                                    _nameController.text = _motoNameSuggestions[0];
                                  }),
                                ),
                              ),
                            ],
                          ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideX(begin: 0.05),

                          const SizedBox(height: 36),
                          
                          Text(
                            'Hình ảnh xe',
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
                                        Text('Nhấp để tải ảnh lên', style: GoogleFonts.outfit(color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
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
                                // Dropdown for province codes
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _selectedProvinceCode,
                                      style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.textPrimary),
                                      icon: const Icon(Icons.arrow_drop_down_rounded, color: AppTheme.textMuted),
                                      menuMaxHeight: 350,
                                      onChanged: (val) {
                                        if (val != null) setState(() => _selectedProvinceCode = val);
                                      },
                                      items: _provinces.map((p) => DropdownMenuItem<String>(
                                        value: p['code'],
                                        child: SizedBox(
                                          width: 220,
                                          child: Text(
                                            p['name']!,
                                            style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      )).toList(),
                                      selectedItemBuilder: (BuildContext context) {
                                        return _provinces.map((p) {
                                          return Container(
                                            alignment: Alignment.center,
                                            child: Text(p['code']!, style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.textPrimary)),
                                          );
                                        }).toList();
                                      },
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 1.5,
                                  height: 36,
                                  color: Colors.grey.shade300,
                                ),
                                Expanded(
                                  child: TextFormField(
                                    controller: _licensePlateController,
                                    textCapitalization: TextCapitalization.characters,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 2, color: AppTheme.textPrimary),
                                    decoration: InputDecoration(
                                      hintText: 'A-123.45',
                                      hintStyle: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 2, color: Colors.grey.shade300),
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'Vui lòng nhập số xe';
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
                            'Tên xe (tùy chọn)',
                            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                          ).animate().fadeIn(duration: 400.ms, delay: 350.ms).slideX(begin: 0.05),
                          const SizedBox(height: 12),
                          
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade300, width: 1.5),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: _selectedName,
                                style: GoogleFonts.outfit(fontSize: 16, color: AppTheme.textPrimary),
                                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.textMuted),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() {
                                      _selectedName = val;
                                      if (val != 'Khác (Tự điền)') {
                                        _nameController.text = val;
                                      } else {
                                        _nameController.clear();
                                      }
                                    });
                                  }
                                },
                                items: getNameOptions().map((String val) {
                                  return DropdownMenuItem<String>(
                                    value: val,
                                    child: Text(val, style: GoogleFonts.outfit(fontWeight: FontWeight.w500)),
                                  );
                                }).toList(),
                              ),
                            ),
                          ).animate().fadeIn(duration: 400.ms, delay: 380.ms).slideX(begin: 0.05),
                          
                          if (_selectedName == 'Khác (Tự điền)') ...[
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _nameController,
                              style: GoogleFonts.outfit(color: AppTheme.textPrimary),
                              decoration: InputDecoration(
                                hintText: 'Nhập tên xe của bạn (Ví dụ: Toyota Vios 2024)',
                                hintStyle: GoogleFonts.outfit(color: Colors.grey.shade400),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5)),
                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5)),
                                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              ),
                            ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.05),
                          ],

                          const SizedBox(height: 24),

                          Text(
                            'Màu sắc (tùy chọn)',
                            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                          ).animate().fadeIn(duration: 400.ms, delay: 420.ms).slideX(begin: 0.05),
                          const SizedBox(height: 12),
                          
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade300, width: 1.5),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: _selectedColor,
                                style: GoogleFonts.outfit(fontSize: 16, color: AppTheme.textPrimary),
                                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.textMuted),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() {
                                      _selectedColor = val;
                                      if (val != 'Khác (Tự điền)') {
                                        _colorController.text = val;
                                      } else {
                                        _colorController.clear();
                                      }
                                    });
                                  }
                                },
                                items: [..._colorSuggestions, 'Khác (Tự điền)'].map((String val) {
                                  return DropdownMenuItem<String>(
                                    value: val,
                                    child: Text(val, style: GoogleFonts.outfit(fontWeight: FontWeight.w500)),
                                  );
                                }).toList(),
                              ),
                            ),
                          ).animate().fadeIn(duration: 400.ms, delay: 450.ms).slideX(begin: 0.05),
                          
                          if (_selectedColor == 'Khác (Tự điền)') ...[
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _colorController,
                              style: GoogleFonts.outfit(color: AppTheme.textPrimary),
                              decoration: InputDecoration(
                                hintText: 'Nhập màu sắc xe (Ví dụ: Trắng ngọc trai)',
                                hintStyle: GoogleFonts.outfit(color: Colors.grey.shade400),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5)),
                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5)),
                                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              ),
                            ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.05),
                          ],

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
