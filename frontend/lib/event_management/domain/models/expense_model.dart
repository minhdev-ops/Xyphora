import 'expense_split_model.dart';

class ExpenseModel {
  final String id;
  final String eventId;
  final String title;
  final double amount;
  final DateTime dayPaid;
  final String payerId;
  final List<ExpenseSplitModel> splits;

  ExpenseModel({
    required this.id,
    required this.eventId,
    required this.title,
    required this.amount,
    required this.dayPaid,
    required this.payerId,
    required this.splits,
  });
}
