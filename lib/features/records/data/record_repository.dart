import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';
import '../../../models/record.dart';

final recordRepositoryProvider = Provider<RecordRepository>((ref) {
  return RecordRepository(ref.watch(dioProvider));
});

class RecordRepository {
  RecordRepository(this._dio);

  final Dio _dio;

  /// GET /records/map — 僅有座標的語料（地圖 marker）
  Future<RecordListResponse> fetchMapRecords({
    String? bbox,
    String? category,
    int limit = 500,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/records/map',
        queryParameters: {
          if (bbox != null && bbox.isNotEmpty) 'bbox': bbox,
          if (category != null && category.isNotEmpty) 'category': category,
          'limit': limit,
        },
      );
      return RecordListResponse.fromJson(response.data!);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  /// GET /records — docs/api.md
  Future<RecordListResponse> fetchRecords({
    int page = 1,
    int pageSize = 20,
    String? search,
    String? category,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/records',
        queryParameters: {
          'page': page,
          'page_size': pageSize,
          if (search != null && search.isNotEmpty) 'search': search,
          if (category != null && category.isNotEmpty) 'category': category,
        },
      );
      return RecordListResponse.fromJson(response.data!);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  /// GET /records/{id}
  Future<Record> fetchRecord(int id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/records/$id');
      return Record.fromJson(response.data!);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  /// POST /records → 201
  Future<Record> createRecord({
    required String title,
    required String category,
    String? note,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/records',
        data: {
          'title': title,
          'category': category,
          if (note != null && note.isNotEmpty) 'note': note,
          if (latitude != null && longitude != null) ...{
            'latitude': latitude,
            'longitude': longitude,
          },
        },
      );
      return Record.fromJson(response.data!);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  /// POST /upload/audio — multipart，上傳後後端已寫入 audio_url
  Future<String> uploadAudio({
    required int recordId,
    required File audioFile,
    void Function(int sent, int total)? onProgress,
  }) async {
    try {
      final filename = _basename(audioFile.path, fallback: 'recording.m4a');
      final formData = FormData.fromMap({
        'record_id': recordId.toString(),
        'file': await MultipartFile.fromFile(
          audioFile.path,
          filename: filename,
        ),
      });
      final response = await _dio.post<Map<String, dynamic>>(
        '/upload/audio',
        data: formData,
        onSendProgress: onProgress,
      );
      return response.data!['audio_url'] as String;
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  /// POST /upload/image — multipart，上傳後後端已寫入 image_url
  Future<String> uploadImage({
    required int recordId,
    required File imageFile,
    void Function(int sent, int total)? onProgress,
  }) async {
    try {
      final filename = _basename(imageFile.path, fallback: 'photo.jpg');
      final formData = FormData.fromMap({
        'record_id': recordId.toString(),
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: filename,
        ),
      });
      final response = await _dio.post<Map<String, dynamic>>(
        '/upload/image',
        data: formData,
        onSendProgress: onProgress,
      );
      return response.data!['image_url'] as String;
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  /// DELETE /records/{id} → 204
  Future<void> deleteRecord(int id) async {
    try {
      await _dio.delete<void>('/records/$id');
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  /// GET /health（選用）
  Future<bool> checkHealth() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/health');
      return response.data?['status'] == 'ok';
    } on DioException {
      return false;
    }
  }

  String _basename(String path, {required String fallback}) {
    final name = path.split(Platform.pathSeparator).last;
    return name.isNotEmpty ? name : fallback;
  }
}
