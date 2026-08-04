import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/models/transaction_model.dart';
import '../../domain/models/spending_model.dart';

class DashboardController extends GetxController {
  // Navigation state
  var selectedIndex = 0.obs;

  // Header user info
  var userName = 'Nguyễn Văn A'.obs;

  // Financial summary states
  var totalBalance = 455000.0.obs;
  var debtToYou = 330000.0.obs;
  var yourDebt = 19000.0.obs;

  // Selected Tab filter state ('all' or 'my_spending')
  var selectedTab = 'all'.obs;

  // Event transactions list
  var transactions = <TransactionModel>[].obs;

  // My spending summary & list
  var monthlySpendingTotal = 1135000.0.obs;
  var spendingCount = 8.obs;
  var spendings = <SpendingModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  void loadDashboardData() {
    // Load event transactions (All tab)
    transactions.assignAll([
      TransactionModel(
        title: 'Du lịch Đà Lạt',
        date: '20 tháng 7, 2026',
        memberCount: 5,
        memberInitials: ['B', 'M', 'L', 'H'],
        amount: -125000.0,
        status: TransactionStatus.borrow,
      ),
      TransactionModel(
        title: 'Tiệc sinh nhật Minh',
        date: '15 tháng 7, 2026',
        memberCount: 8,
        memberInitials: ['B', 'M', 'L', 'H'],
        amount: 340000.0,
        status: TransactionStatus.receive,
      ),
      TransactionModel(
        title: 'Nhà Airbnb Hội An',
        date: '10 tháng 7, 2026',
        memberCount: 4,
        memberInitials: ['B', 'M', 'L', 'H'],
        amount: 0.0,
        status: TransactionStatus.done,
      ),
      TransactionModel(
        title: 'Ăn tối nhóm Startup',
        date: '5 tháng 7, 2026',
        memberCount: 6,
        memberInitials: ['B', 'M', 'L', 'H'],
        amount: -78000.0,
        status: TransactionStatus.borrow,
      ),
    ]);

    // Load personal spendings (My Spending tab)
    spendings.assignAll([
      const SpendingModel(
        title: 'Cà phê Highlands',
        category: 'Ăn uống',
        date: '27 tháng 7, 2026',
        amount: 55000.0,
        icon: Icons.local_cafe_outlined,
        themeColor: Color(0xFF0C3D2B),
        bgThemeColor: Color(0xFFE2F0E5),
        paymentMethod: 'Ví MoMo',
        note: 'Americano sáng đi làm',
      ),
      const SpendingModel(
        title: 'Mua sắm siêu thị',
        category: 'Mua sắm',
        date: '26 tháng 7, 2026',
        amount: 320000.0,
        icon: Icons.shopping_cart_outlined,
        themeColor: Color(0xFF5E35B1),
        bgThemeColor: Color(0xFFEDE7F6),
        paymentMethod: 'Thẻ tín dụng',
        note: 'Mua thực phẩm tuần mới',
      ),
      const SpendingModel(
        title: 'Grab đi làm',
        category: 'Di chuyển',
        date: '26 tháng 7, 2026',
        amount: 45000.0,
        icon: Icons.directions_car_filled_outlined,
        themeColor: Color(0xFF00796B),
        bgThemeColor: Color(0xFFE0F2F1),
        paymentMethod: 'Ví MoMo',
        note: 'Di chuyển giờ cao điểm',
      ),
      const SpendingModel(
        title: 'Thuốc nhà thuốc',
        category: 'Y tế',
        date: '25 tháng 7, 2026',
        amount: 85000.0,
        icon: Icons.medication_outlined,
        themeColor: Color(0xFFC62828),
        bgThemeColor: Color(0xFFFFEBEE),
        paymentMethod: 'Tiền mặt',
        note: 'Mua Vitamin C và khẩu trang',
      ),
    ]);
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
}
