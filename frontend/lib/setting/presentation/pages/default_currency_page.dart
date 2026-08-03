
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/default_currency_controller.dart';
import '../widgets/custom_header.dart';

class DefaultCurrencyPage extends GetView<DefaultCurrencyController> {
  const DefaultCurrencyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFE4F5E5),
        body: SafeArea(
        child: Column(
          children: [
            const CustomHeader(title: 'Tiền tệ mặc định'),
            Expanded( // <--- Thêm Expanded & SingleChildScrollView ở đây để cho phép cuộn
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Container(
                  decoration: BoxDecoration(color: const Color(0xFF18231E), borderRadius: BorderRadius.circular(16)),
                  child: Obx(() => ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.currencies.length,
                    separatorBuilder: (context, index) => const Divider(color: Colors.white10, height: 1),
                    itemBuilder: (context, index) {
                      final item = controller.currencies[index];
                      final isSelected = item.code == controller.selectedCode.value;

                      return InkWell(
                        onTap: () => controller.selectCurrency(item.code),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          color: isSelected ? const Color(0xFF142920) : Colors.transparent,
                          child: Row(
                            children: [
                              SizedBox(
                                width: 32,
                                child: Text(item.code, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                                    Text(item.detail, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                                  ],
                                ),
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
            ),
          ],
        ),
      ),
    );
  }
}