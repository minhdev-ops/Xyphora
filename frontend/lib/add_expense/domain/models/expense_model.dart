class ExpenseModel {
  final String id;
  final String title;
  final double amount;
  final String currency;
  final String description;
  final String category;
  final String date;
  final String? receiptUrl;

  const ExpenseModel({
    required this.id,
    required this.title,
    required this.amount,
    this.currency = 'VND',
    this.description = '',
    this.category = 'Khác',
    this.date = '',
    this.receiptUrl,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] ?? 'VND',
      description: json['description'] ?? '',
      category: json['category'] ?? 'Khác',
      date: json['date'] ?? '',
      receiptUrl: json['receipt_url'],
    );
  }

  ExpenseModel copyWith({
    String? id,
    String? title,
    double? amount,
    String? currency,
    String? description,
    String? category,
    String? date,
    String? receiptUrl,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      description: description ?? this.description,
      category: category ?? this.category,
      date: date ?? this.date,
      receiptUrl: receiptUrl ?? this.receiptUrl,
    );
  }
}
