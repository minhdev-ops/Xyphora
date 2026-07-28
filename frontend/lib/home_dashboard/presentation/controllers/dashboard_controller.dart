import 'package:get/get.dart';
import '../../domain/models/transaction_model.dart';

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

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  void loadDashboardData() {
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
  }

  // Reactive getter to filter transactions based on tab
  List<TransactionModel> get filteredTransactions {
    if (selectedTab.value == 'my_spending') {
      // Return only items where the user is spending/borrowing
      return transactions.where((tx) => tx.status == TransactionStatus.borrow).toList();
    }
    return transactions;
  }

  void changeTab(String tab) {
    selectedTab.value = tab;
  }

  void onTabChanged(int index) {
    selectedIndex.value = index;
  }
}
