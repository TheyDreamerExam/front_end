import 'package:coord_converter/core/interceptors/api_interceptor.dart';
import 'package:coord_converter/features/data/api/coord_client.dart';
import 'package:coord_converter/features/data/datasource/app_datasource.dart';
import 'package:coord_converter/features/data/repository/app_repository_impl.dart';
import 'package:coord_converter/features/domain/repository/app_repository.dart';
import 'package:coord_converter/features/presentation/converter/converter_bloc.dart';
import 'package:coord_converter/features/presentation/settings/settings_bloc.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

final GetIt vf = GetIt.instance;

Future<void> init() async {
  Dio dio = Dio();
  dio.interceptors.add(ApiInterceptor());

  //LIBRARY

  //API
  vf.registerLazySingleton<CoordClient>(() => CoordClient(dio));

  //DATASOURCE
  vf.registerLazySingleton<AppDataSource>(
    () => AppDataSourceImpl(
      client: vf.call(),
    ),
  );

  //REPOSITORY
  vf.registerLazySingleton<AppRepository>(
    () => AppRepositoryImpl(
      dataSource: vf.call(),
    ),
  );

  //USE CASE

  //BLOC
  vf.registerLazySingleton<ConverterCubit>(
    () => ConverterCubit(
      repository: vf.call(),
    ),
  );
  vf.registerLazySingleton<SettingsCubit>(() => SettingsCubit());
}
