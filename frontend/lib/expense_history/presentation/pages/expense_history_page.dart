import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../config/app_theme.dart';
import '../../../config/app_format.dart';
import '../controllers/expense_history_controller.dart';
import '../widgets/expense_history_filter_bar.dart';
import '../widgets/expense_history_item_card.dart';
import '../widgets/expense_history_summary.dart';

class ExpenseHistoryPage extends GetView<ExpenseHistoryController> {
  const ExpenseHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.cardBg,
                    radius: 20,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons.arrow_back,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      onPressed: () => Get.back(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Lịch sử chi tiêu',
                    style: AppTextStyles.titleLarge,
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: ExpenseHistorySummary(),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: ExpenseHistoryFilterBar(),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Obx(
                () {
                  if (controller.isLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  }

                  if (controller.hasError.value) {
                    return _ErrorState(
                      message: controller.errorMessage.value,
                      onRetry: controller.refresh,
                    );
                  }

                  if (controller.items.isEmpty) {
                    return _EmptyState();
                  }

                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: controller.refresh,
                    child: _ExpenseListView(controller: controller),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpenseListView extends StatelessWidget {
  final ExpenseHistoryController controller;

  const _ExpenseListView({required this.controller});

  String _formatDateHeader(String? date) {
    if (date == null) return 'Không rõ ngày';
    final parts = date.split('-');
    if (parts.length != 3) return date;
    final day = int.tryParse(parts[2]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[0]);
    if (day == null || month == null || year == null) return date;
    return AppFormat.date(DateTime(year, month, day));
  }

  @override
  Widget build(BuildContext context) {
    final items = controller.items;
    final dates = <String>[];
    for (final item in items) {
      final date = item.expenseDate ?? '';
      if (!dates.contains(date)) dates.add(date);
    }

    final rows = <Widget>[];
    for (final date in dates) {
      rows.add(
        Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 8),
          child: Text(
            _formatDateHeader(date),
            style: GoogleFonts.nunito(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
        ),
      );
      for (final item in items.where((e) => (e.expenseDate ?? '') == date)) {
        rows.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ExpenseHistoryItemCard(item: item),
          ),
        );
      }
    }
    rows.add(
      Obx(
        () => controller.isLoadingMore.value
            ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                  ),
                ),
              )
            : const SizedBox(height: 12),
      ),
    );

    return ListView.builder(
      controller: controller.scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
      itemCount: rows.length,
      itemBuilder: (context, index) => rows[index],
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.receipt_long_rounded,
            size: 56,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 12),
          Text(
            'Chưa có chi tiêu nào',
            style: AppTextStyles.titleMedium,
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            size: 48,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySecondary,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: Text(
              'Thử lại',
              style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}