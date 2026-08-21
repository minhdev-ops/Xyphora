import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../config/app_theme.dart';
import '../../../config/app_format.dart';
import '../../../add_expense/presentation/bindings/add_expense_binding.dart';
import '../../../add_expense/presentation/pages/add_expense_page.dart';
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
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: CircleAvatar(
            backgroundColor: AppColors.cardBg,
            radius: 20,
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.arrow_back,
                  color: AppColors.primary, size: 20),
              onPressed: () => Get.back(),
            ),
          ),
        ),
        leadingWidth: 56,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: CircleAvatar(
              backgroundColor: AppColors.cardBg,
              radius: 20,
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.person_add_alt,
                    color: AppColors.primary, size: 20),
                onPressed: () {},
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(
              backgroundColor: AppColors.cardBg,
              radius: 20,
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.more_vert,
                    color: AppColors.primary, size: 20),
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
              backgroundColor: AppColors.primary,
              onPressed: () {
                if (isPhotoTab) {
                  Get.snackbar(
                    'Thêm ảnh',
                    'Tính năng thêm ảnh đang phát triển',
                    backgroundColor: AppColors.primary,
                    colorText: Colors.white,
                    duration: const Duration(seconds: 2),
                  );
                } else {
                  final eventId = controller.eventId;
                  Get.to(
                    () => ExpensePage(),
                    binding: AddExpenseBinding(),
                    arguments: {
                      'event_id': eventId,
                      'event_title': controller.event?.title ?? 'Sự kiện',
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
              style: AppTextStyles.caption,
            ),
          ],
        );
      }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class _EventInfo extends StatelessWidget {
  final EventModel? event;

  const _EventInfo({required this.event});

  @override
  Widget build(BuildContext context) {
    if (event == null) {
      return Column(
        children: [
          const Text('🎉', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 8),
          Text('Chi tiết sự kiện', style: AppTextStyles.heading2),
        ],
      );
    }
    final dateStr =
        '${event!.participants.length} thành viên, ${AppFormat.monthYear(event!.createdAt)}';

    return Column(
      children: [
        Text(event!.emoji, style: const TextStyle(fontSize: 40)),
        const SizedBox(height: 8),
        Text(
          event!.title,
          style: AppTextStyles.heading2,
        ),
        const SizedBox(height: 4),
        Text(
          dateStr,
          style: AppTextStyles.caption,
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
          color: AppColors.inputBg,
          borderRadius: AppRadius.rPill,
          border: Border.all(color: AppColors.borderLight),
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
                            ? AppColors.primary
                            : Colors.transparent,
                        borderRadius: AppRadius.rPill,
                      ),
                      child: Text(
                        labels[i],
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(
                          color: isActive
                              ? Colors.white
                              : AppColors.primary,
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
