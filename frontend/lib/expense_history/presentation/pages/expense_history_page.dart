import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/expense_history_controller.dart';
import '../widgets/expense_history_filter_bar.dart';
import '../widgets/expense_history_item_card.dart';
import '../widgets/expense_history_summary.dart';

class ExpenseHistoryPage extends GetView<ExpenseHistoryController> {
  const ExpenseHistoryPage({super.key});

  static const List<String> _months = [
    'tháng 1', 'tháng 2', 'tháng 3', 'tháng 4', 'tháng 5', 'tháng 6',
    'tháng 7', 'tháng 8', 'tháng 9', 'tháng 10', 'tháng 11', 'tháng 12',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F7F4),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 20,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFF0A4226),
                        size: 20,
                      ),
                      onPressed: () => Get.back(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Lịch sử chi tiêu',
                    style: GoogleFonts.nunito(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0A4226),
                    ),
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
                        color: Color(0xFF0C3D2B),
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
                    color: const Color(0xFF0C3D2B),
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
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[0]);
    final day = int.tryParse(parts[2]);
    if (month == null || year == null || day == null) return date;
    return '$day ${ExpenseHistoryPage._months[month - 1]}, $year';
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
              color: const Color(0xFF0A4226),
            ),
          ),
        ),
      );
      for (final item in items.where((e) => (e.expenseDate ?? '') == date)) {
        rows.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ExpenseHistoryItemCard(
              item: item,
              formatCurrency: controller.formatCurrency,
            ),
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
                      color: Color(0xFF0C3D2B),
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
            color: Color(0xFFB8CFC0),
          ),
          const SizedBox(height: 12),
          Text(
            'Chưa có chi tiêu nào',
            style: GoogleFonts.nunito(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF5A7563),
            ),
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
            color: Color(0xFFB8CFC0),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF5A7563),
              ),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0C3D2B),
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