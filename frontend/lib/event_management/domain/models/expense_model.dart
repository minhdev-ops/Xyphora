import 'expense_split_model.dart';
import 'participant_model.dart';

class ExpenseModel {
  final String id;
  final String eventId;
  final String title;
  final double amount;
  final DateTime dayPaid;
  final String payerId;
  final List<ExpenseSplitModel> splits;
  final String? categoryIcon;

  ExpenseModel({
    required this.id,
    required this.eventId,
    required this.title,
    required this.amount,
    required this.dayPaid,
    required this.payerId,
    required this.splits,
    this.categoryIcon,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json, String eventId, List<ParticipantModel> participants) {
    return ExpenseModel(
      id: json['expense_id'].toString(),
      eventId: eventId,
      title: json['title'] as String? ?? '',
      amount: double.tryParse(json['amount']?.toString() ?? '') ?? 0,
      dayPaid: DateTime.tryParse(json['expense_date'] as String? ?? '') ?? DateTime.now(),
      payerId: json['payer_id']?.toString() ?? '',
      categoryIcon: (json['category'] as Map<String, dynamic>?)?['icon'] as String?,
      splits: (json['splits'] as List? ?? [])
          .map((s) => ExpenseSplitModel.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }
}