import '../../domain/models/expense_model.dart';

class AddExpenseDatasource {
  static final List<ExpenseModel> _mockExpenses = [
    ExpenseModel(
      id: '1',
      title: 'Ăn trưa cùng đồng nghiệp',
      amount: 185000,
      currency: 'VND',
      description: 'Nhà hàng Nhật Bản',
      category: 'Ăn uống',
      date: '2026-07-29',
    ),
    ExpenseModel(
      id: '2',
      title: 'Grab đi làm',
      amount: 45000,
      currency: 'VND',
      description: 'Đi làm sáng',
      category: 'Di chuyển',
      date: '2026-07-29',
    ),
    ExpenseModel(
      id: '3',
      title: 'Cà phê sáng',
      amount: 35000,
      currency: 'VND',
      description: 'Highlands Cà phê',
      category: 'Ăn uống',
      date: '2026-07-28',
    ),
    ExpenseModel(
      id: '4',
      title: 'Mua sách',
      amount: 120000,
      currency: 'VND',
      description: 'Sách lập trình Flutter',
      category: 'Giáo dục',
      date: '2026-07-27',
    ),
    ExpenseModel(
      id: '5',
      title: 'Tiền điện tháng 7',
      amount: 350000,
      currency: 'VND',
      description: 'Hóa đơn tiền điện',
      category: 'Hóa đơn',
      date: '2026-07-25',
    ),
  ];

  List<ExpenseModel> getMockExpenses() => _mockExpenses;

  ExpenseModel? getMockExpenseById(String id) {
    try {
      return _mockExpenses.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  ExpenseModel addMockExpense(ExpenseModel expense) {
    final newExpense = expense.copyWith(
      id: (_mockExpenses.length + 1).toString(),
      date: DateTime.now().toIso8601String().split('T')[0],
    );
    _mockExpenses.insert(0, newExpense);
    return newExpense;
  }
}
