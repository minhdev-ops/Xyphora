import 'package:get/get.dart';

class PushNotificationController extends GetxController {
  var settings = <String, bool>{
    'Thông báo đẩy': true,
    'Nhắc nợ chưa trả': true,
    'Thanh toán mới': true,
    'Lời mời nhóm': true,
    'Tổng kết tuần': false,
    'Âm thanh thông báo': true,
  }.obs;

  final Map<String, String> subtitles = {
    'Thông báo đẩy': 'Bật/tắt toàn bộ thông báo',
    'Nhắc nợ chưa trả': 'Khi có khoản nợ quá hạn',
    'Thanh toán mới': 'Khi ai đó trả tiền cho bạn',
    'Lời mời nhóm': 'Khi được mời vào nhóm mới',
    'Tổng kết tuần': 'Báo cáo chi tiêu mỗi thứ Hai',
    'Âm thanh thông báo': 'Phát âm khi có thông báo',
  };

  void toggleSetting(String key, bool val) {
    settings[key] = val;
  }
}