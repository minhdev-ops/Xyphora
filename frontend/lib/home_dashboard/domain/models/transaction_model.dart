enum TransactionStatus { borrow, receive, done }

class TransactionModel {
  final String title;
  final String date;
  final int memberCount;
  final List<String> memberInitials;
  final double amount;
  final TransactionStatus status;

  TransactionModel({
    required this.title,
    required this.date,
    required this.memberCount,
    required this.memberInitials,
    required this.amount,
    required this.status,
  });
}
