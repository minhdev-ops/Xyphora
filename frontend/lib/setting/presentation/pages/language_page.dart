import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/language_controller.dart';
import '../widgets/custom_header.dart';

class LanguagePage extends GetView<LanguageController> {
  const LanguagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFE4F5E5),
        body: SafeArea(
        child: Column(
          children: [
            const CustomHeader(title: 'Ngôn ngữ'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Container(
                decoration: BoxDecoration(color: const Color(0xFF18231E), borderRadius: BorderRadius.circular(16)),
                child: Obx(() => ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.languages.length,
                  separatorBuilder: (context, index) => const Divider(color: Colors.white10, height: 1),
                  itemBuilder: (context, index) {
                    final item = controller.languages[index];
                    final isSelected = item.code == controller.selectedCode.value;

                    return InkWell(
                      onTap: () => controller.selectLanguage(item.code),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        color: isSelected ? const Color(0xFF142920) : Colors.transparent,
                        child: Row(
                          children: [
                            SizedBox(
                              width: 32,
                              child: Text(item.code, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(item.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                            ),
                            if (isSelected)
                              Container(
                                decoration: const BoxDecoration(color: Color(0xFF43D08A), shape: BoxShape.circle),
                                padding: const EdgeInsets.all(4),
                                child: const Icon(Icons.check, color: Color(0xFF0F1714), size: 14),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}