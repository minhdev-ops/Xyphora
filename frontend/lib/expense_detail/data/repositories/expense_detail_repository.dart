import 'package:injectable/injectable.dart';
import 'package:xyphora_frontend/expense_detail/data/datasources/expense_detail_datasource.dart';
import 'package:xyphora_frontend/expense_detail/domain/models/expense_detail.dart';

@lazySingleton
class ExpenseDetailRepository {
  final ExpenseDetailDatasource _datasource;

  ExpenseDetailRepository(this._datasource);

  Future<ExpenseDetail> fetchExpenseDetail(int expenseId) {
    return _datasource.fetchExpenseDetail(expenseId);
  }

  Future<Map<String, dynamic>> deleteExpense(int expenseId) {
    return _datasource.deleteExpense(expenseId);
  }
}