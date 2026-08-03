import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/support_feedback_controller.dart';
import '../widgets/custom_header.dart';

class SupportFeedbackPage extends GetView<SupportFeedbackController> {
  const SupportFeedbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFE4F5E5),
        body: SafeArea(
        child: Column(
          children: [
            const CustomHeader(title: 'Hỗ trợ & Phản hồi'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                children: [
                  const Text('CÂU HỎI THƯỜNG GẶP', style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(color: const Color(0xFF18231E), borderRadius: BorderRadius.circular(16)),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.faqs.length,
                      separatorBuilder: (context, index) => const Divider(color: Colors.white10, height: 1),
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(controller.faqs[index], style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
                          trailing: const Icon(Icons.chevron_right, color: Colors.white38, size: 18),
                          onTap: () => controller.openFaq(controller.faqs[index]),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: const Color(0xFF18231E), borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Đánh giá ứng dụng', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (index) {
                            return Obx(() => IconButton(
                              icon: Icon(
                                index < controller.rating.value ? Icons.star_rounded : Icons.star_outline_rounded,
                                color: index < controller.rating.value ? const Color(0xFFFFB74D) : Colors.white38,
                                size: 30,
                              ),
                              onPressed: () => controller.setRating(index + 1),
                            ));
                          }),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: const Color(0xFF18231E), borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Gửi phản hồi cho chúng tôi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 12),
                        TextField(
                          controller: controller.feedbackController,
                          maxLines: 4,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          decoration: InputDecoration(
                            hintText: 'Mô tả vấn đề hoặc góp ý của bạn...',
                            hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                            filled: true,
                            fillColor: const Color(0xFF111A16),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white10)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF43D08A))),
                          ),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: controller.submitFeedback,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1B3D2F),
                              foregroundColor: const Color(0xFF43D08A),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Gửi phản hồi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: const Color(0xFF18231E), borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Liên hệ trực tiếp', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 12),
                        const Row(
                          children: [
                            Icon(Icons.language_rounded, color: Colors.white54, size: 18),
                            SizedBox(width: 8),
                            Text('support@xyphora.app', style: TextStyle(color: Colors.white54, fontSize: 13)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Row(
                          children: [
                            Icon(Icons.chat_bubble_outline_rounded, color: Colors.white54, size: 18),
                            SizedBox(width: 8),
                            Text('Zalo: 0901 234 567', style: TextStyle(color: Colors.white54, fontSize: 13)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}