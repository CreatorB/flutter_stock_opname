import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:syathiby/core/utils/logger_util.dart';
import 'package:syathiby/features/announcement/cubit/announcement_cubit.dart';
import 'package:syathiby/features/announcement/service/announcement_service.dart';
import 'package:syathiby/features/auth/login/bloc/login_bloc.dart';
import 'package:syathiby/features/auth/login/service/login_service.dart';
import 'package:syathiby/features/product/bloc/product_bloc.dart';
import 'package:syathiby/features/product/service/product_service.dart';
import 'package:syathiby/features/theme/bloc/theme_bloc.dart';

final sl = GetIt.instance;

Future<void> setupLocator() async {
  // Cubits/Blocs
  sl.registerFactory(() => AnnouncementCubit(sl()));
  sl.registerFactory(() => ThemeBloc());
  sl.registerFactory(() => LoginBloc(loginService: sl()));
  sl.registerFactory(() => ProductBloc(productService: sl()));

  // Services
  sl.registerLazySingleton<AnnouncementService>(
      () => AnnouncementService(sl()));
  sl.registerLazySingleton<LoginService>(
      () => LoginService(sl()));
  sl.registerLazySingleton<ProductService>(
      () => ProductService(sl()));

  // External
  sl.registerLazySingleton<Dio>(() {
    final dio = Dio(BaseOptions(
      baseUrl: dotenv.env['BASE_URL'] ?? '',
      headers: {
        'Accept': 'application/json',
      },
      // Add timeout
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
    ));

    // Add interceptor for debugging
dio.interceptors.add(InterceptorsWrapper(
    onError: (error, handler) async {
      if (error.response?.statusCode == 401) {
        LoggerUtil.error('Unauthorized', error);
      }
      return handler.next(error);
    },
  ));

  return dio;
  });
}
