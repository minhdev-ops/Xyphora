import '../datasources/expense_detail_datasource.dart';
import '../../domain/models/expense_detail.dart';

class ExpenseDetailRepository {
  final ExpenseDetailDatasource _datasource = ExpenseDetailDatasource();

  Future<ExpenseDetail> fetchExpenseDetail(int expenseId) {
    return _datasource.fetchExpenseDetail(expenseId);
  }
}
