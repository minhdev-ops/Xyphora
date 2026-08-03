class CategoryStat {
  final String name;
  final double amount;
  final int color;
  final int percent;

  const CategoryStat({
    required this.name,
    required this.amount,
    required this.color,
    required this.percent,
  });
}

class MonthlyStat {
  final String label;
  final double value;

  const MonthlyStat({required this.label, required this.value});
}

class TransactionItem {
  final String name;
  final String categoryName;
  final double amount;
  final int color;

  const TransactionItem({
    required this.name,
    required this.categoryName,
    required this.amount,
    required this.color,
  });
}
