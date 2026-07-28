import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../domain/models/spending_model.dart';

class SpendingDetailPage extends StatelessWidget {
  final SpendingModel spending;

  const SpendingDetailPage({super.key, required this.spending});

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FAF6), // Match background color
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leadingWidth: 60,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFFE2F0E5), // Light green circular background
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Color(0xFF0C3D2B),
                size: 16,
              ),
            ),
          ),
        ),
        title: Text(
          'Chi tiết chi tiêu',
          style: GoogleFonts.nunito(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF0C3D2B),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () {
                Get.snackbar('Tùy chọn', 'Chức năng đang được phát triển');
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFFE2F0E5),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.more_vert_rounded,
                  color: Color(0xFF0C3D2B),
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Green Summary Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2F0E5), // Light green background
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFFCBE0D1),
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon Container
                    Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        spending.icon,
                        color: spending.themeColor,
                        size: 34,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Title
                    Text(
                      spending.title,
                      style: GoogleFonts.nunito(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0C3D2B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Amount
                    Text(
                      _formatCurrency(spending.amount),
                      style: GoogleFonts.nunito(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF0C3D2B),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Category Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFCBE0D1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        spending.category,
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0C3D2B),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 2. Info Detail Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
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
                child: Column(
                  children: [
                    // Row 1: Ngày
                    _buildDetailRow(
                      icon: Icons.calendar_month_outlined,
                      label: 'NGÀY',
                      value: spending.date,
                    ),
                    const Divider(
                      height: 24,
                      color: Color(0xFFECEFF1),
                      thickness: 1,
                    ),
                    // Row 2: Phương thức
                    _buildDetailRow(
                      icon: Icons.wallet_giftcard_outlined,
                      label: 'PHƯƠNG THỨC',
                      value: spending.paymentMethod,
                    ),
                    const Divider(
                      height: 24,
                      color: Color(0xFFECEFF1),
                      thickness: 1,
                    ),
                    // Row 3: Ghi chú
                    _buildDetailRow(
                      icon: Icons.chat_bubble_outline_rounded,
                      label: 'GHI CHÚ',
                      value: spending.note.isNotEmpty
                          ? spending.note
                          : 'Không có ghi chú',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 3. Action Buttons
              // Button 1: Chỉnh sửa chi tiêu
              GestureDetector(
                onTap: () {
                  Get.snackbar(
                    'Chỉnh sửa',
                    'Tính năng chỉnh sửa chi tiêu đang phát triển',
                    backgroundColor: const Color(0xFF0C3D2B).withValues(alpha: 0.8),
                    colorText: Colors.white,
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF0C3D2B),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.edit_note_rounded,
                        color: Color(0xFF0C3D2B),
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Chỉnh sửa chi tiêu',
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0C3D2B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Button 2: Xoá chi tiêu
              GestureDetector(
                onTap: () {
                  Get.defaultDialog(
                    title: 'Xóa chi tiêu',
                    middleText: 'Bạn có chắc chắn muốn xóa khoản chi tiêu này?',
                    textCancel: 'Hủy',
                    textConfirm: 'Xóa',
                    confirmTextColor: Colors.white,
                    buttonColor: const Color(0xFFD32F2F),
                    onConfirm: () {
                      Get.back(); // close dialog
                      Get.back(); // return to dashboard
                      Get.snackbar(
                        'Thành công',
                        'Đã xóa khoản chi tiêu thành công',
                        backgroundColor: const Color(0xFFD32F2F).withValues(alpha: 0.8),
                        colorText: Colors.white,
                      );
                    },
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFBEBEB),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFEFD7D7),
                      width: 1,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Xoá chi tiêu',
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFD32F2F),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Grey round container for icon
        Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            color: Color(0xFFEDEFEF),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(
            icon,
            color: const Color(0xFF5A7563),
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.nunito(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF8A8A8A),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: GoogleFonts.nunito(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0C3D2B),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
