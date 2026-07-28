import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';
import '../../domain/models/transaction_model.dart';
import '../widgets/balance_card.dart';
import '../widgets/custom_bottom_nav_bar.dart';

class HomeDashboardPage extends StatelessWidget {
  const HomeDashboardPage({super.key});

  String _formatCurrency(double amount) {
    final absAmount = amount.abs().toInt();
    final str = absAmount.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(str[i]);
    }
    return '${buffer.toString()}đ';
  }

  Color _getAvatarColor(int index) {
    final colors = [
      const Color(0xFF083C25), // Dark Green 'B'
      const Color(0xFF004D40), // Dark Teal 'M'
      const Color(0xFF4A6B82), // Slate Blue 'L'
      const Color(0xFF2E7D32), // Forest Green 'H'
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final DashboardController controller = Get.put(DashboardController());

    return Scaffold(
      backgroundColor: const Color(0xFFF4FAF6), // Pale light-green background
      bottomNavigationBar: const CustomBottomNavBar(initialIndex: 0),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.snackbar(
            'Thêm sự kiện',
            'Chức năng tạo sự kiện tài chính mới đang phát triển',
            backgroundColor: const Color(0xFF0C3D2B).withValues(alpha: 0.8),
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );
        },
        backgroundColor: const Color(0xFF0C3D2B), // Deep Green FAB
        shape: const CircleBorder(),
        elevation: 4,
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 32,
        ),
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
              _buildEventList(controller),
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
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF5A7563),
              ),
            ),
            const SizedBox(height: 4),
            Obx(() => Text(
                  '${controller.userName.value} 👋',
                  style: GoogleFonts.nunito(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF0C3D2B),
                  ),
                )),
          ],
        ),
        const Spacer(),
        // Notification Circle Button
        _buildHeaderIcon(
          icon: Icons.notifications_none_rounded,
          onTap: () {
            Get.snackbar('Thông báo', 'Bạn không có thông báo mới');
          },
        ),
        const SizedBox(width: 12),
        // Settings Circle Button
        _buildHeaderIcon(
          icon: Icons.settings_outlined,
          onTap: () {
            Get.snackbar('Cài đặt nhanh', 'Phần cài đặt nhanh đang phát triển');
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
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFFE0E0E0).withValues(alpha: 0.8),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: const Color(0xFF5A7563),
          size: 22,
        ),
      ),
    );
  }

  Widget _buildTabSelector(DashboardController controller) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Obx(() {
        final currentTab = controller.selectedTab.value;
        return Row(
          children: [
            // Tab "Tất cả"
            Expanded(
              child: GestureDetector(
                onTap: () => controller.changeTab('all'),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: currentTab == 'all'
                        ? const Color(0xFF0C3D2B)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Text(
                    'Tất cả',
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: currentTab == 'all'
                          ? Colors.white
                          : const Color(0xFF5A7563),
                    ),
                  ),
                ),
              ),
            ),
            // Tab "Chi tiêu của tôi"
            Expanded(
              child: GestureDetector(
                onTap: () => controller.changeTab('my_spending'),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: currentTab == 'my_spending'
                        ? const Color(0xFF0C3D2B)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Text(
                    'Chi tiêu của tôi',
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: currentTab == 'my_spending'
                          ? Colors.white
                          : const Color(0xFF5A7563),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildEventList(DashboardController controller) {
    return Obx(() {
      final list = controller.filteredTransactions;
      if (list.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 40.0),
            child: Text(
              'Không có dữ liệu hiển thị',
              style: GoogleFonts.nunito(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF5A7563),
              ),
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
    });
  }

  Widget _buildEventCard(TransactionModel tx) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Event Title & Member Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.title,
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0C3D2B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${tx.date} • ${tx.memberCount} thành viên',
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF5A7563),
                  ),
                ),
                const SizedBox(height: 12),
                // Stack of Avatars
                _buildAvatarRow(tx),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Price Info & Arrow
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildPriceInfo(tx),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Color(0xFF8A8A8A),
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
              color: const Color(0xFFD9E8DF),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1.5),
            ),
            alignment: Alignment.center,
            child: Text(
              '+${tx.memberCount - limit}',
              style: GoogleFonts.nunito(
                fontSize: 9,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF0C3D2B),
              ),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 24,
      width: (displayCount + (tx.memberCount > limit ? 1 : 0)) * 18.0 + 8.0,
      child: Stack(
        clipBehavior: Clip.none,
        children: avatarWidgets,
      ),
    );
  }

  Widget _buildPriceInfo(TransactionModel tx) {
    if (tx.status == TransactionStatus.done) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFD9E8DF), // Subtle light green background
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'Đã xong',
          style: GoogleFonts.nunito(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0C3D2B),
          ),
        ),
      );
    }

    final isBorrow = tx.status == TransactionStatus.borrow;
    final color = isBorrow ? const Color(0xFFD32F2F) : const Color(0xFF0C3D2B);
    final sign = isBorrow ? '-' : '+';
    final amountText = _formatCurrency(tx.amount);
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
          style: GoogleFonts.nunito(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF5A7563),
          ),
        ),
      ],
    );
  }
}
