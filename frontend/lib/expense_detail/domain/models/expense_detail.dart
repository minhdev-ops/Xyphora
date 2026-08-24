class ExpenseSplitItem {
  final int participantId;
  final int? userId;
  final String? displayName;
  final String? avatar;
  final double amount;
  final String status;
  final bool isPayer;

  const ExpenseSplitItem({
    required this.participantId,
    required this.amount,
    required this.status,
    required this.isPayer,
    this.userId,
    this.displayName,
    this.avatar,
  });

  factory ExpenseSplitItem.fromJson(Map<String, dynamic> json) {
    return ExpenseSplitItem(
      participantId: (json['participant_id'] as num).toInt(),
      userId: json['user_id'] as int?,
      displayName: json['display_name'] as String?,
      avatar: json['avatar'] as String?,
      amount: (json['amount'] as num).toDouble(),
      status: json['status'] as String? ?? 'pending',
      isPayer: json['is_payer'] as bool? ?? false,
    );
  }

  String get name => displayName ?? 'Người tham gia';

  bool get isPaid => status == 'settled';

  String get initials {
    final words = name.split(' ').where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return '?';
    if (words.length == 1) return words.first.substring(0, 1).toUpperCase();
    return (words.first.substring(0, 1) + words.last.substring(0, 1))
        .toUpperCase();
  }
}

class ExpensePayerItem {
  final int participantId;
  final int? userId;
  final String? displayName;
  final String? avatar;
  final double amount;

  const ExpensePayerItem({
    required this.participantId,
    required this.amount,
    this.userId,
    this.displayName,
    this.avatar,
  });

  factory ExpensePayerItem.fromJson(Map<String, dynamic> json) {
    return ExpensePayerItem(
      participantId: (json['participant_id'] as num).toInt(),
      userId: json['user_id'] as int?,
      displayName: json['display_name'] as String?,
      avatar: json['avatar'] as String?,
      amount: (json['amount'] as num).toDouble(),
    );
  }

  String get name => displayName ?? 'Người trả';
}

class ExpenseDetail {
  final int expenseId;
  final int eventId;
  final String? eventTitle;
  final String title;
  final String? description;
  final double amount;
  final String currency;
  final String? expenseDate;
  final String splitMethod;
  final String? createdAt;
  final int? categoryId;
  final String? categoryName;
  final String? categoryIcon;
  final String? categoryColor;
  final int? payerParticipantId;
  final int? payerUserId;
  final String? payerName;
  final int? myParticipantId;
  final double? mySplitAmount;
  final String? mySplitStatus;
  final List<ExpenseSplitItem> splits;
  final List<ExpensePayerItem> payers;

  const ExpenseDetail({
    required this.expenseId,
    required this.eventId,
    required this.title,
    required this.amount,
    required this.currency,
    required this.splitMethod,
    required this.splits,
    this.payers = const [],
    this.eventTitle,
    this.description,
    this.expenseDate,
    this.createdAt,
    this.categoryId,
    this.categoryName,
    this.categoryIcon,
    this.categoryColor,
    this.payerParticipantId,
    this.payerUserId,
    this.payerName,
    this.myParticipantId,
    this.mySplitAmount,
    this.mySplitStatus,
  });

  factory ExpenseDetail.fromJson(Map<String, dynamic> json) {
    final category = json['category'] as Map<String, dynamic>?;
    final payer = json['payer'] as Map<String, dynamic>?;
    final mySplit = json['my_split'] as Map<String, dynamic>?;

    return ExpenseDetail(
      expenseId: (json['expense_id'] as num).toInt(),
      eventId: (json['event_id'] as num?)?.toInt() ?? 0,
      eventTitle: json['event_title'] as String?,
      title: json['title'] as String,
      description: json['description'] as String?,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'VND',
      expenseDate: json['expense_date'] as String?,
      splitMethod: json['split_method'] as String? ?? 'equal',
      createdAt: json['created_at'] as String?,
      categoryId: category?['category_id'] as int?,
      categoryName: category?['name'] as String?,
      categoryIcon: category?['icon'] as String?,
      categoryColor: category?['color'] as String?,
      payerParticipantId: payer?['participant_id'] as int?,
      payerUserId: payer?['user_id'] as int?,
      payerName: payer?['display_name'] as String?,
      myParticipantId: mySplit?['participant_id'] as int?,
      mySplitAmount: mySplit?['amount'] != null
          ? (mySplit!['amount'] as num).toDouble()
          : null,
      mySplitStatus: mySplit?['status'] as String?,
      splits: (json['splits'] as List<dynamic>? ?? [])
          .map((s) => ExpenseSplitItem.fromJson(s as Map<String, dynamic>))
          .toList(),
      payers: (json['payers'] as List<dynamic>? ?? [])
          .map((p) => ExpensePayerItem.fromJson(p as Map<String, dynamic>))
          .toList(),
    );
  }

  String get splitMethodLabel {
    switch (splitMethod) {
      case 'equal':
        return 'Chia đều';
      case 'exact':
        return 'Chia chính xác';
      case 'percentage':
        return 'Chia theo phần trăm';
      case 'share':
        return 'Chia theo phần';
      default:
        return 'Chia đều';
    }
  }

  bool get isMyDebt => mySplitStatus == 'pending';

  bool get isMyPaid => mySplitStatus == 'settled';
}
