import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/push_notification_controller.dart';
import '../widgets/custom_header.dart';

class PushNotificationPage extends GetView<PushNotificationController> {
  const PushNotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFE4F5E5),
        body: SafeArea(
        child: Column(
          children: [
            const CustomHeader(title: 'Thông báo đẩy'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Container(
                decoration: BoxDecoration(color: const Color(0xFF18231E), borderRadius: BorderRadius.circular(16)),
                child: Obx(() {
                  final keys = controller.settings.keys.toList();
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: keys.length,
                    separatorBuilder: (context, index) => const Divider(color: Colors.white10, height: 1),
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
                                  Text(key, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                                  const SizedBox(height: 2),
                                  Text(controller.subtitles[key]!, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                                ],
                              ),
                            ),
                            Switch(
                              value: controller.settings[key]!,
                              activeThumbColor: const Color(0xFF43D08A),
                              activeTrackColor: const Color(0xFF1B3D2F),
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