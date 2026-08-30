import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../config/api_config.dart';
import '../../../config/token_storage.dart';
import '../../domain/models/notification_model.dart';

class NotificationController extends GetxController {
  var notifications = <NotificationModel>[].obs;
  var isLoading = false.obs;

  int get unreadCount => notifications.where((n) => !n.isRead.value).length;

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    isLoading.value = true;
    try {
      final token = await TokenStorage.read();
      if (token == null) return;

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/notifications'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final data = body['data'] as List<dynamic>? ?? [];
        notifications.assignAll(data.map((item) {
          final map = item as Map<String, dynamic>;
          final type = map['type']?.toString() ?? 'system';
          final style = _typeStyle(type);
          final createdAt = map['created_at']?.toString() ?? '';
          return NotificationModel(
            id: map['notification_id']?.toString() ?? '',
            title: map['title']?.toString() ?? '',
            body: map['content']?.toString() ?? '',
            time: _formatTime(createdAt),
            icon: style.icon,
            iconColor: style.iconColor,
            iconBgColor: style.iconBgColor,
            isRead: map['is_read'] == true,
          );
        }));
      }
    } catch (e) {
      debugPrint('[NotificationController] load error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final token = await TokenStorage.read();
      if (token == null) return;

      await http.put(
        Uri.parse('${ApiConfig.baseUrl}/notifications/read-all'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

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
    } catch (e) {
      debugPrint('[NotificationController] markAllAsRead error: $e');
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      final token = await TokenStorage.read();
      if (token == null) return;

      await http.put(
        Uri.parse('${ApiConfig.baseUrl}/notifications/$id/read'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final item = notifications.firstWhereOrNull((n) => n.id == id);
      if (item != null) {
        item.isRead.value = true;
      }
    } catch (e) {
      debugPrint('[NotificationController] markAsRead error: $e');
    }
  }

  Future<void> deleteNotification(String id) async {
    try {
      final token = await TokenStorage.read();
      if (token == null) return;

      await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/notifications/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      notifications.removeWhere((n) => n.id == id);
      Get.snackbar(
        'Đã xóa',
        'Đã xóa thông báo khỏi danh sách',
        backgroundColor: const Color(0xFFD32F2F).withValues(alpha: 0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 1),
      );
    } catch (e) {
      debugPrint('[NotificationController] deleteNotification error: $e');
    }
  }

  ({IconData icon, Color iconColor, Color iconBgColor}) _typeStyle(String type) {
    switch (type) {
      case 'invitation':
        return (
          icon: Icons.person_add_outlined,
          iconColor: const Color(0xFF1976D2),
          iconBgColor: const Color(0xFFE3F2FD),
        );
      case 'expense_added':
        return (
          icon: Icons.add_circle_outline_rounded,
          iconColor: const Color(0xFF2E7D32),
          iconBgColor: const Color(0xFFE8F5E9),
        );
      case 'expense_updated':
        return (
          icon: Icons.edit_outlined,
          iconColor: const Color(0xFFF57C00),
          iconBgColor: const Color(0xFFFFF3E0),
        );
      case 'expense_deleted':
        return (
          icon: Icons.delete_outline_rounded,
          iconColor: const Color(0xFFD32F2F),
          iconBgColor: const Color(0xFFFFEBEE),
        );
      case 'settlement_request':
        return (
          icon: Icons.payment_outlined,
          iconColor: const Color(0xFF7B1FA2),
          iconBgColor: const Color(0xFFEDE7F6),
        );
      case 'settlement_completed':
        return (
          icon: Icons.check_circle_outline_rounded,
          iconColor: const Color(0xFF2E7D32),
          iconBgColor: const Color(0xFFE8F5E9),
        );
      case 'reminder':
        return (
          icon: Icons.access_time_rounded,
          iconColor: const Color(0xFFE65100),
          iconBgColor: const Color(0xFFFFF3E0),
        );
      default:
        return (
          icon: Icons.notifications_none_rounded,
          iconColor: const Color(0xFF00796B),
          iconBgColor: const Color(0xFFE0F2F1),
        );
    }
  }

  String _formatTime(String isoString) {
    if (isoString.isEmpty) return '';
    final dt = DateTime.tryParse(isoString);
    if (dt == null) return isoString;
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    if (diff.inDays < 7) return '${diff.inDays} ngày trước';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
