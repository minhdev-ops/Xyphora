import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../bindings/event_binding.dart';
import '../controllers/event_controller.dart';
import '../widgets/summary_card.dart';
import '../widgets/filter_chip.dart';
import '../widgets/event_card.dart';

class EventPage extends StatelessWidget {
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
    final ctrl = Get.find<EventController>();

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() => Row(
                  children: [
                    Expanded(
                      child: SummaryCard(
                          label: 'Bạn được nhận',
                          amount: '+${_formatVND(ctrl.getTotalOwed())}',
                          amountColor: const Color(0xFF1B9B5A)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SummaryCard(
                          label: 'Bạn còn nợ',
                          amount: '-${_formatVND(ctrl.getTotalDebt())}',
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
                                    isActive: ctrl.currentFilter.value == label,
                                    onTap: () =>
                                        ctrl.currentFilter.value = label),
                              ))
                          .toList()),
                )),
            const SizedBox(height: 20),
            Obx(() {
              if (ctrl.isLoading.value) {
                return const Center(
                    child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(
                      color: Color(0xFF0A4226)),
                ));
              }
              return Column(
                  children: ctrl.filteredEvents
                      .map((e) => EventCard(
                          event: e,
                          balance: e.getUserBalance(ctrl.myUserId)))
                      .toList());
            }),
            const SizedBox(height: 100),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0A4226),
        onPressed: () {},
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF0A4226),
        unselectedItemColor: const Color(0xFF9E9E9E),
        currentIndex: 2,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Thống kê'),
          BottomNavigationBarItem(icon: Icon(Icons.people_alt), label: 'Sự kiện'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'Cài đặt'),
        ],
        onTap: (_) {},
      ),
    );
  }
}
