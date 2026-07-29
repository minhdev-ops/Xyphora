import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/models/notification_model.dart';

class NotificationController extends GetxController {
  var notifications = <NotificationModel>[].obs;

  int get unreadCount => notifications.where((n) => !n.isRead.value).length;

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }

  void loadNotifications() {
    notifications.assignAll([
      // Unread notifications (Chưa đọc)
      NotificationModel(
        id: '1',
        title: 'Bạn nợ Minh Anh',
        body: 'Du lịch Đà Lạt • 150.000đ chưa thanh toán',
        time: '5 phút trước',
        icon: Icons.north_east_rounded,
        iconColor: const Color(0xFFD32F2F),
        iconBgColor: const Color(0xFFFFEBEE),
        isRead: false,
      ),
      NotificationModel(
        id: '2',
        title: 'Thanh Tú đã trả bạn',
        body: '55.000đ • Nhóm ăn trưa văn phòng',
        time: '1 giờ trước',
        icon: Icons.south_west_rounded,
        iconColor: const Color(0xFF2E7D32),
        iconBgColor: const Color(0xFFE8F5E9),
        isRead: false,
      ),
      NotificationModel(
        id: '3',
        title: 'Lời mời nhóm mới',
        body: 'Hoàng Nam mời bạn vào nhóm "Weekend Trip 2025"',
        time: '3 giờ trước',
        icon: Icons.person_add_outlined,
        iconColor: const Color(0xFF1976D2),
        iconBgColor: const Color(0xFFE3F2FD),
        isRead: false,
      ),
      // Read notifications (Trước đó)
      NotificationModel(
        id: '4',
        title: 'Nhắc nhở thanh toán',
        body: 'Bạn còn 2 khoản nợ chưa thanh toán trong tuần này',
        time: 'Hôm qua',
        icon: Icons.access_time_rounded,
        iconColor: const Color(0xFFE65100),
        iconBgColor: const Color(0xFFFFF3E0),
        isRead: true,
      ),
      NotificationModel(
        id: '5',
        title: 'Quang Huy đã trả bạn',
        body: '200.000đ • Du lịch Đà Lạt',
        time: 'Hôm qua',
        icon: Icons.south_west_rounded,
        iconColor: const Color(0xFF2E7D32),
        iconBgColor: const Color(0xFFE8F5E9),
        isRead: true,
      ),
      NotificationModel(
        id: '6',
        title: 'Bạn nợ Thanh Tú',
        body: 'Ăn tối BBQ • 85.000đ',
        time: '2 ngày trước',
        icon: Icons.north_east_rounded,
        iconColor: const Color(0xFFD32F2F),
        iconBgColor: const Color(0xFFFFEBEE),
        isRead: true,
      ),
      NotificationModel(
        id: '7',
        title: 'Cập nhật ứng dụng',
        body: 'Xyphora v1.1 đã có sẵn với nhiều tính năng mới 🎉',
        time: '3 ngày trước',
        icon: Icons.notifications_none_rounded,
        iconColor: const Color(0xFF00796B),
        iconBgColor: const Color(0xFFE0F2F1),
        isRead: true,
      ),
    ]);
  }

  void markAllAsRead() {
    for (var n in notifications) {
      n.isRead.value = true;
    }
    Get.snackbar(
      'Thành công',
      'Đã đánh dấu tất cả thông báo là đã đọc',
      backgroundColor: const Color(0xFF0C3D2B).withValues(alpha: 0.8),
      colorText: Colors.white,
      duration: const Duration(seconds: 1),
    );
  }

  void markAsRead(String id) {
    final item = notifications.firstWhereOrNull((n) => n.id == id);
    if (item != null) {
      item.isRead.value = true;
      Get.snackbar(
        'Đã đọc',
        'Đã đánh dấu thông báo là đã đọc',
        backgroundColor: const Color(0xFF0C3D2B).withValues(alpha: 0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 1),
      );
    }
  }

  void deleteNotification(String id) {
    notifications.removeWhere((n) => n.id == id);
    Get.snackbar(
      'Đã xóa',
      'Đã xóa thông báo khỏi danh sách',
      backgroundColor: const Color(0xFFD32F2F).withValues(alpha: 0.8),
      colorText: Colors.white,
      duration: const Duration(seconds: 1),
    );
  }
}
