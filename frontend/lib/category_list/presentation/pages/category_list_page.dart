import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../config/category_icons.dart';
import '../../domain/models/category_stat_item.dart';
import '../controllers/category_list_controller.dart';
import '../widgets/category_form_sheet.dart';

class CategoryListPage extends GetView<CategoryListController> {
  const CategoryListPage({super.key});

  Future<void> _openForm({CategoryStatItem? item}) async {
    final result = await Get.bottomSheet<Map<String, dynamic>>(
      CategoryFormSheet(
        initialName: item?.name,
        initialIcon: item?.icon,
        initialColor: item?.color,
      ),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    );

    if (result == null) return;

    if (item == null) {
      await controller.createCategory(
        name: result['name'] as String,
        icon: result['icon'] as String?,
        color: result['color'] as String?,
      );
    } else {
      await controller.updateCategory(
        categoryId: item.categoryId,
        name: result['name'] as String,
        icon: result['icon'] as String?,
        color: result['color'] as String?,
      );
    }
  }

  Future<void> _confirmDelete(CategoryStatItem item) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Xóa danh mục "${item.name}"?',
          style: GoogleFonts.nunito(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0C3D2B),
          ),
        ),
        content: Text(
          'Danh mục này sẽ bị xóa vĩnh viễn.',
          style: GoogleFonts.nunito(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF5A7563),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(
              'Hủy',
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF5A7563),
              ),
            ),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(
              'Xóa',
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w800,
                color: const Color(0xFFC62828),
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await controller.deleteCategory(item.categoryId);
    }
  }

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
          'Danh mục chi tiêu',
          style: GoogleFonts.nunito(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF0C3D2B),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        backgroundColor: const Color(0xFF0C3D2B),
        shape: const CircleBorder(),
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      body: SafeArea(
        child: GetBuilder<CategoryListController>(
          builder: (ctrl) {            if (ctrl.isLoading.value) {
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
                        onTap: ctrl.loadCategories,
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

            final items = ctrl.sortedCategories;
            if (items.isEmpty) {
              return Center(
                child: Text(
                  'Không có danh mục nào',
                  style: GoogleFonts.nunito(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF5A7563),
                  ),
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCard(ctrl),
                  const SizedBox(height: 20),
                  ...items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _buildCategoryCard(ctrl, item, items),
                    ),
                  ),
                  const SizedBox(height: 88),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSummaryCard(CategoryListController ctrl) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFE2F0E5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFCBE0D1), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.category_rounded,
              color: Color(0xFF0C3D2B),
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tổng chi theo danh mục',
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF5A7563),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  ctrl.formatCurrency(ctrl.totalAll),
                  style: GoogleFonts.nunito(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF0C3D2B),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${ctrl.categoryCount} danh mục',
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF5A7563),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
    CategoryListController ctrl,
    CategoryStatItem item,
    List<CategoryStatItem> all,
  ) {
    final iconColor = categoryColorFor(item.color);
    final maxAmount = all.isEmpty ? 1.0 : all.first.totalAmount;
    final percent = maxAmount <= 0 ? 0.0 : (item.totalAmount / maxAmount);

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
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Icon(
                  categoryIconFor(item.icon),
                  color: iconColor,
                  size: 22,
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
                            item.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.nunito(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0C3D2B),
                            ),
                          ),
                        ),
                        if (item.isDefault) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE2F0E5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Mặc định',
                              style: GoogleFonts.nunito(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF0C3D2B),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item.expenseCount} khoản chi',
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF5A7563),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    ctrl.formatCurrency(item.totalAmount),
                    style: GoogleFonts.nunito(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF0C3D2B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () => _openForm(item: item),
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE2F0E5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.edit_rounded,
                            color: Color(0xFF0C3D2B),
                            size: 15,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => _confirmDelete(item),
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFDE8E8),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.delete_outline_rounded,
                            color: Color(0xFFC62828),
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: percent.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: const Color(0xFFF0F4F1),
              valueColor: AlwaysStoppedAnimation<Color>(iconColor),
            ),
          ),
        ],
      ),
    );
  }
}