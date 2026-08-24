import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/repositories/category_list_repository.dart';
import '../../domain/models/category_stat_item.dart';

class CategoryListController extends GetxController {
  final CategoryListRepository _repository = CategoryListRepository();

  final isLoading = true.obs;
  final errorMessage = RxnString();
  final categories = <CategoryStatItem>[].obs;
  final isMutating = false.obs;

  List<CategoryStatItem> get sortedCategories {
    final list = [...categories];
    list.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
    return list;
  }

  double get totalAll =>
      categories.fold(0.0, (sum, c) => sum + c.totalAmount);

  int get categoryCount => categories.length;

  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }

  Future<void> loadCategories() async {
    isLoading.value = true;
    errorMessage.value = null;
    update();

    try {
      categories.assignAll(await _repository.fetchCategories());
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    }

    isLoading.value = false;
    update();
  }

  Future<bool> createCategory({
    required String name,
    String? icon,
    String? color,
  }) async {
    return _mutate(() => _repository.createCategory(
          name: name,
          icon: icon,
          color: color,
        ));
  }

  Future<bool> updateCategory({
    required int categoryId,
    required String name,
    String? icon,
    String? color,
  }) async {
    return _mutate(() => _repository.updateCategory(
          categoryId: categoryId,
          name: name,
          icon: icon,
          color: color,
        ));
  }

  Future<bool> deleteCategory(int categoryId) async {
    return _mutate(() => _repository.deleteCategory(categoryId));
  }

  Future<bool> _mutate(Future<dynamic> Function() action) async {
    isMutating.value = true;
    update();

    try {
      await action();
      await loadCategories();
      return true;
    } catch (e) {
      Get.snackbar(
        'Thất bại',
        e.toString().replaceFirst('Exception: ', ''),
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isMutating.value = false;
      update();
    }
  }

  String formatCurrency(double amount) {
    final str = amount.abs().round().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(str[i]);
    }
    return '${buffer.toString()}đ';
  }
}