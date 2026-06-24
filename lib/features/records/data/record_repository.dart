import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/network/dio_client.dart';
import '../../../models/record.dart';

final recordRepositoryProvider = Provider<RecordRepository>((ref) {
  return RecordRepository(ref.watch(dioProvider));
});

class RecordRepository {
  RecordRepository(this._dio);

  final Dio _dio;

  Future<RecordListResponse> fetchRecords({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/records',
        queryParameters: {'page': page, 'page_size': pageSize},
      );
      return RecordListResponse.fromJson(response.data!);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<Record> fetchRecord(int id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/records/$id');
      return Record.fromJson(response.data!);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  /// POST /records — 見 docs/api.md（後端尚未實作時會回傳 404/405）
  Future<Record> createRecord({
    required String title,
    required String category,
    String? note,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/records',
        data: {
          'title': title,
          'category': category,
          if (note != null && note.isNotEmpty) 'note': note,
        },
      );
      return Record.fromJson(response.data!);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404 || e.response?.statusCode == 405) {
        throw AppException(
          '後端尚未提供 POST /records 端點，請先於後端實作新增語料 API',
          statusCode: e.response?.statusCode,
        );
      }
      throw mapDioError(e);
    }
  }

  /// POST /upload/audio — MVP 規格端點
  Future<String> uploadAudio({
    required int recordId,
    required File audioFile,
  }) async {
    try {
      final formData = FormData.fromMap({
        'record_id': recordId,
        'file': await MultipartFile.fromFile(
          audioFile.path,
          filename: 'recording.m4a',
        ),
      });
      final response = await _dio.post<Map<String, dynamic>>(
        '/upload/audio',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      return response.data!['audio_url'] as String;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404 || e.response?.statusCode == 405) {
        throw AppException(
          '後端尚未提供 POST /upload/audio 端點',
          statusCode: e.response?.statusCode,
        );
      }
      throw mapDioError(e);
    }
  }

  /// POST /upload/image — MVP 規格端點
  Future<String> uploadImage({
    required int recordId,
    required File imageFile,
  }) async {
    try {
      final formData = FormData.fromMap({
        'record_id': recordId,
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: 'photo.jpg',
        ),
      });
      final response = await _dio.post<Map<String, dynamic>>(
        '/upload/image',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      return response.data!['image_url'] as String;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404 || e.response?.statusCode == 405) {
        throw AppException(
          '後端尚未提供 POST /upload/image 端點',
          statusCode: e.response?.statusCode,
        );
      }
      throw mapDioError(e);
    }
  }

  Future<Record> updateRecordUrls({
    required int recordId,
    String? audioUrl,
    String? imageUrl,
  }) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        '/records/$recordId',
        data: {
          if (audioUrl != null) 'audio_url': audioUrl,
          if (imageUrl != null) 'image_url': imageUrl,
        },
      );
      return Record.fromJson(response.data!);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
