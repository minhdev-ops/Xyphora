import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../add_expense/domain/models/expense_model.dart';
import '../../../add_expense/presentation/pages/edit_expense_page.dart';
import '../../../config/category_icons.dart';
import '../../../event_management/presentation/pages/event_detail_view.dart';
import '../../domain/models/expense_detail.dart';
import '../controllers/expense_detail_controller.dart';

class ExpenseDetailPage extends GetView<ExpenseDetailController> {
  final int expenseId;

  const ExpenseDetailPage({super.key, required this.expenseId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FAF6),
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
                color: Color(0xFFE2F0E5),
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
                final ctrl = Get.find<ExpenseDetailController>();
                _showOptionsSheet(context, ctrl);
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
        child: GetBuilder<ExpenseDetailController>(
          builder: (ctrl) {
            if (ctrl.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF0C3D2B)),
              );
            }

            final error = ctrl.errorMessage.value;
            if (error != null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: Color(0xFFC62828),
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        error,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF5A7563),
                        ),
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: ctrl.loadDetail,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0C3D2B),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            'Thử lại',
                            style: GoogleFonts.nunito(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            final detail = ctrl.detail.value;
            if (detail == null) {
              return const SizedBox.shrink();
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCard(ctrl, detail),
                  const SizedBox(height: 16),
                  if (detail.mySplitStatus != null) ...[
                    _buildMySplitBanner(ctrl, detail),
                    const SizedBox(height: 16),
                  ],
                  _buildEventCard(ctrl, detail),
                  const SizedBox(height: 16),
                  _buildInfoCard(ctrl, detail),
                  if (detail.splits.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildSplitsSection(ctrl, detail),
                  ],
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSummaryCard(ExpenseDetailController ctrl, ExpenseDetail detail) {
    final icon = categoryIconFor(detail.categoryIcon);
    final color = categoryColorFor(detail.categoryColor);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFE2F0E5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFCBE0D1), width: 1),
      ),
      child: Column(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: color, size: 34),
          ),
          const SizedBox(height: 16),
          Text(
            detail.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0C3D2B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            ctrl.formatCurrency(detail.amount),
            style: GoogleFonts.nunito(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF0C3D2B),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              if (detail.categoryName != null) _buildPill(detail.categoryName!),
              _buildPill(detail.splitMethodLabel),
              if (detail.expenseDate != null)
                _buildPill(ctrl.formatDate(detail.expenseDate)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFCBE0D1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: GoogleFonts.nunito(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF0C3D2B),
        ),
      ),
    );
  }

  Widget _buildMySplitBanner(
    ExpenseDetailController ctrl,
    ExpenseDetail detail,
  ) {
    final paid = detail.isMyPaid;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: paid ? const Color(0xFFE2F0E5) : const Color(0xFFFFE8D9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            paid ? Icons.check_circle_rounded : Icons.info_outline_rounded,
            color: paid ? const Color(0xFF0C3D2B) : const Color(0xFFE07B39),
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              paid
                  ? 'Bạn đã thanh toán ${ctrl.formatCurrency(detail.mySplitAmount ?? 0)}'
                  : 'Bạn nợ ${detail.payerName ?? 'người trả'} ${ctrl.formatCurrency(detail.mySplitAmount ?? 0)}',
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: paid ? const Color(0xFF0C3D2B) : const Color(0xFFB4561E),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(ExpenseDetailController ctrl, ExpenseDetail detail) {
    final isPersonal = detail.eventId == 0;
    final content = Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFE2F0E5),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Icon(
              isPersonal ? Icons.person_outline_rounded : Icons.event_rounded,
              color: const Color(0xFF0C3D2B),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sự kiện',
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF5A7563),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isPersonal
                      ? 'Cá nhân'
                      : (detail.eventTitle ?? 'Không xác định'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.nunito(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0C3D2B),
                  ),
                ),
              ],
            ),
          ),
          if (!isPersonal)
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Color(0xFF8A8A8A),
              size: 14,
            ),
        ],
      ),
    );

    if (isPersonal) return content;

    return GestureDetector(
      onTap: () {
        Get.to(
          () => const EventDetailView(),
          arguments: {'event_id': detail.eventId},
          transition: Transition.rightToLeft,
          duration: const Duration(milliseconds: 300),
        );
      },
      child: content,
    );
  }

  Widget _buildInfoCard(ExpenseDetailController ctrl, ExpenseDetail detail) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
          _buildInfoRow(
            icon: Icons.person_outline_rounded,
            label: 'Người trả',
            value: detail.payers.isEmpty
                ? (detail.payerParticipantId == null
                    ? 'Bạn'
                    : (detail.payerName ?? 'Không xác định'))
                : detail.payers
                    .map((p) => p.name)
                    .join(', '),
          ),
          if (detail.payers.isNotEmpty) ...[
            const Divider(height: 24, color: Color(0xFFF0F4F1)),
            ...detail.payers.map(
              (payer) => _buildInfoRow(
                icon: Icons.payments_outlined,
                label: '',
                value: ctrl.formatCurrency(payer.amount),
              ),
            ),
          ],
          if (detail.description != null &&
              detail.description!.trim().isNotEmpty) ...[
            const Divider(height: 24, color: Color(0xFFF0F4F1)),
            _buildInfoRow(
              icon: Icons.notes_rounded,
              label: 'Ghi chú',
              value: detail.description!,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF8AA494), size: 20),
        const SizedBox(width: 10),
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF5A7563),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0C3D2B),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSplitsSection(
    ExpenseDetailController ctrl,
    ExpenseDetail detail,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Chia tiền (${detail.splits.length} người)',
            style: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF0C3D2B),
            ),
          ),
        ),
        const SizedBox(height: 12),
        ...detail.splits.map(
          (split) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _buildSplitCard(ctrl, detail, split),
          ),
        ),
      ],
    );
  }

  Widget _buildSplitCard(
    ExpenseDetailController ctrl,
    ExpenseDetail detail,
    ExpenseSplitItem split,
  ) {
    final isMe = split.participantId == detail.myParticipantId;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFE2F0E5),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              split.initials,
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF0C3D2B),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        split.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.nunito(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0C3D2B),
                        ),
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 6),
                      _buildMiniBadge(
                        'Bạn',
                        const Color(0xFF0C3D2B),
                        const Color(0xFFE2F0E5),
                      ),
                    ],
                    if (split.isPayer) ...[
                      const SizedBox(width: 6),
                      _buildMiniBadge(
                        'Người trả',
                        const Color(0xFFB4561E),
                        const Color(0xFFFFE8D9),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  split.isPaid ? 'Đã thanh toán' : 'Chưa thanh toán',
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: split.isPaid
                        ? const Color(0xFF3E9B6E)
                        : const Color(0xFFE07B39),
                  ),
                ),
              ],
            ),
          ),
          Text(
            ctrl.formatCurrency(split.amount),
            style: GoogleFonts.nunito(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF0C3D2B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniBadge(String text, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: GoogleFonts.nunito(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: textColor,
        ),
      ),
    );
  }

  void _showOptionsSheet(BuildContext context, ExpenseDetailController ctrl) {
    final detail = ctrl.detail.value;
    if (detail == null) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFD0D0D0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.edit_rounded, color: Color(0xFF0C3D2B)),
                title: Text(
                  'Chỉnh sửa',
                  style: GoogleFonts.nunito(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0C3D2B),
                  ),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  final result = await Get.to<ExpenseModel>(
                    () => const EditExpensePage(),
                    arguments: {
                      'id': '${detail.expenseId}',
                      'title': detail.title,
                      'amount': detail.amount,
                      'currency': detail.currency,
                      'category': detail.categoryName ?? '',
                      'note': detail.description ?? '',
                      'date': detail.expenseDate ?? '',
                      'event_id': detail.eventId,
                      'event_title': detail.eventTitle,
                    },
                    transition: Transition.rightToLeft,
                    duration: const Duration(milliseconds: 300),
                  );
                  if (result != null) {
                    ctrl.loadDetail();
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded, color: Color(0xFFD32F2F)),
                title: Text(
                  'Xóa',
                  style: GoogleFonts.nunito(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFD32F2F),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(context, ctrl, detail);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    ExpenseDetailController ctrl,
    ExpenseDetail detail,
  ) {
    Get.defaultDialog(
      title: 'Xóa chi tiêu',
      titleStyle: GoogleFonts.nunito(
        fontSize: 18,
        fontWeight: FontWeight.w900,
        color: const Color(0xFF0C3D2B),
      ),
      middleText: 'Bạn có chắc chắn muốn xóa "${detail.title}"?',
      middleTextStyle: GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF5A7563),
      ),
      textCancel: 'Hủy',
      textConfirm: 'Xóa',
      confirmTextColor: Colors.white,
      buttonColor: const Color(0xFFD32F2F),
      onConfirm: () async {
        Navigator.pop(context);
        final success = await ctrl.deleteExpense();
        if (success) {
          Get.back();
          Get.snackbar(
            'Thành công',
            'Đã xóa chi tiêu',
            backgroundColor: const Color(0xFFD32F2F).withValues(alpha: 0.8),
            colorText: Colors.white,
          );
        } else {
          Get.snackbar(
            'Lỗi',
            'Không thể xóa chi tiêu',
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
          );
        }
      },
    );
  }
}
