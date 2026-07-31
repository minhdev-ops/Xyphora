class GroupMember {
  final String id;
  final String name;
  final int color;

  const GroupMember({
    required this.id,
    required this.name,
    required this.color,
  });

  factory GroupMember.fromJson(Map<String, dynamic> json) {
    return GroupMember(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      color: (json['color'] as num?)?.toInt() ?? 0xFF0C3D2B,
    );
  }
}

class GroupExpenseModel {
  final String id;
  final String title;
  final double amount;
  final String currency;
  final String description;
  final String category;
  final String date;
  final String? receiptUrl;
  final List<String> payerIds;
  final String splitMode;

  const GroupExpenseModel({
    required this.id,
    required this.title,
    required this.amount,
    this.currency = 'VND',
    this.description = '',
    this.category = 'Khác',
    this.date = '',
    this.receiptUrl,
    this.payerIds = const [],
    this.splitMode = 'equal',
  });

  factory GroupExpenseModel.fromJson(Map<String, dynamic> json) {
    return GroupExpenseModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] ?? 'VND',
      description: json['description'] ?? '',
      category: json['category'] ?? 'Khác',
      date: json['date'] ?? '',
      receiptUrl: json['receipt_url'],
      payerIds:
          (json['payer_ids'] as List?)?.map((e) => e.toString()).toList() ??
          const [],
      splitMode: json['split_mode'] ?? 'equal',
    );
  }

  GroupExpenseModel copyWith({
    String? id,
    String? title,
    double? amount,
    String? currency,
    String? description,
    String? category,
    String? date,
    String? receiptUrl,
    List<String>? payerIds,
    String? splitMode,
  }) {
    return GroupExpenseModel(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      description: description ?? this.description,
      category: category ?? this.category,
      date: date ?? this.date,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      payerIds: payerIds ?? this.payerIds,
      splitMode: splitMode ?? this.splitMode,
    );
  }
}
