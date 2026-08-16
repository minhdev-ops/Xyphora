class ExpenseHistoryItem {
  final int expenseId;
  final int eventId;
  final String? eventTitle;
  final String title;
  final String? description;
  final double amount;
  final String currency;
  final String? expenseDate;
  final String splitMethod;
  final int? categoryId;
  final String? categoryName;
  final String? categoryIcon;
  final String? categoryColor;
  final int? payerParticipantId;
  final int? payerUserId;
  final String? payerName;
  final double? mySplitAmount;
  final String? mySplitStatus;
  final int splitCount;

  const ExpenseHistoryItem({
    required this.expenseId,
    required this.eventId,
    required this.title,
    required this.amount,
    required this.currency,
    required this.splitMethod,
    required this.splitCount,
    this.eventTitle,
    this.description,
    this.expenseDate,
    this.categoryId,
    this.categoryName,
    this.categoryIcon,
    this.categoryColor,
    this.payerParticipantId,
    this.payerUserId,
    this.payerName,
    this.mySplitAmount,
    this.mySplitStatus,
  });

  factory ExpenseHistoryItem.fromJson(Map<String, dynamic> json) {
    final category = json['category'] as Map<String, dynamic>?;
    final payer = json['payer'] as Map<String, dynamic>?;
    final mySplit = json['my_split'] as Map<String, dynamic>?;

    return ExpenseHistoryItem(
      expenseId: (json['expense_id'] as num).toInt(),
      eventId: (json['event_id'] as num?)?.toInt() ?? 0,
      eventTitle: json['event_title'] as String?,
      title: json['title'] as String,
      description: json['description'] as String?,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'VND',
      expenseDate: json['expense_date'] as String?,
      splitMethod: json['split_method'] as String? ?? 'equal',
      categoryId: category?['category_id'] as int?,
      categoryName: category?['name'] as String?,
      categoryIcon: category?['icon'] as String?,
      categoryColor: category?['color'] as String?,
      payerParticipantId: payer?['participant_id'] as int?,
      payerUserId: payer?['user_id'] as int?,
      payerName: payer?['display_name'] as String?,
      mySplitAmount: mySplit?['amount'] != null
          ? (mySplit!['amount'] as num).toDouble()
          : null,
      mySplitStatus: mySplit?['status'] as String?,
      splitCount: (json['split_count'] as num?)?.toInt() ?? 0,
    );
  }

  bool get isMyDebt => mySplitStatus == 'pending' && payerUserId != null;

  bool get isPaid => mySplitStatus == 'settled';
}

class ExpensePageResult {
  final List<ExpenseHistoryItem> items;
  final int currentPage;
  final int perPage;
  final int total;
  final int lastPage;
  final double totalAmount;
  final double myTotalAmount;

  const ExpensePageResult({
    required this.items,
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.lastPage,
    required this.totalAmount,
    required this.myTotalAmount,
  });

  factory ExpensePageResult.fromJson(Map<String, dynamic> json) {
    final meta = json['meta'] as Map<String, dynamic>;
    final summary = json['summary'] as Map<String, dynamic>? ?? const {};

    return ExpensePageResult(
      items: (json['data'] as List<dynamic>? ?? [])
          .map((e) => ExpenseHistoryItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentPage: (meta['current_page'] as num).toInt(),
      perPage: (meta['per_page'] as num).toInt(),
      total: (meta['total'] as num).toInt(),
      lastPage: (meta['last_page'] as num).toInt(),
      totalAmount: (summary['total_amount'] as num?)?.toDouble() ?? 0,
      myTotalAmount: (summary['my_total_amount'] as num?)?.toDouble() ?? 0,
    );
  }
}