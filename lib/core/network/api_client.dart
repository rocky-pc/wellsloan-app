import 'dart:io';
import 'package:dio/dio.dart';
import '../constants/api_endpoints.dart';
import '../storage/secure_storage_service.dart';
import 'api_exception.dart';

class ApiClient {
  late final Dio _dio;
  final SecureStorageService _storage = SecureStorageService();

  ApiClient({String? baseUrl}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? ApiEndpoints.activeBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          final errResponse = e.response;
          String message = "Network connection error. Please check your internet.";
          
          if (errResponse != null && errResponse.data != null) {
            final data = errResponse.data;
            if (data is Map) {
              if (data['errors'] != null && data['errors'] is Map) {
                // Flatten Laravel validation errors
                final errors = data['errors'] as Map;
                message = errors.values
                    .map((val) => val is List ? val.join(' ') : val.toString())
                    .join(' ');
              } else if (data['message'] != null) {
                message = data['message'].toString();
              } else if (data['error'] != null) {
                message = data['error'].toString();
              }
            }
          }

          final customException = ApiException(
            message: message,
            statusCode: errResponse?.statusCode,
            errors: errResponse?.data,
          );

          return handler.reject(
            DioException(
              requestOptions: e.requestOptions,
              error: customException,
              response: e.response,
              type: e.type,
            ),
          );
        },
      ),
    );
  }

  void updateBaseUrl(String newUrl) {
    _dio.options.baseUrl = newUrl;
  }

  Future<Response<T>> get<T>(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get<T>(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException(message: e.message ?? "Unexpected request failure");
    }
  }

  Future<Response<T>> post<T>(String path, {dynamic data}) async {
    try {
      return await _dio.post<T>(path, data: data);
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException(message: e.message ?? "Unexpected request failure");
    }
  }

  Future<Response<T>> patch<T>(String path, {dynamic data}) async {
    try {
      return await _dio.patch<T>(path, data: data);
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException(message: e.message ?? "Unexpected request failure");
    }
  }

  Future<Response<T>> uploadFile<T>(
    String path, {
    required File file,
    required String fileKey,
    required Map<String, dynamic> extraFields,
  }) async {
    try {
      final fileName = file.path.split(RegExp(r'[/\\]')).last;
      final formData = FormData.fromMap({
        ...extraFields,
        fileKey: await MultipartFile.fromFile(file.path, filename: fileName),
      });

      return await _dio.post<T>(
        path,
        data: formData,
      );
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException(message: e.message ?? "File upload failed");
    }
  }
}
