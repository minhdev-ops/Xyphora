class ExpenseSplitModel {
  final String expenseId;
  final String participantId;
  final double amount;
  final String status;

  ExpenseSplitModel({
    required this.expenseId,
    required this.participantId,
    required this.amount,
    this.status = 'pending',
  });
}
