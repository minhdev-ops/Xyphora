import 'expense_model.dart';
import 'expense_split_model.dart';
import 'participant_model.dart';
import 'event_model.dart';
import '../../../auth/domain/models/user.dart';

class ExpenseGroup {
  final DateTime date;
  final String formattedDate;
  final List<ExpenseModel> expenses;

  ExpenseGroup({
    required this.date,
    required this.formattedDate,
    required this.expenses,
  });
}

class BalanceItem {
  final String name;
  final double amount;

  BalanceItem({required this.name, required this.amount});
}

class EventDetailMock {
  static const String myUserId = 'user_1';

  static final UserModel userMe = UserModel(id: 'user_1', name: 'Bạn', email: '');
  static final UserModel userMinh = UserModel(id: 'user_2', name: 'Minh Tuấn', email: '');
  static final UserModel userLan = UserModel(id: 'user_3', name: 'Lan', email: '');
  static final UserModel userHuy = UserModel(id: 'user_4', name: 'Huy', email: '');
  static final UserModel userTrang = UserModel(id: 'user_5', name: 'Trang', email: '');

  static final List<ParticipantModel> participants = [
    ParticipantModel(id: 'p1', eventId: 'evt_detail', userId: 'user_1', user: userMe),
    ParticipantModel(id: 'p2', eventId: 'evt_detail', userId: 'user_2', user: userMinh),
    ParticipantModel(id: 'p3', eventId: 'evt_detail', userId: 'user_3', user: userLan),
    ParticipantModel(id: 'p4', eventId: 'evt_detail', userId: 'user_4', user: userHuy),
    ParticipantModel(id: 'p5', eventId: 'evt_detail', userId: 'user_5', user: userTrang),
  ];

  static List<ExpenseSplitModel> _fullSplits(String expenseId, double total) {
    final perPerson = total / 5;
    return participants.map((p) => ExpenseSplitModel(
          expenseId: expenseId,
          participantId: p.id,
          amount: perPerson,
        )).toList();
  }

  static List<ExpenseSplitModel> _customSplits(String expenseId, Map<String, double> amounts) {
    return participants.map((p) {
      final amt = amounts[p.id] ?? 0;
      return ExpenseSplitModel(expenseId: expenseId, participantId: p.id, amount: amt);
    }).toList();
  }

  static final List<ExpenseModel> expenses = [
    ExpenseModel(
      id: 'exp_1',
      eventId: 'evt_detail',
      title: 'Khách sạn 2 đêm',
      amount: 1200000,
      dayPaid: DateTime(2026, 7, 20),
      payerId: 'user_2',
      splits: _customSplits('exp_1', {'p1': 340000, 'p2': 340000, 'p3': 340000, 'p4': 60000, 'p5': 120000}),
    ),
    ExpenseModel(
      id: 'exp_2',
      eventId: 'evt_detail',
      title: 'Cà phê sáng',
      amount: 45000,
      dayPaid: DateTime(2026, 7, 20),
      payerId: 'user_2',
      splits: _fullSplits('exp_2', 45000),
    ),
    ExpenseModel(
      id: 'exp_3',
      eventId: 'evt_detail',
      title: 'Ăn tối tại BBQ',
      amount: 650000,
      dayPaid: DateTime(2026, 7, 21),
      payerId: 'user_3',
      splits: _fullSplits('exp_3', 650000),
    ),
    ExpenseModel(
      id: 'exp_4',
      eventId: 'evt_detail',
      title: 'Vé tham quan',
      amount: 400000,
      dayPaid: DateTime(2026, 7, 21),
      payerId: 'user_4',
      splits: _customSplits('exp_4', {'p1': 180000, 'p2': 55000, 'p3': 55000, 'p4': 55000, 'p5': 55000}),
    ),
    ExpenseModel(
      id: 'exp_5',
      eventId: 'evt_detail',
      title: 'Xăng xe',
      amount: 255000,
      dayPaid: DateTime(2026, 7, 22),
      payerId: 'user_2',
      splits: _customSplits('exp_5', {'p1': 146000, 'p2': 30000, 'p3': 30000, 'p4': 30000, 'p5': 19000}),
    ),
  ];

  static final EventModel event = EventModel(
    id: 'evt_detail',
    ownerId: 'user_2',
    emoji: '⛰️',
    title: 'Du lịch Đà Lạt',
    createdAt: DateTime(2026, 7, 20),
    participants: participants,
    expenses: expenses,
  );

  static String formatDate(DateTime dt) {
    const months = [
      'tháng 1', 'tháng 2', 'tháng 3', 'tháng 4',
      'tháng 5', 'tháng 6', 'tháng 7', 'tháng 8',
      'tháng 9', 'tháng 10', 'tháng 11', 'tháng 12',
    ];
    return '${dt.day} ${months[dt.month - 1]}, ${dt.year}';
  }

  static List<ExpenseGroup> get expenseGroups {
    final map = <DateTime, List<ExpenseModel>>{};
    for (final e in expenses) {
      final day = DateTime(e.dayPaid.year, e.dayPaid.month, e.dayPaid.day);
      map.putIfAbsent(day, () => []);
      map[day]!.add(e);
    }
    final sortedDays = map.keys.toList()..sort((a, b) => b.compareTo(a));
    return sortedDays.map((day) => ExpenseGroup(
          date: day,
          formattedDate: formatDate(day),
          expenses: map[day]!,
        )).toList();
  }

  static double get myTotalExpense {
    double total = 0;
    for (final e in expenses) {
      for (final s in e.splits) {
        final p = participants.firstWhere((p) => p.id == s.participantId);
        if (p.userId == myUserId) {
          total += s.amount;
        }
      }
    }
    return total;
  }

  static double get totalExpense => expenses.fold(0, (sum, e) => sum + e.amount);

  static List<BalanceItem> get balances => [
        BalanceItem(name: 'Minh Tuấn', amount: 200000),
        BalanceItem(name: 'Lan', amount: 90000),
        BalanceItem(name: 'Huy', amount: -19000),
        BalanceItem(name: 'Trang', amount: 40000),
      ];

  static double get totalOwed =>
      balances.where((b) => b.amount > 0).fold(0, (sum, b) => sum + b.amount);

  static List<String> get photos => ['🌅', '🌊', '🍃', '🏔️', '🌸', '🌲'];
}
