import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../auth/domain/models/user.dart';
import '../../domain/models/event_model.dart';
import '../../domain/models/participant_model.dart';
import '../bindings/event_binding.dart';
import '../controllers/event_controller.dart';

class AddEventPage extends StatefulWidget {
  const AddEventPage({super.key});

  @override
  State<AddEventPage> createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  static const Color _green = Color(0xFF0C3D2B);
  static const List<String> _emojis = [
    '🎉', '⛰️', '🍽️', '🎂', '🏖️', '🏠', '🎊', '⚽',
  ];

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedEmoji = '🎉';

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _createEvent() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      Get.snackbar(
        'Lỗi',
        'Vui lòng nhập tên sự kiện',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    final controller = Get.find<EventController>();
    final eventId = DateTime.now().millisecondsSinceEpoch.toString();

    final event = EventModel(
      id: eventId,
      ownerId: controller.myUserId,
      emoji: _selectedEmoji,
      title: title,
      description: _descriptionController.text.trim(),
      createdAt: DateTime.now(),
      participants: [
        ParticipantModel(
          id: '${eventId}_p1',
          eventId: eventId,
          userId: controller.myUserId,
          user: UserModel(
            id: controller.myUserId,
            name: 'Bạn',
            email: 'ban@email.com',
          ),
        ),
      ],
      expenses: [],
    );

    controller.addEvent(event);
    Get.back();
    Get.snackbar(
      'Thành công',
      'Đã tạo sự kiện mới',
      backgroundColor: _green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    EventBinding().dependencies();

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
                          children: _emojis.map((emoji) {
                            final isSelected = emoji == _selectedEmoji;
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 4,
                              ),
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _selectedEmoji = emoji),
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
                        controller: _titleController,
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
                        controller: _descriptionController,
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
                    ElevatedButton(
                      onPressed: _createEvent,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _green,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Tạo sự kiện',
                        style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
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
}
