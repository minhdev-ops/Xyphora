import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../add_group_expense/presentation/bindings/add_group_expense_binding.dart';
import '../../../add_group_expense/presentation/pages/add_group_expense_page.dart';
import '../controllers/event_detail_controller.dart';
import '../widgets/expenses_tab.dart';
import '../widgets/balances_tab.dart';
import '../widgets/photos_tab.dart';
import '../../domain/models/event_model.dart';

class EventDetailView extends GetView<EventDetailController> {
  const EventDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(EventDetailController());

    return Scaffold(
      backgroundColor: const Color(0xFFF2F7F4),
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              radius: 20,
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.person_add_alt,
                    color: Color(0xFF0A4226), size: 20),
                onPressed: () {},
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              radius: 20,
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.more_vert,
                    color: Color(0xFF0A4226), size: 20),
                onPressed: () {},
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _EventInfo(event: controller.event),
          const SizedBox(height: 20),
          _CustomTabBar(currentTab: controller.currentTab, onSwitch: controller.switchTab),
          const SizedBox(height: 8),
          Expanded(
            child: Obx(() {
              switch (controller.currentTab.value) {
                case 0:
                  return const ExpensesTab();
                case 1:
                  return const BalancesTab();
                case 2:
                  return const PhotosTab();
                default:
                  return const ExpensesTab();
              }
            }),
          ),
        ],
      ),
      floatingActionButton: Obx(() {
        final isPhotoTab = controller.currentTab.value == 2;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton(
              backgroundColor: const Color(0xFF0A4226),
              onPressed: () {
                if (isPhotoTab) {
                  Get.snackbar(
                    'Thêm ảnh',
                    'Chức năng thêm ảnh đang phát triển',
                    backgroundColor: const Color(0xFF0A4226),
                    colorText: Colors.white,
                    duration: const Duration(seconds: 2),
                  );
                } else {
                  final eventId = controller.eventId;
                  Get.to(
                    () => GroupExpensePage(),
                    binding: AddGroupExpenseBinding(),
                    arguments: {
                      'event_id': eventId,
                      'event_title': controller.event.title,
                    },
                  )?.then((result) {
                    if (result == true) {
                      controller.loadExpenses();
                    }
                  });
                }
              },
              child: Icon(
                isPhotoTab ? Icons.camera_alt : Icons.add,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isPhotoTab ? 'Thêm ảnh' : 'Thêm chi tiêu',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF0A4226),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class _EventInfo extends StatelessWidget {
  final EventModel event;

  const _EventInfo({required this.event});

  @override
  Widget build(BuildContext context) {
    const months = [
      'tháng 1', 'tháng 2', 'tháng 3', 'tháng 4',
      'tháng 5', 'tháng 6', 'tháng 7', 'tháng 8',
      'tháng 9', 'tháng 10', 'tháng 11', 'tháng 12',
    ];
    final dateStr =
        '${event.participants.length} thành viên • ${months[event.createdAt.month - 1]}, ${event.createdAt.year}';

    return Column(
      children: [
        Text(event.emoji, style: const TextStyle(fontSize: 40)),
        const SizedBox(height: 8),
        Text(
          event.title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0A4226),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          dateStr,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF9E9E9E),
          ),
        ),
      ],
    );
  }
}

class _CustomTabBar extends StatelessWidget {
  final RxInt currentTab;
  final void Function(int) onSwitch;

  const _CustomTabBar({
    required this.currentTab,
    required this.onSwitch,
  });

  @override
  Widget build(BuildContext context) {
    const labels = ['Chi tiêu', 'Số dư', 'Ảnh'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F9F8),
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Obx(() => Row(
              children: List.generate(labels.length, (i) {
                final isActive = currentTab.value == i;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => onSwitch(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isActive
                            ? const Color(0xFF0A4226)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Text(
                        labels[i],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isActive
                              ? Colors.white
                              : const Color(0xFF0A4226),
                          fontSize: 14,
                          fontWeight:
                              isActive ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            )),
      ),
    );
  }
}
