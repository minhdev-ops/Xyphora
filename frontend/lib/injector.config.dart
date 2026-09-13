// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:xyphora_frontend/add_expense/data/datasources/add_expense_datasource.dart'
    as _i715;
import 'package:xyphora_frontend/add_expense/data/repositories/add_expense_repository.dart'
    as _i112;
import 'package:xyphora_frontend/add_expense/data/services/add_expense_service.dart'
    as _i39;
import 'package:xyphora_frontend/auth/data/datasources/auth_datasource.dart'
    as _i38;
import 'package:xyphora_frontend/auth/data/repositories/auth_repository.dart'
    as _i261;
import 'package:xyphora_frontend/auth/data/services/auth_service.dart' as _i587;
import 'package:xyphora_frontend/category_list/data/datasources/category_list_datasource.dart'
    as _i280;
import 'package:xyphora_frontend/category_list/data/repositories/category_list_repository.dart'
    as _i573;
import 'package:xyphora_frontend/category_list/data/services/category_list_service.dart'
    as _i872;
import 'package:xyphora_frontend/event_management/data/datasources/event_datasource.dart'
    as _i982;
import 'package:xyphora_frontend/event_management/data/repositories/event_repository.dart'
    as _i28;
import 'package:xyphora_frontend/event_management/data/services/event_service.dart'
    as _i294;
import 'package:xyphora_frontend/expense_detail/data/datasources/expense_detail_datasource.dart'
    as _i303;
import 'package:xyphora_frontend/expense_detail/data/repositories/expense_detail_repository.dart'
    as _i469;
import 'package:xyphora_frontend/expense_detail/data/services/expense_detail_service.dart'
    as _i545;
import 'package:xyphora_frontend/expense_history/data/datasources/expense_history_datasource.dart'
    as _i161;
import 'package:xyphora_frontend/expense_history/data/repositories/expense_history_repository.dart'
    as _i929;
import 'package:xyphora_frontend/expense_history/data/services/expense_history_service.dart'
    as _i231;
import 'package:xyphora_frontend/statistics/data/datasources/statistics_datasource.dart'
    as _i34;
import 'package:xyphora_frontend/statistics/data/repositories/statistics_repository.dart'
    as _i1026;
import 'package:xyphora_frontend/statistics/data/services/statistics_service.dart'
    as _i306;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.lazySingleton<_i39.AddExpenseService>(() => _i39.AddExpenseService());
    gh.lazySingleton<_i587.AuthService>(() => _i587.AuthService());
    gh.lazySingleton<_i872.CategoryListService>(
      () => _i872.CategoryListService(),
    );
    gh.lazySingleton<_i294.EventService>(() => _i294.EventService());
    gh.lazySingleton<_i545.ExpenseDetailService>(
      () => _i545.ExpenseDetailService(),
    );
    gh.lazySingleton<_i231.ExpenseHistoryService>(
      () => _i231.ExpenseHistoryService(),
    );
    gh.lazySingleton<_i306.StatisticsService>(() => _i306.StatisticsService());
    gh.lazySingleton<_i982.EventDatasource>(
      () => _i982.EventDatasource(gh<_i294.EventService>()),
    );
    gh.lazySingleton<_i161.ExpenseHistoryDatasource>(
      () => _i161.ExpenseHistoryDatasource(gh<_i231.ExpenseHistoryService>()),
    );
    gh.lazySingleton<_i28.EventRepository>(
      () => _i28.EventRepository(gh<_i982.EventDatasource>()),
    );
    gh.lazySingleton<_i34.StatisticsDatasource>(
      () => _i34.StatisticsDatasource(gh<_i306.StatisticsService>()),
    );
    gh.lazySingleton<_i1026.StatisticsRepository>(
      () => _i1026.StatisticsRepository(gh<_i34.StatisticsDatasource>()),
    );
    gh.lazySingleton<_i280.CategoryListDatasource>(
      () => _i280.CategoryListDatasource(gh<_i872.CategoryListService>()),
    );
    gh.lazySingleton<_i303.ExpenseDetailDatasource>(
      () => _i303.ExpenseDetailDatasource(gh<_i545.ExpenseDetailService>()),
    );
    gh.lazySingleton<_i929.ExpenseHistoryRepository>(
      () =>
          _i929.ExpenseHistoryRepository(gh<_i161.ExpenseHistoryDatasource>()),
    );
    gh.lazySingleton<_i38.AuthDatasource>(
      () => _i38.AuthDatasource(gh<_i587.AuthService>()),
    );
    gh.lazySingleton<_i715.AddExpenseDatasource>(
      () => _i715.AddExpenseDatasource(gh<_i39.AddExpenseService>()),
    );
    gh.lazySingleton<_i112.AddExpenseRepository>(
      () => _i112.AddExpenseRepository(gh<_i715.AddExpenseDatasource>()),
    );
    gh.lazySingleton<_i469.ExpenseDetailRepository>(
      () => _i469.ExpenseDetailRepository(gh<_i303.ExpenseDetailDatasource>()),
    );
    gh.lazySingleton<_i573.CategoryListRepository>(
      () => _i573.CategoryListRepository(gh<_i280.CategoryListDatasource>()),
    );
    gh.lazySingleton<_i261.AuthRepository>(
      () => _i261.AuthRepository(gh<_i38.AuthDatasource>()),
    );
    return this;
  }
}
