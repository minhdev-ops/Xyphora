import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../controllers/notification_controller.dart';
import '../../domain/models/notification_model.dart';

class NotificationPage extends GetView<NotificationController> {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FAF6), // Match pale green background
      body: SafeArea(
        child: Column(
          children: [
            // 1. Custom Left-Aligned Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Circular back button
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE2F0E5), // Light green circle
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Color(0xFF0C3D2B),
                        size: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Title & Unread Count Subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Thông báo',
                          style: GoogleFonts.nunito(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF0C3D2B),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Obx(() => Text(
                              '${controller.unreadCount} chưa đọc',
                              style: GoogleFonts.nunito(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF5A7563),
                              ),
                            )),
                      ],
                    ),
                  ),
                  // "Đọc tất cả" button
                  GestureDetector(
                    onTap: () => controller.markAllAsRead(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD9E8DF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Đọc tất cả',
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0C3D2B),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 2. Notifications List
            Expanded(
              child: Obx(() {
                final allList = controller.notifications;
                final unreadList = allList.where((n) => !n.isRead.value).toList();
                final readList = allList.where((n) => n.isRead.value).toList();

                if (allList.isEmpty) {
                  return Center(
                    child: Text(
                      'Bạn không có thông báo nào',
                      style: GoogleFonts.nunito(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF5A7563),
                      ),
                    ),
                  );
                }

                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    // Section 1: Chưa đọc
                    if (unreadList.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 12),
                        child: Text(
                          'Chưa đọc',
                          style: GoogleFonts.nunito(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF5A7563),
                          ),
                        ),
                      ),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: unreadList.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = unreadList[index];
                          return _buildNotificationCard(
                            item: item,
                            isUnread: true,
                            onActionTap: () => controller.markAsRead(item.id),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Section 2: Trước đó
                    if (readList.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          'Trước đó',
                          style: GoogleFonts.nunito(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF5A7563),
                          ),
                        ),
                      ),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: readList.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = readList[index];
                          return _buildNotificationCard(
                            item: item,
                            isUnread: false,
                            onActionTap: () =>
                                controller.deleteNotification(item.id),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                    ],
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard({
    required NotificationModel item,
    required bool isUnread,
    required VoidCallback onActionTap,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isUnread ? const Color(0xFFE2F0E5) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isUnread ? const Color(0xFFCBE0D1) : const Color(0xFFE5EDE9),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.01),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: item.iconBgColor,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              item.icon,
              color: item.iconColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: GoogleFonts.nunito(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0C3D2B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.body,
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF5A7563),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.time,
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF8A8A8A),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Action Button (Pin/Mark as read or Delete/Close)
          GestureDetector(
            onTap: onActionTap,
            child: isUnread
                ? const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(
                      Icons.push_pin_outlined,
                      color: Color(0xFF5A7563),
                      size: 18,
                    ),
                  )
                : Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEDEFEF),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.close_rounded,
                      color: Color(0xFF8A8A8A),
                      size: 12,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
