import 'package:injectable/injectable.dart';
import 'package:xyphora_frontend/add_expense/data/datasources/add_expense_datasource.dart';

@lazySingleton
class AddExpenseRepository {
  final AddExpenseDatasource _datasource;

  AddExpenseRepository(this._datasource);

  Future<Map<String, dynamic>> fetchCategories() {
    return _datasource.fetchCategories();
  }

  Future<Map<String, dynamic>> fetchEvents() {
    return _datasource.fetchEvents();
  }

  Future<Map<String, dynamic>> fetchEvent(int eventId) {
    return _datasource.fetchEvent(eventId);
  }

  Future<Map<String, dynamic>> saveExpense({
    int? eventId,
    int? categoryId,
    required String title,
    required double amount,
    String currency = 'VND',
    String? description,
    String? expenseDate,
    String? splitMethod,
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

  Future<Map<String, dynamic>> updateExpense({
    required int expenseId,
    int? eventId,
    int? categoryId,
    required String title,
    required double amount,
    String currency = 'VND',
    String? description,
    String? expenseDate,
    String? splitMethod,
    List<int> payerIds = const [],
    List<Map<String, dynamic>> splits = const [],
  }) {
    return _datasource.updateExpense(
      expenseId: expenseId,
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

  Future<Map<String, dynamic>> deleteExpense(int expenseId) {
    return _datasource.deleteExpense(expenseId);
  }
}