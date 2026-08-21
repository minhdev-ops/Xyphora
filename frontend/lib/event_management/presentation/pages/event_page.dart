import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/app_theme.dart';
import '../../../config/app_format.dart';
import '../bindings/event_binding.dart';
import '../controllers/event_controller.dart';
import '../widgets/summary_card.dart';
import '../widgets/filter_chip.dart';
import '../widgets/event_card.dart';
import 'event_detail_view.dart';
import 'add_event_page.dart';
import '../../../home_dashboard/presentation/widgets/custom_bottom_nav_bar.dart';

class EventPage extends GetView<EventController> {
  const EventPage({super.key});

  @override
  Widget build(BuildContext context) {
    EventBinding().dependencies();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Sự kiện',
            style: AppTextStyles.heading1),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: CircleAvatar(
              backgroundColor: AppColors.cardBg,
              radius: 20,
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.search,
                    color: AppColors.primary, size: 20),
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
                              amount: '+${AppFormat.currency(controller.getTotalOwed())}',
                              amountColor: AppColors.success),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: SummaryCard(
                              label: 'Bạn còn nợ',
                              amount: '-${AppFormat.currency(controller.getTotalDebt())}',
                              amountColor: AppColors.error),
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
                      color: AppColors.primary),
                ));
              }
              return ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: controller.filteredEvents
                    .map((e) => EventCard(
                        event: e,
                        balance: e.getUserBalance(controller.myUserId),
                        onTap: () => Get.to(
                          () => const EventDetailView(),
                          arguments: {'event_id': 10},
                        )))
                    .toList(),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => Get.to(() => const AddEventPage()),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: const CustomBottomNavBar(initialIndex: 2),
    );
  }
}
