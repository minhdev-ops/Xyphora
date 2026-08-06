import '../../domain/models/group_expense_model.dart';

class AddGroupExpenseDatasource {
  static final List<GroupExpenseModel> _mockExpenses = [
    GroupExpenseModel(
      id: '1',
      title: 'Ăn trưa nhóm',
      amount: 320000,
      currency: 'VND',
      description: 'Nhà hàng Nhật Bản',
      category: 'Ăn uống',
      date: '2026-07-30',
      payerIds: ['m1', 'm2'],
      splitMode: 'equal',
    ),
    GroupExpenseModel(
      id: '2',
      title: 'Đi xem phim',
      amount: 240000,
      currency: 'VND',
      description: 'CGV Vincom',
      category: 'Giải trí',
      date: '2026-07-29',
      payerIds: ['m3'],
      splitMode: 'percent',
    ),
  ];

  static const List<GroupMember> _mockMembers = [
    GroupMember(id: 'm1', name: 'An', color: 0xFF5B8DEF),
    GroupMember(id: 'm2', name: 'Bảo', color: 0xFFE07A5F),
    GroupMember(id: 'm3', name: 'Chi', color: 0xFF9B5DE5),
    GroupMember(id: 'm4', name: 'Dũng', color: 0xFFF4A261),
    GroupMember(id: 'm5', name: 'Hoa', color: 0xFF2A9D8F),
    GroupMember(id: 'm6', name: 'Minh', color: 0xFFE76F51),
    GroupMember(id: 'm7', name: 'Khôi', color: 0xFF6D597A),
    GroupMember(id: 'm8', name: 'Lâm', color: 0xFF43AA8B),
  ];

  List<GroupExpenseModel> getMockExpenses() => _mockExpenses;

  List<GroupMember> getMockMembers() => _mockMembers;

  GroupExpenseModel? getMockExpenseById(String id) {
    try {
      return _mockExpenses.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  GroupExpenseModel addMockExpense(GroupExpenseModel expense) {
    final newExpense = expense.copyWith(
      id: (_mockExpenses.length + 1).toString(),
      date: DateTime.now().toIso8601String().split('T')[0],
    );
    _mockExpenses.insert(0, newExpense);
    return newExpense;
  }
}
