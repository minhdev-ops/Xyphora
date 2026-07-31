import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../bindings/event_binding.dart';
import '../controllers/event_controller.dart';
import '../widgets/summary_card.dart';
import '../widgets/filter_chip.dart';
import '../widgets/event_card.dart';
import 'event_detail_view.dart';
import '../../../home_dashboard/presentation/widgets/custom_bottom_nav_bar.dart';

class EventPage extends GetView<EventController> {
  const EventPage({super.key});

  String _formatVND(double amount) {
    final str = amount.abs().toStringAsFixed(0);
    final buf = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buf.write('.');
      buf.write(str[i]);
    }
    return '${buf.toString()}đ';
  }

  @override
  Widget build(BuildContext context) {
    EventBinding().dependencies();

    return Scaffold(
      backgroundColor: const Color(0xFFF2F7F4),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Sự kiện',
            style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0A4226))),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              radius: 20,
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.search,
                    color: Color(0xFF0A4226), size: 20),
                onPressed: () {},
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() => Row(
                      children: [
                        Expanded(
                          child: SummaryCard(
                              label: 'Bạn được nhận',
                              amount: '+${_formatVND(controller.getTotalOwed())}',
                              amountColor: const Color(0xFF1B9B5A)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: SummaryCard(
                              label: 'Bạn còn nợ',
                              amount: '-${_formatVND(controller.getTotalDebt())}',
                              amountColor: const Color(0xFFFF3B30)),
                        ),
                      ],
                    )),
                const SizedBox(height: 20),
                Obx(() => SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                          children: ['Tất cả', 'Đang mở', 'Đã xong']
                              .map((label) => Padding(
                                    padding: const EdgeInsets.only(right: 10),
                                    child: AppFilterChip(
                                        label: label,
                                        isActive: controller.currentFilter.value == label,
                                        onTap: () =>
                                            controller.currentFilter.value = label),
                                  ))
                              .toList()),
                    )),
                const SizedBox(height: 20),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                    child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(
                      color: Color(0xFF0A4226)),
                ));
              }
              return ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: controller.filteredEvents
                    .map((e) => EventCard(
                        event: e,
                        balance: e.getUserBalance(controller.myUserId),
                        onTap: () => Get.to(() => const EventDetailView())))
                    .toList(),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0A4226),
        onPressed: () {},
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: const CustomBottomNavBar(initialIndex: 2),
    );
  }
}
