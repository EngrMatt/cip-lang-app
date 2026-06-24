import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import '../errors/app_exception.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ),
  );
  dio.interceptors.add(
    InterceptorsWrapper(
      onError: (error, handler) {
        handler.next(error);
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
        '無法連線至 API（${AppConfig.apiBaseUrl}）',
        statusCode: status,
      );
    default:
      return AppException(
        error.message ?? '網路請求失敗',
        statusCode: status,
      );
  }
}
