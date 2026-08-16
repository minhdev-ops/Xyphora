import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../config/category_icons.dart';

const List<Color> categoryColorOptions = [
  Color(0xFFEF4444),
  Color(0xFFF97316),
  Color(0xFFF59E0B),
  Color(0xFF22C55E),
  Color(0xFF10B981),
  Color(0xFF06B6D4),
  Color(0xFF3B82F6),
  Color(0xFF8B5CF6),
  Color(0xFFEC4899),
  Color(0xFF64748B),
];

class CategoryFormSheet extends StatefulWidget {
  final String? initialName;
  final String? initialIcon;
  final String? initialColor;

  const CategoryFormSheet({
    super.key,
    this.initialName,
    this.initialIcon,
    this.initialColor,
  });

  @override
  State<CategoryFormSheet> createState() => _CategoryFormSheetState();
}

class _CategoryFormSheetState extends State<CategoryFormSheet> {
  late final TextEditingController _nameController;
  late String _selectedIcon;
  late String _selectedColor;
  final bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _selectedIcon = widget.initialIcon ?? categoryIconMap.keys.first;
    _selectedColor = widget.initialColor?.replaceFirst('#', '') ??
        _colorToHex(categoryColorOptions.first);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String _colorToHex(Color color) {
    final hex = color.toARGB32().toRadixString(16).substring(2).toUpperCase();
    return '#$hex';
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      Get.snackbar(
        'Lỗi',
        'Vui lòng nhập tên danh mục',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }
    if (_submitting) return;
    Navigator.pop(context, {
      'name': name,
      'icon': _selectedIcon,
      'color': _selectedColor,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.initialName == null ? 'Thêm danh mục' : 'Sửa danh mục',
            style: GoogleFonts.nunito(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF0C3D2B),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            autofocus: widget.initialName == null,
            maxLength: 50,
            decoration: InputDecoration(
              hintText: 'Tên danh mục (vd: Mua sắm)',
              hintStyle: GoogleFonts.nunito(
                color: const Color(0xFF5A7563),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              counterText: '',
              filled: true,
              fillColor: const Color(0xFFE2F0E5),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Biểu tượng',
            style: GoogleFonts.nunito(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF5A7563),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: categoryIconMap.entries.map((entry) {
              final selected = entry.key == _selectedIcon;
              return GestureDetector(
                onTap: () => setState(() => _selectedIcon = entry.key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFF0C3D2B)
                        : const Color(0xFFE2F0E5),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    entry.value,
                    color: selected ? Colors.white : const Color(0xFF0C3D2B),
                    size: 22,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          Text(
            'Màu sắc',
            style: GoogleFonts.nunito(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF5A7563),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: categoryColorOptions.map((color) {
              final hex = _colorToHex(color);
              final selected = hex == _selectedColor;
              return GestureDetector(
                onTap: () => setState(() => _selectedColor = hex),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: selected
                        ? Border.all(color: const Color(0xFF0C3D2B), width: 3)
                        : null,
                  ),
                  child: selected
                      ? const Icon(Icons.check_rounded,
                          color: Colors.white, size: 18)
                      : null,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: _submit,
            child: Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFF0C3D2B),
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: Text(
                widget.initialName == null ? 'Thêm danh mục' : 'Lưu thay đổi',
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}