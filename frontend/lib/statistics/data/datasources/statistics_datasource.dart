import '../../domain/models/statistics_model.dart';

class StatisticsDatasource {
  static const double _totalExpense = 2670000;
  static const double _changeRate = 18.5;

  static const List<CategoryStat> _categoryStats = [
    CategoryStat(
      name: 'Chỗ ở',
      amount: 1200000,
      color: 0xFFA5D6A7,
      percent: 45,
    ),
    CategoryStat(
      name: 'Ăn uống',
      amount: 800000,
      color: 0xFF4CAF50,
      percent: 30,
    ),
    CategoryStat(
      name: 'Di chuyển',
      amount: 450000,
      color: 0xFF2E7D32,
      percent: 17,
    ),
    CategoryStat(
      name: 'Vui chơi',
      amount: 150000,
      color: 0xFF1B5E20,
      percent: 4,
    ),
    CategoryStat(name: 'Khác', amount: 70000, color: 0xFF1A4331, percent: 4),
  ];

  static const List<MonthlyStat> _monthlyStats = [
    MonthlyStat(label: 'T1', value: 520000),
    MonthlyStat(label: 'T2', value: 450000),
    MonthlyStat(label: 'T3', value: 620000),
    MonthlyStat(label: 'T4', value: 380000),
    MonthlyStat(label: 'T5', value: 790000),
    MonthlyStat(label: 'T6', value: 540000),
    MonthlyStat(label: 'T7', value: 1050000),
    MonthlyStat(label: 'T8', value: 700000),
    MonthlyStat(label: 'T9', value: 610000),
    MonthlyStat(label: 'T10', value: 830000),
    MonthlyStat(label: 'T11', value: 470000),
    MonthlyStat(label: 'T12', value: 890000),
  ];

  static const Map<String, List<TransactionItem>> _monthlyTransactions = {
    'T1': [
      TransactionItem(
        name: 'Tiền thuê nhà',
        categoryName: 'Chỗ ở',
        amount: 350000,
        color: 0xFFA5D6A7,
      ),
      TransactionItem(
        name: 'Ăn uống ngoài',
        categoryName: 'Ăn uống',
        amount: 170000,
        color: 0xFF4CAF50,
      ),
    ],
    'T2': [
      TransactionItem(
        name: 'Tiền điện nước',
        categoryName: 'Chỗ ở',
        amount: 200000,
        color: 0xFFA5D6A7,
      ),
      TransactionItem(
        name: 'Đi chợ',
        categoryName: 'Ăn uống',
        amount: 150000,
        color: 0xFF4CAF50,
      ),
      TransactionItem(
        name: 'Xăng xe',
        categoryName: 'Di chuyển',
        amount: 100000,
        color: 0xFF2E7D32,
      ),
    ],
    'T3': [
      TransactionItem(
        name: 'Tiền thuê nhà',
        categoryName: 'Chỗ ở',
        amount: 350000,
        color: 0xFFA5D6A7,
      ),
      TransactionItem(
        name: 'Ăn uống ngoài',
        categoryName: 'Ăn uống',
        amount: 180000,
        color: 0xFF4CAF50,
      ),
      TransactionItem(
        name: 'Xăng xe',
        categoryName: 'Di chuyển',
        amount: 90000,
        color: 0xFF2E7D32,
      ),
    ],
    'T4': [
      TransactionItem(
        name: 'Tiền thuê nhà',
        categoryName: 'Chỗ ở',
        amount: 300000,
        color: 0xFFA5D6A7,
      ),
      TransactionItem(
        name: 'Ăn uống ngoài',
        categoryName: 'Ăn uống',
        amount: 80000,
        color: 0xFF4CAF50,
      ),
    ],
    'T5': [
      TransactionItem(
        name: 'Tiền thuê nhà',
        categoryName: 'Chỗ ở',
        amount: 350000,
        color: 0xFFA5D6A7,
      ),
      TransactionItem(
        name: 'Ăn uống ngoài',
        categoryName: 'Ăn uống',
        amount: 240000,
        color: 0xFF4CAF50,
      ),
      TransactionItem(
        name: 'Xăng xe',
        categoryName: 'Di chuyển',
        amount: 120000,
        color: 0xFF2E7D32,
      ),
      TransactionItem(
        name: 'Xem phim',
        categoryName: 'Vui chơi',
        amount: 80000,
        color: 0xFF1B5E20,
      ),
    ],
    'T6': [
      TransactionItem(
        name: 'Tiền thuê nhà',
        categoryName: 'Chỗ ở',
        amount: 350000,
        color: 0xFFA5D6A7,
      ),
      TransactionItem(
        name: 'Ăn uống ngoài',
        categoryName: 'Ăn uống',
        amount: 130000,
        color: 0xFF4CAF50,
      ),
      TransactionItem(
        name: 'Xăng xe',
        categoryName: 'Di chuyển',
        amount: 60000,
        color: 0xFF2E7D32,
      ),
    ],
    'T7': [
      TransactionItem(
        name: 'Homestay Đà Lạt',
        categoryName: 'Chỗ ở',
        amount: 400000,
        color: 0xFFA5D6A7,
      ),
      TransactionItem(
        name: 'Ăn vặt Bảo Lộc',
        categoryName: 'Ăn uống',
        amount: 250000,
        color: 0xFF4CAF50,
      ),
      TransactionItem(
        name: 'Xăng xe',
        categoryName: 'Di chuyển',
        amount: 150000,
        color: 0xFF2E7D32,
      ),
      TransactionItem(
        name: 'Cà phê vỉa hè',
        categoryName: 'Ăn uống',
        amount: 150000,
        color: 0xFF4CAF50,
      ),
      TransactionItem(
        name: 'Vé tham quan',
        categoryName: 'Vui chơi',
        amount: 100000,
        color: 0xFF1B5E20,
      ),
    ],
    'T8': [
      TransactionItem(
        name: 'Tiền thuê nhà',
        categoryName: 'Chỗ ở',
        amount: 350000,
        color: 0xFFA5D6A7,
      ),
      TransactionItem(
        name: 'Ăn uống ngoài',
        categoryName: 'Ăn uống',
        amount: 200000,
        color: 0xFF4CAF50,
      ),
      TransactionItem(
        name: 'Xăng xe',
        categoryName: 'Di chuyển',
        amount: 100000,
        color: 0xFF2E7D32,
      ),
      TransactionItem(
        name: 'Xem phim',
        categoryName: 'Vui chơi',
        amount: 50000,
        color: 0xFF1B5E20,
      ),
    ],
    'T9': [
      TransactionItem(
        name: 'Tiền thuê nhà',
        categoryName: 'Chỗ ở',
        amount: 350000,
        color: 0xFFA5D6A7,
      ),
      TransactionItem(
        name: 'Ăn uống ngoài',
        categoryName: 'Ăn uống',
        amount: 160000,
        color: 0xFF4CAF50,
      ),
      TransactionItem(
        name: 'Xăng xe',
        categoryName: 'Di chuyển',
        amount: 100000,
        color: 0xFF2E7D32,
      ),
    ],
    'T10': [
      TransactionItem(
        name: 'Tiền thuê nhà',
        categoryName: 'Chỗ ở',
        amount: 350000,
        color: 0xFFA5D6A7,
      ),
      TransactionItem(
        name: 'Ăn uống ngoài',
        categoryName: 'Ăn uống',
        amount: 280000,
        color: 0xFF4CAF50,
      ),
      TransactionItem(
        name: 'Xăng xe',
        categoryName: 'Di chuyển',
        amount: 120000,
        color: 0xFF2E7D32,
      ),
      TransactionItem(
        name: 'Xem phim',
        categoryName: 'Vui chơi',
        amount: 80000,
        color: 0xFF1B5E20,
      ),
    ],
    'T11': [
      TransactionItem(
        name: 'Tiền thuê nhà',
        categoryName: 'Chỗ ở',
        amount: 300000,
        color: 0xFFA5D6A7,
      ),
      TransactionItem(
        name: 'Ăn uống ngoài',
        categoryName: 'Ăn uống',
        amount: 120000,
        color: 0xFF4CAF50,
      ),
      TransactionItem(
        name: 'Xăng xe',
        categoryName: 'Di chuyển',
        amount: 50000,
        color: 0xFF2E7D32,
      ),
    ],
    'T12': [
      TransactionItem(
        name: 'Tiền thuê nhà',
        categoryName: 'Chỗ ở',
        amount: 400000,
        color: 0xFFA5D6A7,
      ),
      TransactionItem(
        name: 'Ăn uống ngoài',
        categoryName: 'Ăn uống',
        amount: 290000,
        color: 0xFF4CAF50,
      ),
      TransactionItem(
        name: 'Xăng xe',
        categoryName: 'Di chuyển',
        amount: 130000,
        color: 0xFF2E7D32,
      ),
      TransactionItem(
        name: 'Xem phim',
        categoryName: 'Vui chơi',
        amount: 70000,
        color: 0xFF1B5E20,
      ),
    ],
  };

  double getTotalExpense() => _totalExpense;

  double getChangeRate() => _changeRate;

  List<CategoryStat> getCategoryStats() => _categoryStats;

  List<MonthlyStat> getMonthlyStats() => _monthlyStats;

  List<TransactionItem> getMonthlyTransactions(String monthLabel) =>
      _monthlyTransactions[monthLabel] ?? const [];
}
