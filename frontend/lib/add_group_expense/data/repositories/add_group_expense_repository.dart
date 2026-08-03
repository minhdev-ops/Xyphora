import '../datasources/add_group_expense_datasource.dart';
import '../../domain/models/group_expense_model.dart';

class AddGroupExpenseRepository {
  final AddGroupExpenseDatasource _datasource = AddGroupExpenseDatasource();

  List<GroupExpenseModel> getMockExpenses() => _datasource.getMockExpenses();

  List<GroupMember> getMockMembers() => _datasource.getMockMembers();

  GroupExpenseModel? getMockExpenseById(String id) =>
      _datasource.getMockExpenseById(id);

  GroupExpenseModel addMockExpense(GroupExpenseModel expense) =>
      _datasource.addMockExpense(expense);
}
