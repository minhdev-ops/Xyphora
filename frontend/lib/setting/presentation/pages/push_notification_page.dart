import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/push_notification_controller.dart';
import '../widgets/custom_header.dart';

class PushNotificationPage extends GetView<PushNotificationController> {
  const PushNotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFF4FAF6),
        body: SafeArea(
        child: Column(
          children: [
            const CustomHeader(title: 'Thông báo đẩy'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
              ],
                ),
                child: Obx(() {
                  final keys = controller.settings.keys.toList();
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: keys.length,
                    separatorBuilder: (context, index) => const Divider(color: Color(0xFFECEFF1), height: 1, thickness: 1),
                    itemBuilder: (context, index) {
                      final key = keys[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(key, style: GoogleFonts.nunito(color: const Color(0xFF0C3D2B), fontWeight: FontWeight.w800, fontSize: 15)),
                                  const SizedBox(height: 2),
                                  Text(controller.subtitles[key]!, style: GoogleFonts.nunito(color: const Color(0xFF5A7563), fontSize: 12, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                            Switch(
                              value: controller.settings[key]!,
                              activeColor: Colors.white,
                              activeTrackColor: const Color(0xFF0C3D2B), // Gạt sang màu xanh đậm
                              inactiveThumbColor: Colors.white,
                              inactiveTrackColor: const Color(0xFFD0D0D0),

                              onChanged: (val) => controller.toggleSetting(key, val),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}