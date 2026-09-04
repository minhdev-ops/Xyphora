import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/token_storage.dart';
import '../../data/dashboard_service.dart';
import '../../domain/models/transaction_model.dart';
import '../../domain/models/spending_model.dart';
import '../../../auth/presentation/pages/login_pages.dart';

class DashboardController extends GetxController {
  final DashboardService _dashboardService = DashboardService();

  // Navigation state
  var selectedIndex = 0.obs;

  // Header user info
  var userName = ''.obs;

  // Loading state
  var isLoading = false.obs;

  // Financial summary states
  var totalBalance = 0.0.obs;
  var debtToYou = 0.0.obs;
  var yourDebt = 0.0.obs;

  // Selected Tab filter state ('all' or 'my_spending')
  var selectedTab = 'all'.obs;

  // Event transactions list
  var transactions = <TransactionModel>[].obs;

  // My spending summary & list
  var monthlySpendingTotal = 0.0.obs;
  var spendingCount = 0.obs;
  var spendings = <SpendingModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    debugPrint('[Dashboard] controller onInit -> loadDashboardData');
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    isLoading.value = true;
    update();

    final result = await _dashboardService.getDashboard();

    if (result['success'] != true) {
      isLoading.value = false;
      update();

      if (result['message'] == 'Phiên đăng nhập đã hết hạn') {
        await TokenStorage.delete();
        Get.offAll(() => const LoginPages());
        return;
      }

      Get.snackbar(
        'Lỗi',
        result['message'] ?? 'Không thể tải dữ liệu',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    final data = result['data'] as Map<String, dynamic>;

    // Header
    final user = data['user'] as Map<String, dynamic>? ?? {};
    userName.value = user['name']?.toString() ?? '';

    // Summary
    final summary = data['summary'] as Map<String, dynamic>? ?? {};
    final balance = summary['balance'] as Map<String, dynamic>? ?? {};
    totalBalance.value = _toDouble(balance['total']);
    debtToYou.value = _toDouble(balance['debt_to_you']);
    yourDebt.value = _toDouble(balance['your_debt']);
    monthlySpendingTotal.value = _toDouble(summary['monthly_spending']);
    spendingCount.value = summary['monthly_spending_count'] ?? 0;

    // Transactions (All tab)
    final txList = data['transactions'] as List<dynamic>? ?? [];
    transactions.assignAll(txList.map((item) {
      final map = item as Map<String, dynamic>;
      return TransactionModel(
        title: map['title']?.toString() ?? '',
        date: _formatDate(map['date']),
        memberCount: map['member_count'] ?? 0,
        memberInitials:
            (map['member_initials'] as List<dynamic>? ?? []).cast<String>(),
        amount: _toDouble(map['amount']),
        status: _mapStatus(map['status']?.toString()),
      );
    }));

    // Spendings (My Spending tab)
    final spList = data['spendings'] as List<dynamic>? ?? [];
    spendings.assignAll(spList.map((item) {
      final map = item as Map<String, dynamic>;
      final style = _categoryStyle(map['category']?.toString());
      return SpendingModel(
        expenseId: map['expense_id'] is num
            ? (map['expense_id'] as num).toInt()
            : 0,
        eventId: map['event_id'] is num
            ? (map['event_id'] as num).toInt()
            : null,
        title: map['title']?.toString() ?? '',
        category: map['category']?.toString() ?? 'Khác',
        date: _formatDate(map['date']),
        amount: _toDouble(map['amount']),
        icon: style.icon,
        themeColor: style.themeColor,
        bgThemeColor: style.bgThemeColor,
        paymentMethod: map['event_id'] is num ? 'Chia sẻ sự kiện' : 'Chi tiêu cá nhân',
        note: map['note']?.toString() ?? '',
      );
    }));

    isLoading.value = false;
    update();
  }

  void changeTab(String tab) {
    selectedTab.value = tab;
    update();
  }

  void onTabChanged(int index) {
    selectedIndex.value = index;
    update();
  }

  double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  TransactionStatus _mapStatus(String? status) {
    switch (status) {
      case 'borrow':
        return TransactionStatus.borrow;
      case 'receive':
        return TransactionStatus.receive;
      default:
        return TransactionStatus.done;
    }
  }

  String _formatDate(dynamic date) {
    if (date == null || date.toString().isEmpty) return '';
    final dt = DateTime.tryParse(date.toString());
    if (dt == null) return date.toString();
    return '${dt.day} tháng ${dt.month}, ${dt.year}';
  }

  ({IconData icon, Color themeColor, Color bgThemeColor}) _categoryStyle(
      String? category) {
    switch (category) {
      case 'Ăn uống':
        return (
          icon: Icons.local_cafe_outlined,
          themeColor: const Color(0xFF0C3D2B),
          bgThemeColor: const Color(0xFFE2F0E5),
        );
      case 'Mua sắm':
        return (
          icon: Icons.shopping_cart_outlined,
          themeColor: const Color(0xFF5E35B1),
          bgThemeColor: const Color(0xFFEDE7F6),
        );
      case 'Di chuyển':
        return (
          icon: Icons.directions_car_filled_outlined,
          themeColor: const Color(0xFF00796B),
          bgThemeColor: const Color(0xFFE0F2F1),
        );
      case 'Y tế':
        return (
          icon: Icons.medication_outlined,
          themeColor: const Color(0xFFC62828),
          bgThemeColor: const Color(0xFFFFEBEE),
        );
      case 'Nhà ở':
        return (
          icon: Icons.home_outlined,
          themeColor: const Color(0xFFF57C00),
          bgThemeColor: const Color(0xFFFFF3E0),
        );
      case 'Giải trí':
        return (
          icon: Icons.sports_esports_outlined,
          themeColor: const Color(0xFF00897B),
          bgThemeColor: const Color(0xFFE0F2F1),
        );
      default:
        return (
          icon: Icons.receipt_long_outlined,
          themeColor: const Color(0xFF4A6B82),
          bgThemeColor: const Color(0xFFE8EEF2),
        );
    }
  }
}