import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../../config/app_theme.dart';
import '../../../config/app_format.dart';
import '../../../add_expense/presentation/bindings/add_expense_binding.dart';
import '../../../add_expense/presentation/pages/add_expense_page.dart';
import '../../../category_list/presentation/bindings/category_list_binding.dart';
import '../../../category_list/presentation/pages/category_list_page.dart';
import '../controllers/dashboard_controller.dart';
import '../../domain/models/transaction_model.dart';
import '../../domain/models/spending_model.dart';
import '../widgets/balance_card.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../../../expense_detail/presentation/bindings/expense_detail_binding.dart';
import '../../../expense_detail/presentation/pages/expense_detail_page.dart';
import '../../../notification/presentation/pages/notification_page.dart';

class HomeDashboardPage extends GetView<DashboardController> {
  const HomeDashboardPage({super.key});

  Color _getAvatarColor(int index) {
    final colors = [
      const Color(0xFF083C25),
      const Color(0xFF004D40),
      const Color(0xFF4A6B82),
      const Color(0xFF2E7D32),
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      bottomNavigationBar: const CustomBottomNavBar(initialIndex: 0),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(
            () => ExpensePage(),
            binding: AddExpenseBinding(),
            transition: Transition.rightToLeft,
            duration: const Duration(milliseconds: 300),
          );
        },
        backgroundColor: AppColors.primary,
        shape: const CircleBorder(),
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildHeader(controller),
              const SizedBox(height: 24),
              const BalanceCard(),
              const SizedBox(height: 24),
              _buildTabSelector(controller),
              const SizedBox(height: 20),
              // Dynamic view switcher based on tab selection
              GetBuilder<DashboardController>(
                builder: (ctrl) {
                  if (ctrl.selectedTab.value == 'my_spending') {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSpendingSummaryCard(ctrl),
                        const SizedBox(height: 16),
                        _buildSpendingList(ctrl),
                      ],
                    );
                  } else {
                    return _buildEventList(ctrl);
                  }
                },
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(DashboardController controller) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Xin chào,',
              style: AppTextStyles.bodySecondary,
            ),
            const SizedBox(height: 4),
            GetBuilder<DashboardController>(
              builder: (ctrl) => Text(
                ctrl.userName.value,
                style: AppTextStyles.heading2,
              ),
            ),
          ],
        ),
        const Spacer(),
        _buildHeaderIcon(
          icon: Icons.notifications_none_rounded,
          onTap: () {
            Get.to(
              () => const NotificationPage(),
              transition: Transition.upToDown,
              duration: const Duration(milliseconds: 350),
            );
          },
        ),
        const SizedBox(width: 12),
        _buildHeaderIcon(
          icon: Icons.category_rounded,
          onTap: () {
            Get.to(
              () => const CategoryListPage(),
              binding: CategoryListBinding(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildHeaderIcon({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.borderLight.withValues(alpha: 0.8),
            width: 1,
          ),
          boxShadow: AppShadow.card,
        ),
        child: Icon(icon, color: AppColors.textSecondary, size: 22),
      ),
    );
  }

  Widget _buildTabSelector(DashboardController controller) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: AppRadius.rPill,
        boxShadow: AppShadow.card,
      ),
      child: GetBuilder<DashboardController>(
        builder: (ctrl) {
          final currentTab = ctrl.selectedTab.value;
          return Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => ctrl.changeTab('all'),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: currentTab == 'all'
                          ? AppColors.primary
                          : Colors.transparent,
                      borderRadius: AppRadius.rPill,
                    ),
                    child: Text(
                      'Tất cả',
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: currentTab == 'all'
                            ? Colors.white
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => ctrl.changeTab('my_spending'),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: currentTab == 'my_spending'
                          ? AppColors.primary
                          : Colors.transparent,
                      borderRadius: AppRadius.rPill,
                    ),
                    child: Text(
                      'Chi tiêu của tôi',
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: currentTab == 'my_spending'
                            ? Colors.white
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSpendingSummaryCard(DashboardController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: AppRadius.rXl,
        boxShadow: AppShadow.cardSoft,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tổng tháng này',
                style: AppTextStyles.subtitle,
              ),
              const SizedBox(height: 4),
              Text(
                AppFormat.currency(controller.monthlySpendingTotal.value),
                style: AppTextStyles.amountLarge,
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Số khoản',
                style: AppTextStyles.subtitle,
              ),
              const SizedBox(height: 4),
              Text(
                '${controller.spendingCount.value}',
                style: AppTextStyles.amountLarge,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpendingList(DashboardController controller) {
    final list = controller.spendings;
    if (list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 40.0),
          child: Text(
            'Không có dữ liệu chi tiêu',
            style: AppTextStyles.titleMedium,
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final SpendingModel item = list[index];
        return GestureDetector(
          onTap: () => Get.to(
            () => ExpenseDetailPage(expenseId: item.expenseId),
            binding: ExpenseDetailBinding(item.expenseId),
            transition: Transition.rightToLeft,
            duration: const Duration(milliseconds: 300),
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: AppRadius.rXl,
              boxShadow: AppShadow.cardSoft,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: item.bgThemeColor,
                    borderRadius: AppRadius.rMd,
                  ),
                  alignment: Alignment.center,
                  child: Icon(item.icon, color: item.themeColor, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: AppTextStyles.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: item.bgThemeColor,
                              borderRadius: AppRadius.rXs,
                            ),
                            child: Text(
                              item.category,
                              style: AppTextStyles.badge,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item.date,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.caption,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppFormat.currency(item.amount),
                      style: AppTextStyles.amountSmall,
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: AppColors.textTertiary,
                      size: 12,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEventList(DashboardController controller) {
    final list = controller.transactions;
    if (list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 40.0),
          child: Text(
            'Không có dữ liệu hiển thị',
            style: AppTextStyles.titleMedium,
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return _buildEventCard(list[index]);
      },
    );
  }

  Widget _buildEventCard(TransactionModel tx) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: AppRadius.rXl,
        boxShadow: AppShadow.cardSoft,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.title,
                  style: AppTextStyles.title,
                ),
                const SizedBox(height: 4),
                Text(
                  '${tx.date} - ${tx.memberCount} thành viên',
                  style: AppTextStyles.subtitle,
                ),
                const SizedBox(height: 12),
                _buildAvatarRow(tx),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildPriceInfo(tx),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.textTertiary,
                size: 14,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarRow(TransactionModel tx) {
    List<Widget> avatarWidgets = [];
    final limit = 4;
    final displayCount = tx.memberInitials.length > limit
        ? limit
        : tx.memberInitials.length;

    for (int i = 0; i < displayCount; i++) {
      avatarWidgets.add(
        Positioned(
          left: i * 18.0,
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: _getAvatarColor(i),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1.5),
            ),
            alignment: Alignment.center,
            child: Text(
              tx.memberInitials[i],
              style: GoogleFonts.nunito(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
        ),
      );
    }

    if (tx.memberCount > limit) {
      avatarWidgets.add(
        Positioned(
          left: limit * 18.0,
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.primarySubtle,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1.5),
            ),
            alignment: Alignment.center,
            child: Text(
              '+${tx.memberCount - limit}',
              style: GoogleFonts.nunito(
                fontSize: 9,
                fontWeight: FontWeight.w900,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 24,
      width: (displayCount + (tx.memberCount > limit ? 1 : 0)) * 18.0 + 8.0,
      child: Stack(clipBehavior: Clip.none, children: avatarWidgets),
    );
  }

  Widget _buildPriceInfo(TransactionModel tx) {
    if (tx.status == TransactionStatus.done) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primarySubtle,
          borderRadius: AppRadius.rSm,
        ),
        child: Text(
          'Đã xong',
          style: GoogleFonts.nunito(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
      );
    }

    final isBorrow = tx.status == TransactionStatus.borrow;
    final color = isBorrow ? AppColors.error : AppColors.primary;
    final sign = isBorrow ? '-' : '+';
    final amountText = AppFormat.currency(tx.amount);
    final statusText = isBorrow ? 'bạn nợ' : 'bạn được nhận';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '$sign$amountText',
          style: GoogleFonts.nunito(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          statusText,
          style: AppTextStyles.caption,
        ),
      ],
    );
  }
}
