class CategoryStatItem {
  final int categoryId;
  final String name;
  final String? icon;
  final String? color;
  final bool isDefault;
  final int expenseCount;
  final double totalAmount;

  const CategoryStatItem({
    required this.categoryId,
    required this.name,
    required this.isDefault,
    required this.expenseCount,
    required this.totalAmount,
    this.icon,
    this.color,
  });

  factory CategoryStatItem.fromJson(Map<String, dynamic> json) {
    return CategoryStatItem(
      categoryId: (json['category_id'] as num).toInt(),
      name: json['name']?.toString() ?? 'Khác',
      icon: json['icon'] as String?,
      color: json['color'] as String?,
      isDefault: json['is_default'] as bool? ?? false,
      expenseCount: (json['expense_count'] as num?)?.toInt() ?? 0,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0,
    );
  }

  String formatCurrency(double amount) {
    final str = amount.abs().round().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(str[i]);
    }
    return '${buffer.toString()}đ';
  }
}
