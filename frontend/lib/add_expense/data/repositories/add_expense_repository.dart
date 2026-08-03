import '../datasources/add_expense_datasource.dart';
import '../../domain/models/expense_model.dart';

class AddExpenseRepository {
  final AddExpenseDatasource _datasource = AddExpenseDatasource();

  List<ExpenseModel> getMockExpenses() => _datasource.getMockExpenses();

  ExpenseModel? getMockExpenseById(String id) =>
      _datasource.getMockExpenseById(id);

  ExpenseModel addMockExpense(ExpenseModel expense) =>
      _datasource.addMockExpense(expense);
}
