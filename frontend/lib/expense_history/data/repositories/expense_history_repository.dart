import 'package:injectable/injectable.dart';
import 'package:xyphora_frontend/expense_history/data/datasources/expense_history_datasource.dart';
import 'package:xyphora_frontend/expense_history/domain/models/expense_history_item.dart';

@lazySingleton
class ExpenseHistoryRepository {
  final ExpenseHistoryDatasource _datasource;

  ExpenseHistoryRepository(this._datasource);

  Future<ExpensePageResult> fetchExpenses({
    int? eventId,
    int page = 1,
    int perPage = 15,
    DateTime? dateFrom,
    DateTime? dateTo,
    int? categoryId,
    int? payerId,
    String? search,
    String? mySplitStatus,
    String sort = 'desc',
  }) {
    return _datasource.fetchExpenses(
      eventId: eventId,
      page: page,
      perPage: perPage,
      dateFrom: dateFrom,
      dateTo: dateTo,
      categoryId: categoryId,
      payerId: payerId,
      search: search,
      mySplitStatus: mySplitStatus,
      sort: sort,
    );
  }

  Future<List<Map<String, dynamic>>> fetchCategories() {
    return _datasource.fetchCategories();
  }

  Future<List<Map<String, dynamic>>> fetchEvents() {
    return _datasource.fetchEvents();
  }
}