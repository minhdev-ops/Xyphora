class ExpenseSplitModel {
  final String expenseId;
  final String participantId;
  final double amount;

  ExpenseSplitModel({
    required this.expenseId,
    required this.participantId,
    required this.amount,
  });

  factory ExpenseSplitModel.fromJson(Map<String, dynamic> json) {
    return ExpenseSplitModel(
      expenseId: json['expense_id']?.toString() ?? '',
      participantId: json['participant_id']?.toString() ?? '',
      amount: double.tryParse(json['amount']?.toString() ?? '') ?? 0,
    );
  }
}