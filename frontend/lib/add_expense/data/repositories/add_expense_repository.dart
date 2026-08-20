import '../datasources/add_expense_datasource.dart';
import '../../domain/models/expense_model.dart';

class AddExpenseRepository {
  final AddExpenseDatasource _datasource = AddExpenseDatasource();

  List<ExpenseModel> getMockExpenses() => _datasource.getMockExpenses();

  ExpenseModel? getMockExpenseById(String id) =>
      _datasource.getMockExpenseById(id);

  ExpenseModel addMockExpense(ExpenseModel expense) =>
      _datasource.addMockExpense(expense);

  Future<Map<String, dynamic>> fetchCategories() {
    return _datasource.fetchCategories();
  }

  Future<Map<String, dynamic>> saveExpense({
    int? eventId,
    int? categoryId,
    required String title,
    required double amount,
    String currency = 'VND',
    String? description,
    String? expenseDate,
  }) {
    return _datasource.createExpense(
      eventId: eventId,
      categoryId: categoryId,
      title: title,
      amount: amount,
      currency: currency,
      description: description,
      expenseDate: expenseDate,
    );
  }
}