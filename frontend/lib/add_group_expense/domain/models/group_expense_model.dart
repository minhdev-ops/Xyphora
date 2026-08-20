class GroupMember {
  final String id;
  final String name;
  final int color;
  final bool isMe;

  const GroupMember({
    required this.id,
    required this.name,
    required this.color,
    this.isMe = false,
  });

  factory GroupMember.fromJson(Map<String, dynamic> json) {
    return GroupMember(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      color: (json['color'] as num?)?.toInt() ?? 0xFF0C3D2B,
      isMe: json['is_me'] == true,
    );
  }

  factory GroupMember.fromParticipant(Map<String, dynamic> p) {
    final name = (p['display_name'] as String?)?.trim().isNotEmpty == true
        ? p['display_name'] as String
        : (p['email'] ?? 'Thành viên');

    return GroupMember(
      id: (p['participant_id'] as num?)?.toInt().toString() ?? '',
      name: name,
      color: _colorFromName(name),
      isMe: p['is_me'] == true,
    );
  }

  static int _colorFromName(String name) {
    const palette = [
      0xFF5B8DEF, 0xFFE07A5F, 0xFF9B5DE5, 0xFFF4A261,
      0xFF2A9D8F, 0xFFE76F51, 0xFF6D597A, 0xFF43AA8B,
      0xFF577590, 0xFFF4A259, 0xFF8AC926, 0xFF1982C4,
    ];

    var hash = 0;
    for (final ch in name.codeUnits) {
      hash = (hash * 31 + ch) & 0x7fffffff;
    }

    return palette[hash % palette.length];
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
