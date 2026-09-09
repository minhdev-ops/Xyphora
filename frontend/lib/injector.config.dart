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
import 'package:xyphora_frontend/auth/data/datasources/auth_datasource.dart'
    as _i38;
import 'package:xyphora_frontend/auth/data/repositories/auth_repository.dart'
    as _i261;
import 'package:xyphora_frontend/auth/data/services/auth_service.dart' as _i587;
import 'package:xyphora_frontend/event_management/data/datasources/event_datasource.dart'
    as _i982;
import 'package:xyphora_frontend/event_management/data/repositories/event_repository.dart'
    as _i28;
import 'package:xyphora_frontend/event_management/data/services/event_service.dart'
    as _i294;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.lazySingleton<_i587.AuthService>(() => _i587.AuthService());
    gh.lazySingleton<_i294.EventService>(() => _i294.EventService());
    gh.lazySingleton<_i982.EventDatasource>(
      () => _i982.EventDatasource(gh<_i294.EventService>()),
    );
    gh.lazySingleton<_i28.EventRepository>(
      () => _i28.EventRepository(gh<_i982.EventDatasource>()),
    );
    gh.lazySingleton<_i38.AuthDatasource>(
      () => _i38.AuthDatasource(gh<_i587.AuthService>()),
    );
    gh.lazySingleton<_i261.AuthRepository>(
      () => _i261.AuthRepository(gh<_i38.AuthDatasource>()),
    );
    return this;
  }
}
