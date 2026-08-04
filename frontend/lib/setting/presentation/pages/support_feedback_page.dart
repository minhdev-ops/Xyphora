import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/support_feedback_controller.dart';
import '../widgets/custom_header.dart';
import '../widgets/faqItem_widget.dart';

class SupportFeedbackPage extends GetView<SupportFeedbackController> {
  const SupportFeedbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFF4FAF6),
        body: SafeArea(
        child: Column(
          children: [
            const CustomHeader(title: 'Hỗ trợ & Phản hồi'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                children: [
                  const Text('CÂU HỎI THƯỜNG GẶP', style: TextStyle(color: const Color(0xFF6B7E71), fontSize: 12, fontWeight: FontWeight.bold,
              ),),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFD6E3DB)),
                    ),
                    child: Column(
                      children: controller.faqs.asMap().entries.map((entry) {
                        int index = entry.key;
                        var faq = entry.value;
                        return Column(
                          children: [
                            FaqItemWidget(faq: faq),
                            if (index < controller.faqs.length - 1)
                              const Divider(height: 1, color: const Color(0xFFD6E3DB)),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white , borderRadius: BorderRadius.circular(16),border: Border.all(color: const Color(0xFFD6E3DB)),),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Đánh giá ứng dụng', style: TextStyle(color: const Color(0xFF0C3D2B), fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (index) {
                            return Obx(() => IconButton(
                              icon: Icon(
                                index < controller.rating.value ? Icons.star_rounded : Icons.star_outline_rounded,
                                color: index < controller.rating.value ? const Color(0xFFFFC107) : Colors.grey.shade400,
                                size: 36,
                              ),
                              onPressed: () => controller.setRating(index + 1),
                            ));
                          }),
                        ),
                        if (controller.rating.value > 0)
                          const Padding(
                            padding: EdgeInsets.only(top: 8.0),
                            child: Text(
                              'Cảm ơn bạn đã đánh giá!',
                              style: TextStyle(color: const Color(0xFF6B7E71), fontSize: 13),
                            ),
                          )
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  //
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12 ),
                      border: Border.all(color: const Color(0xFFD6E3DB)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Gửi phản hồi cho chúng tôi', style: TextStyle(color: const Color(0xFF0C3D2B), fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 12),
                        TextField(
                          controller: controller.feedbackController,
                          maxLines: 4,
                          style: const TextStyle(color: const Color(0xFF0C3D2B), fontSize: 13),
                          decoration: InputDecoration(
                            hintText: 'Mô tả vấn đề hoặc góp ý của bạn...',
                            hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                            filled: true,
                            fillColor: const Color(0xFFEDF3EE),
                            // enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white10)),
                            // focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF43D08A))),
                            contentPadding: const EdgeInsets.all(12 ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFFD7E1D8),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF43D08A),
                                width: 1.5,
                              ),),
                          ),

                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: controller.submitFeedback,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFDBE5DE),//0xFF1B3D2F),
                              foregroundColor: const Color(0xFF0C3D2B), //Color(0xFF43D08A),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              elevation: 0,
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
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFD6E3DB)),),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Liên hệ trực tiếp', style: TextStyle(color: const Color(0xFF0C3D2B), fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 12),
                        const Row(
                          children: [
                            Icon(Icons.language_rounded, color: const Color(0xFF6B7E71), size: 18),
                            SizedBox(width: 8),
                            Text('support@xyphora.app', style: TextStyle(color: const Color(0xFF6B7E71), fontSize: 13)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Row(
                          children: [
                            Icon(Icons.chat_bubble_outline_rounded, color: const Color(0xFF6B7E71), size: 18),
                            SizedBox(width: 8),
                            Text('Zalo: 0901 234 567', style: TextStyle(color: const Color(0xFF6B7E71), fontSize: 13)),
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