import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DashboardService {
  static const String baseUrl = 'http://192.168.1.16:8000/api';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<Map<String, dynamic>> getDashboard() async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Chưa đăng nhập'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/dashboard'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': response.body};
      } else {
        return {'success': false, 'message': 'Lỗi tải dữ liệu'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Không thể kết nối đến máy chủ'};
    }
  }
}
