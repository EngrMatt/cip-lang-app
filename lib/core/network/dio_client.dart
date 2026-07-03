import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/api_settings_provider.dart';
import '../config/app_config.dart';
import '../errors/app_exception.dart';

final dioProvider = Provider<Dio>((ref) {
  final baseUrl =
      ref.watch(apiBaseUrlProvider).valueOrNull ?? AppConfig.defaultApiBaseUrl;

  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 60),
      sendTimeout: const Duration(seconds: 120),
      validateStatus: (status) => status != null && status < 600,
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        // multipart 由 Dio 自動設定 boundary，不可帶 application/json
        if (options.data is! FormData) {
          options.headers.putIfAbsent(
            'Content-Type',
            () => 'application/json',
          );
        } else {
          options.headers.remove('Content-Type');
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        final code = response.statusCode ?? 0;
        if (code >= 400) {
          handler.reject(
            DioException(
              requestOptions: response.requestOptions,
              response: response,
              type: DioExceptionType.badResponse,
            ),
          );
          return;
        }
        handler.next(response);
      },
    ),
  );

  return dio;
});

AppException mapDioError(DioException error) {
  final status = error.response?.statusCode;
  final detail = error.response?.data;
  if (detail is Map && detail['detail'] != null) {
    final d = detail['detail'];
    if (d is String) return AppException(d, statusCode: status);
    if (d is List && d.isNotEmpty) {
      final first = d.first;
      if (first is Map && first['msg'] != null) {
        return AppException(first['msg'].toString(), statusCode: status);
      }
    }
  }
  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.sendTimeout:
      return AppException('連線逾時，請確認後端服務是否啟動', statusCode: status);
    case DioExceptionType.connectionError:
      return AppException(
        '無法連線至 API（${error.requestOptions.baseUrl}）',
        statusCode: status,
      );
    default:
      if (status == 500) {
        return AppException('伺服器錯誤，請確認後端與資料庫是否正常運行', statusCode: status);
      }
      return AppException(
        error.message ?? '網路請求失敗',
        statusCode: status,
      );
  }
}
