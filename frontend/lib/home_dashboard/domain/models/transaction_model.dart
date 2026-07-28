class TransactionModel {
  final String title;
  final String subtitle;
  final String amount;
  final String? extraInfo;
  final TransactionType type;

  TransactionModel({
    required this.title,
    required this.subtitle,
    required this.amount,
    this.extraInfo,
    required this.type,
  });
}

enum TransactionType {
  shopping,
  dining,
  utility,
}
