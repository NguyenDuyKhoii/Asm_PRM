import 'dart:convert';

class ChecklistTaskModel {
  final String key;
  final String name;
  bool completed;
  List<String> photos;
  final String hint;

  ChecklistTaskModel({
    required this.key,
    required this.name,
    required this.completed,
    required this.photos,
    required this.hint,
  });

  // Map of static hints for each checklist key
  static const Map<String, String> taskHints = {
    // Basic service items
    'exterior_high': 'Chụp ảnh toàn bộ ngoại thất xe sau khi xịt rửa áp suất cao.',
    'hand_dry': 'Chụp ảnh bề mặt sơn xe khô ráo không còn vệt nước.',
    'tire_shine': 'Chụp cận cảnh 4 lốp xe bóng loáng sau khi xịt dưỡng.',
    
    // Premium service items
    'exterior_wash': 'Chụp ảnh 4 góc xe (đầu, đuôi và hai bên sườn) sạch sẽ.',
    'interior_basic': 'Chụp ảnh khoang lái, bảng điều khiển và cần số sạch bụi.',
    'vacuum_seats': 'Chụp ảnh thảm sàn và bề mặt ghế sau khi hút sạch bụi bẩn.',
    
    // Wash & vacuum items
    'exterior_full': 'Chụp ảnh tổng thể ngoại thất xe sáng bóng.',
    'vacuum_full': 'Chụp khoang cabin và cốp sau sạch sẽ.',
    'dashboard': 'Chụp cận cảnh vô lăng và taplo sạch bóng.',
    
    // Comprehensive items
    'wash_vacuum': 'Chụp ngoại thất xe và thảm lót sàn.',
    'paint_polish': 'Chụp cận cảnh nắp capo hoặc bề mặt sơn phản chiếu ánh sáng.',
    'plastic_trim': 'Chụp các phần viền nhựa nhám đen bóng sau khi dưỡng.',
    'fragrance': 'Chụp chai nước hoa hoặc nội thất xe sạch sẽ thơm tho.',
    
    // Interior deep clean items
    'interior_deep': 'Chụp cận cảnh các khe kẽ và nội thất sáng bóng.',
    'seat_wash': 'Chụp cận cảnh bề mặt ghế da/nỉ sạch vết ố.',
    'ceiling_clean': 'Chụp trần xe sạch sẽ không còn vết bẩn.',
    'leather_cond': 'Chụp bề mặt ghế da bóng mượt sau khi thoa dầu dưỡng.',
    
    // Fallback/Default items
    'exterior': 'Chụp ảnh ngoại thất xe sạch sẽ.',
    'interior': 'Chụp ảnh nội thất và thảm lót sàn.',
    'tires': 'Chụp cận cảnh lốp xe sau khi xịt bóng.'
  };

  static String getHint(String key) {
    return taskHints[key] ?? taskHints[key.toLowerCase()] ?? 'Chụp ảnh thực tế kết quả sau khi thực hiện tác vụ này.';
  }

  // Parse raw JSON from DB to structured checklist items
  static List<ChecklistTaskModel> fromJsonString(String? jsonStr, Map<String, String> defaultItems) {
    Map<String, dynamic> parsed = {};
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        parsed = jsonDecode(jsonStr);
      } catch (_) {}
    }

    final List<ChecklistTaskModel> list = [];
    defaultItems.forEach((key, name) {
      bool completed = false;
      List<String> photos = [];

      if (parsed.containsKey(key)) {
        final val = parsed[key];
        if (val is bool) {
          // Legacy support: key -> true/false
          completed = val;
        } else if (val is Map) {
          completed = val['completed'] == true;
          if (val['photos'] != null) {
            photos = List<String>.from(val['photos']);
          }
        }
      }

      list.add(ChecklistTaskModel(
        key: key,
        name: name,
        completed: completed,
        photos: photos,
        hint: getHint(key),
      ));
    });

    return list;
  }

  // Convert checklist models back to JSON map for DB saving
  static Map<String, dynamic> toJsonMap(List<ChecklistTaskModel> tasks) {
    final Map<String, dynamic> map = {};
    for (var task in tasks) {
      map[task.key] = {
        'completed': task.completed,
        'photos': task.photos,
      };
    }
    return map;
  }
}
