import '../datasources/add_group_expense_datasource.dart';

class AddGroupExpenseRepository {
  final AddGroupExpenseDatasource _datasource = AddGroupExpenseDatasource();

  Future<Map<String, dynamic>> fetchEvent(int eventId) {
    return _datasource.fetchEvent(eventId);
  }

  Future<Map<String, dynamic>> fetchCategories() {
    return _datasource.fetchCategories();
  }

  Future<Map<String, dynamic>> saveExpense({
    required int eventId,
    int? categoryId,
    required String title,
    required double amount,
    String currency = 'VND',
    String? description,
    String? expenseDate,
    String splitMethod = 'equal',
    List<int> payerIds = const [],
    List<Map<String, dynamic>> splits = const [],
  }) {
    return _datasource.createExpense(
      eventId: eventId,
      categoryId: categoryId,
      title: title,
      amount: amount,
      currency: currency,
      description: description,
      expenseDate: expenseDate,
      splitMethod: splitMethod,
      payerIds: payerIds,
      splits: splits,
    );
  }
}