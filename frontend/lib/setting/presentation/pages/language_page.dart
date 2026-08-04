import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/language_controller.dart';
import '../widgets/custom_header.dart';

class LanguagePage extends GetView<LanguageController> {
  const LanguagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FAF6),
      body: SafeArea(
        child: Column(
          children: [
            const CustomHeader(title: 'Ngôn ngữ'),
            Expanded(
              // <--- Thêm Expanded & SingleChildScrollView ở đây để cho phép cuộn
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Obx(
                    () => ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.languages.length,
                      separatorBuilder: (context, index) => const Divider(color: Color(0xFFECEFF1), height: 1, thickness: 1),
                      itemBuilder: (context, index) {
                        final item = controller.languages[index];
                        final isSelected =
                            item.code == controller.selectedCode.value;

                        return InkWell(
                          onTap: () => controller.selectLanguage(item.code),
                          borderRadius: BorderRadius.circular(index == 0 ? 16 : (index == controller.languages.length - 1 ? 16 : 0)),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFFF4FAF6) : Colors.transparent, // Đổi màu nền nhẹ nếu được chọn
                              borderRadius: BorderRadius.circular(index == 0 ? 16 : (index == controller.languages.length - 1 ? 16 : 0)),
                            ),

                            child: Row(
                              children: [
                                Text(item.flag , style: const TextStyle(fontSize: 24)),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item.name, style: GoogleFonts.nunito(color: const Color(0xFF0C3D2B), fontWeight: FontWeight.w800, fontSize: 15)),
                                      const SizedBox(height: 2),
                                      Text(item.nativeName , style: GoogleFonts.nunito(color: const Color(0xFF5A7563), fontSize: 12, fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  Container(
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF0C3D2B),
                                      shape: BoxShape.circle,
                                    ),
                                    padding: const EdgeInsets.all(4),
                                    child: const Icon(Icons.check_rounded, color: Colors.white, size: 16),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
