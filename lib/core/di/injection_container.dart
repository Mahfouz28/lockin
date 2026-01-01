// lib/core/di/injection_container.dart

import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:lockin/core/services/notifcation_service.dart';
import 'package:lockin/core/services/shared_prefs_service.dart';

import 'package:lockin/features/foucs_mode/cubit/focus_mode_cubit.dart';
import 'package:lockin/features/foucs_mode/services/installed_apps_service.dart';
import 'package:lockin/features/home/cubit/home_cubit.dart';

import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../network/network_info.dart';
import '../api/api_interceptors.dart';
import '../config/app_config.dart';

final sl = GetIt.instance;

/// تهيئة جميع التبعيات (Dependency Injection) في التطبيق
Future<void> initializeDependencies() async {
  // =================================================================
  // Services - Singletons (نسخة واحدة فقط في التطبيق كله)
  // =================================================================

  // Shared Preferences Service
  final sharedPrefs = SharedPrefsService();
  await sharedPrefs.init();
  sl.registerLazySingleton<SharedPrefsService>(() => sharedPrefs);

  // Notification Service
  sl.registerLazySingleton<NotificationService>(() => NotificationService());
  await sl<NotificationService>().initialize();

  // Installed Apps Service
  sl.registerLazySingleton<InstalledAppsService>(() => InstalledAppsService());

  // =================================================================
  // Core / Network Dependencies
  // =================================================================

  // Internet Connection Checker (مكتبة خارجية)
  sl.registerLazySingleton(() => InternetConnectionChecker.createInstance());

  // Network Info (للتحقق من وجود إنترنت)
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  // Dio (عميل HTTP)
  sl.registerLazySingleton<Dio>(() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // إضافة Interceptor لإدارة التوكنات أو الأخطاء العامة
    dio.interceptors.add(ApiInterceptor());

    // إضافة Pretty Logger في وضع الـ Debug فقط
    if (AppConfig.enableLogging) {
      dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseHeader: true,
          responseBody: true,
          error: true,
          compact: false,
        ),
      );
    }

    return dio;
  });

  // =================================================================
  // Cubits - Factories (نسخة جديدة كل مرة بنحتاجها)
  // =================================================================

  // Focus Mode Cubit
  sl.registerFactory<FocusModeCubit>(
    () => FocusModeCubit(
      sl<SharedPrefsService>(),
      sl<InstalledAppsService>(),
      sl<NotificationService>(),
    ),
  );

  // Home Cubit
  sl.registerFactory<HomeCubit>(() => HomeCubit(sl<NotificationService>()));

  // يمكنك إضافة المزيد هنا لاحقًا:
  // sl.registerFactory<SomeOtherCubit>(() => SomeOtherCubit(sl<SomeRepository>()));
  // sl.registerLazySingleton<SomeRepository>(() => SomeRepositoryImpl(sl<Dio>()));
}

/// لإعادة تعيين التبعيات أثناء الاختبارات (Testing)
Future<void> resetDependencies() async {
  await sl.reset();
}
