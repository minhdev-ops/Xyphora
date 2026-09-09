import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bindings/event_binding.dart';
import '../controllers/event_controller.dart';

class AddEventPage extends GetView<EventController> {
  const AddEventPage({super.key});

  static const Color _green = Color(0xFF0C3D2B);

  @override
  Widget build(BuildContext context) {
    EventBinding().dependencies();
    controller.resetCreateEditState();

    return Scaffold(
      backgroundColor: const Color(0xFFF4FAF6),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE2F0E5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                        color: _green,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Thêm sự kiện mới',
                      style: GoogleFonts.nunito(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: _green,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSectionLabel('BIỂU TƯỢNG SỰ KIỆN'),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: _cardDecoration(),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          children: EventController.emojis.map((emoji) {
                            final isSelected =
                                emoji == controller.selectedEmoji.value;
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 4,
                              ),
                              child: GestureDetector(
                                onTap: () => controller.selectEmoji(emoji),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFFE2F0E5)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected
                                          ? _green
                                          : Colors.transparent,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Text(
                                    emoji,
                                    style: const TextStyle(fontSize: 26),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildSectionLabel('TÊN SỰ KIỆN'),
                    const SizedBox(height: 10),
                    Container(
                      decoration: _cardDecoration(),
                      child: TextField(
                        controller: controller.titleController,
                        style: GoogleFonts.nunito(
                          color: _green,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          hintText: 'VD: Du lịch Đà Lạt',
                          hintStyle: GoogleFonts.nunito(
                            color: const Color(0xFF9E9E9E),
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildSectionLabel('MÔ TẢ'),
                    const SizedBox(height: 10),
                    Container(
                      decoration: _cardDecoration(),
                      child: TextField(
                        controller: controller.descriptionController,
                        maxLines: 3,
                        style: GoogleFonts.nunito(
                          color: _green,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Mô tả về sự kiện (không bắt buộc)',
                          hintStyle: GoogleFonts.nunito(
                            color: const Color(0xFF9E9E9E),
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    _buildSectionLabel('NGƯỜI THAM GIA'),
                    const SizedBox(height: 10),
                    Container(
                      decoration: _cardDecoration(),
                      child: Obx(
                        () => Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildParticipantRow(
                              name: 'Bạn',
                              isCreator: true,
                            ),
                            ...controller.participants.map(
                              (p) => _buildParticipantRow(
                                name: p.name,
                                isCreator: false,
                                onRemove: () =>
                                    controller.removeParticipant(p),
                              ),
                            ),
                            const Divider(
                              height: 1,
                              indent: 68,
                              endIndent: 16,
                              color: Color(0xFFE2F0E5),
                            ),
                            if (controller.isAddingParticipant.value)
                              _buildParticipantInput()
                            else
                              _buildAddParticipantRow(),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Obx(
                      () => ElevatedButton(
                        onPressed: controller.isCreating.value
                            ? null
                            : controller.createEvent,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _green,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: controller.isCreating.value
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Text(
                                'Tạo sự kiện',
                                style: GoogleFonts.nunito(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.02),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.nunito(
        color: const Color(0xFF5A7563),
        fontSize: 11,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _buildParticipantRow({
    required String name,
    required bool isCreator,
    VoidCallback? onRemove,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFFE2F0E5),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                name.isNotEmpty ? name.characters.first.toUpperCase() : '?',
                style: GoogleFonts.nunito(
                  color: _green,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: GoogleFonts.nunito(
                color: _green,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (isCreator)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFE2F0E5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Người tạo',
                style: GoogleFonts.nunito(
                  color: _green,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            )
          else
            GestureDetector(
              onTap: onRemove,
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: Color(0xFF9E9E9E),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAddParticipantRow() {
    return InkWell(
      onTap: controller.startAddParticipant,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFE2F0E5),
                shape: BoxShape.circle,
                border: Border.all(color: _green, width: 1.2),
              ),
              child: const Icon(
                Icons.add_rounded,
                color: _green,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Thêm người tham gia',
              style: GoogleFonts.nunito(
                color: _green,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParticipantInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 12, 12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller.participantController,
              autofocus: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => controller.confirmAddParticipant(),
              style: GoogleFonts.nunito(
                color: _green,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText: 'Nhập tên người tham gia',
                hintStyle: GoogleFonts.nunito(
                  color: const Color(0xFF9E9E9E),
                  fontSize: 14,
                ),
                isDense: true,
                filled: true,
                fillColor: const Color(0xFFF4FAF6),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => controller.confirmAddParticipant(),
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: _green,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: controller.cancelAddParticipant,
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(
                Icons.close_rounded,
                color: Color(0xFF9E9E9E),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}