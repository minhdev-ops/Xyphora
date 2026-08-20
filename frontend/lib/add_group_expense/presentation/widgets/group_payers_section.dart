import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

import '../controllers/add_group_expense_controller.dart';
import '../../domain/models/group_expense_model.dart';

class GroupPayersSection extends GetView<AddGroupExpenseController> {
  const GroupPayersSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle("NGƯỜI TRẢ"),
          const SizedBox(height: 16),
          Obx(() {
            if (controller.isLoadingMembers.value) {
              return const SizedBox(
                height: 44,
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF0C3D2B),
                    ),
                  ),
                ),
              );
            }

            if (controller.members.isEmpty) {
              return Text(
                'Chưa có thành viên trong sự kiện',
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  color: const Color(0xFF5A7563),
                ),
              );
            }

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                spacing: 12,
                children: [
                  for (final member in controller.members)
                    SizedBox(width: 52, child: _buildMember(controller, member)),
                ],
              ),
            );
          }),
          const SizedBox(height: 24),
          _sectionTitle("CÁCH CHIA"),
          const SizedBox(height: 12),
          _buildSplitBar(controller),
          const SizedBox(height: 16),
          Obx(() {
            if (controller.selectedSplitMode.value == 'equal') {
              return const SizedBox.shrink();
            }
            return _buildSplitInputs(controller);
          }),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.nunito(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
        color: const Color(0xFF1A4331),
      ),
    );
  }

  Widget _buildMember(
    AddGroupExpenseController controller,
    GroupMember member,
  ) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            GestureDetector(
              onTap: () => controller.togglePayer(member.id),
              child: Obx(
                () => Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(member.color),
                    border: Border.all(
                      width: 2,
                      color: controller.selectedPayers.contains(member.id)
                          ? const Color(0xFF0C3D2B)
                          : const Color(0xFFE2F0E5),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      member.name.characters.first,
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Obx(
              () => controller.selectedPayers.contains(member.id)
                  ? Positioned(
                      right: -2,
                      bottom: -2,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF0C3D2B),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          size: 11,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Obx(
          () => Text(
            member.isMe ? '${member.name} (bạn)' : member.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 12,
              fontWeight: controller.selectedPayers.contains(member.id)
                  ? FontWeight.w700
                  : FontWeight.w500,
              color: controller.selectedPayers.contains(member.id)
                  ? const Color(0xFF0C3D2B)
                  : const Color(0xFF5A7563),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSplitBar(AddGroupExpenseController controller) {
    return Container(
      height: 52,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: const Color(0xFF0C3D2B).withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final option in AddGroupExpenseController.splitOptions)
            Expanded(child: _buildSplitSegment(controller, option)),
        ],
      ),
    );
  }

  Widget _buildSplitSegment(
    AddGroupExpenseController controller,
    (String, String) option,
  ) {
    return Obx(() {
      final selected = controller.selectedSplitMode.value == option.$1;
      return GestureDetector(
        onTap: () => controller.selectSplitMode(option.$1),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF0C3D2B) : Colors.transparent,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Text(
            option.$2,
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : const Color(0xFF0C3D2B),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildSplitInputs(AddGroupExpenseController controller) {
    final mode = controller.selectedSplitMode.value;
    final isPercent = mode == 'percent';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              isPercent ? 'Phần trăm mỗi người' : 'Số tiền mỗi người',
              style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A4331),
              ),
            ),
            const Spacer(),
            Text(
              isPercent ? 'Tổng: ${_sumText(controller)}' : '',
              style: GoogleFonts.nunito(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF5A7563),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        for (final member in controller.members)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: Color(member.color),
                  child: Text(
                    member.name.characters.first,
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    member.isMe ? '${member.name} (bạn)' : member.name,
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1D1D1D),
                    ),
                  ),
                ),
                SizedBox(
                  width: 90,
                  child: TextField(
                    controller: controller.splitControllerFor(member.id),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    textAlign: TextAlign.right,
                    decoration: InputDecoration(
                      isDense: true,
                      suffixText: isPercent ? '%' : 'đ',
                      filled: true,
                      fillColor: const Color(0xFFE2F0E5),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  String _sumText(AddGroupExpenseController controller) {
    final mode = controller.selectedSplitMode.value;
    final total = controller.members.fold<double>(
      0,
      (sum, m) =>
          sum +
          (double.tryParse(
                controller.splitControllerFor(m.id).text.replaceAll(',', '.'),
              ) ??
              0),
    );
    return mode == 'percent' ? '${total.toStringAsFixed(1)}%' : '${total.round()} đ';
  }
}