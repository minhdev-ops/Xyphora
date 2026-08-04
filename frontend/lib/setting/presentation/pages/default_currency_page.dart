
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/default_currency_controller.dart';
import '../widgets/custom_header.dart';

class DefaultCurrencyPage extends GetView<DefaultCurrencyController> {
  const DefaultCurrencyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFF4FAF6),
        body: SafeArea(
        child: Column(
          children: [
            const CustomHeader(title: 'Tiền tệ mặc định'),
            Expanded( // <--- Thêm Expanded & SingleChildScrollView ở đây để cho phép cuộn
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Obx(() => ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.currencies.length,
                    separatorBuilder: (context, index) => const Divider(color: Color(0xFFECEFF1), height: 1, thickness: 1),
                    itemBuilder: (context, index) {
                      final item = controller.currencies[index];
                      final isSelected = item.code == controller.selectedCode.value;

                      return InkWell(
                        onTap: () => controller.selectCurrency(item.code),
                        borderRadius: BorderRadius.circular(index == 0 ? 16 : (index == controller.currencies.length - 1 ? 16 : 0)),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFF4FAF6) : Colors.transparent, // Highlight nền xanh siêu nhạt
                            borderRadius: BorderRadius.circular(index == 0 ? 16 : (index == controller.currencies.length - 1 ? 16 : 0)),
                          ),
                          // color: isSelected ? const Color(0xFF142920) : Colors.transparent,
                          child: Row(
                            children: [
                              SizedBox(
                                width: 36,
                                child:
                                Text(item.code, style: GoogleFonts.nunito(color: const Color(0xFF0C3D2B), fontWeight: FontWeight.w900, fontSize: 15)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.name, style: GoogleFonts.nunito(color: const Color(0xFF0C3D2B), fontWeight: FontWeight.w800, fontSize: 14)),
                                    const SizedBox(height: 2),
                                    Text(item.detail, style: GoogleFonts.nunito(color: const Color(0xFF5A7563), fontSize: 12, fontWeight: FontWeight.w600)),

                                    // Text(item.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                                    // Text(item.detail, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                Container(
                                  decoration: const BoxDecoration(color: Color(0xFF0C3D2B), shape: BoxShape.circle),
                                  padding: const EdgeInsets.all(4),
                                  child: const Icon(Icons.check_rounded, color: Colors.white, size: 16),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  )),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}