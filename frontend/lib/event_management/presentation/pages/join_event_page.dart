import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/join_event_controller.dart';

class JoinEventPage extends GetView<JoinEventController> {
  final String token;

  const JoinEventPage({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    Get.put(JoinEventController(token));

    return Scaffold(
      backgroundColor: const Color(0xFFF4FAF6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: CircleAvatar(
            backgroundColor: Colors.white,
            radius: 20,
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.arrow_back,
                  color: Color(0xFF0A4226), size: 20),
              onPressed: () => Get.back(),
            ),
          ),
        ),
        leadingWidth: 56,
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF0A4226)),
            );
          }
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),
                Text(
                  controller.eventIcon.value,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 48),
                ),
                const SizedBox(height: 8),
                Text(
                  controller.eventTitle.value,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0A4226),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Chọn tên của bạn trong danh sách:',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Color(0xFF9E9E9E)),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: controller.participants.isEmpty
                      ? const Center(
                          child: Text(
                            'Không còn tên nào để chọn.\nMọi người đã tham gia hết rồi!',
                            textAlign: TextAlign.center,
                            style:
                                TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
                          ),
                        )
                      : ListView.separated(
                          itemCount: controller.participants.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final p = controller.participants[index];
                            final participantId =
                                (p['participant_id'] as num).toInt();
                            final name =
                                p['display_name'] as String? ?? 'Không tên';
                            return _NameCard(
                              name: name,
                              onTap: controller.isClaiming.value
                                  ? null
                                  : () => controller.claim(participantId, name),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _NameCard extends StatelessWidget {
  final String name;
  final VoidCallback? onTap;

  const _NameCard({required this.name, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFFE2F0E5),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    name.isNotEmpty ? name.characters.first.toUpperCase() : '?',
                    style: const TextStyle(
                      color: Color(0xFF0A4226),
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0A4226),
                  ),
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: Color(0xFF9E9E9E)),
            ],
          ),
        ),
      ),
    );
  }
}