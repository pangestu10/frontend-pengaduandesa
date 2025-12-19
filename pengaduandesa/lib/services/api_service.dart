import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/env.dart';
import '../models/api_response.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late Dio _dio;
  String? _token;

  void setToken(String token) {
    _token = token;
    _updateHeaders();
  }

  void clearToken() {
    _token = null;
    _updateHeaders();
  }

  void _updateHeaders() {
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
    };
  }

  Future<void> init() async {
    _dio = Dio(BaseOptions(
      baseUrl: Env.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: Env.headers,
    ));

    // Add interceptors
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (kDebugMode) {
          print('🚀 [${options.method}] ${options.baseUrl}${options.path}');
          if (options.data != null) {
            print('📦 Request Data: ${options.data}');
          }
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        if (kDebugMode) {
          print('✅ Response [${response.statusCode}]');
          print('📦 Response Data: ${response.data}');
        }
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        if (kDebugMode) {
          print('❌ Error [${e.response?.statusCode}]: ${e.message}');
          print('📦 Error Response: ${e.response?.data}');
        }
        return handler.next(e);
      },
    ));
  }

  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
      );
      
      // Null safety check
      if (response.data == null) {
        return ApiResponse<T>(
          success: false,
          message: 'Response dari server kosong',
          data: null,
        );
      }
      
      return ApiResponse.fromJson(response.data, fromJson);
    } on DioException catch (e) {
      return _handleError<T>(e);
    }
  }

  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final response = await _dio.post(path, data: data);
      
      // Null safety check
      if (response.data == null) {
        return ApiResponse<T>(
          success: false,
          message: 'Response dari server kosong',
          data: null,
        );
      }
      
      return ApiResponse.fromJson(response.data, fromJson);
    } on DioException catch (e) {
      return _handleError<T>(e);
    }
  }

  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    T Function(Map<String, dynamic>)? fromJson, 
    required bool isFormData,
  }) async {
    try {
      final response = await _dio.put(path, data: data);
      
      // Null safety check
      if (response.data == null) {
        return ApiResponse<T>(
          success: false,
          message: 'Response dari server kosong',
          data: null,
        );
      }
      
      return ApiResponse.fromJson(response.data, fromJson);
    } on DioException catch (e) {
      return _handleError<T>(e);
    }
  }

  Future<ApiResponse<T>> delete<T>(
    String path, {
    dynamic data,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final response = await _dio.delete(path, data: data);
      return ApiResponse.fromJson(response.data, fromJson);
    } on DioException catch (e) {
      return _handleError<T>(e);
    }
  }

  Future<ApiResponse<T>> upload<T>(
    String path, {
    required FormData data,
    T Function(Map<String, dynamic>)? fromJson,
    void Function(int, int)? onSendProgress,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        onSendProgress: onSendProgress,
      );
      
      // Null safety check
      if (response.data == null) {
        return ApiResponse<T>(
          success: false,
          message: 'Response dari server kosong',
          data: null,
        );
      }
      
      return ApiResponse.fromJson(response.data, fromJson);
    } on DioException catch (e) {
      return _handleError<T>(e);
    }
  }

  ApiResponse<T> _handleError<T>(DioException e) {
    if (e.response != null) {
      final statusCode = e.response!.statusCode;
      final responseData = e.response!.data;
      
      // Pastikan responseData adalah Map
      if (responseData is Map<String, dynamic>) {
        // Gunakan message dari backend jika ada
        final backendMessage = responseData['message'] as String?;
        
        // Handle status code khusus
        String finalMessage = backendMessage ?? 'Terjadi kesalahan';
        
        if (statusCode == 401) {
          finalMessage = backendMessage ?? 'Sesi Anda telah berakhir. Silakan login ulang.';
        } else if (statusCode == 403) {
          finalMessage = backendMessage ?? 'Akses ditolak. Anda tidak memiliki izin untuk melakukan aksi ini.';
        } else if (statusCode == 500) {
          finalMessage = backendMessage ?? 'Terjadi kesalahan pada server. Silakan coba lagi nanti.';
        }
        
        return ApiResponse<T>(
          success: false,
          message: finalMessage,
          data: null,
          error: responseData['error'],
        );
      } else {
        // Jika response bukan Map, buat response error generic
        return ApiResponse<T>(
          success: false,
          message: 'Terjadi kesalahan pada server',
          data: null,
          error: responseData,
        );
      }
    } else {
      // Network error atau tidak ada response
      return ApiResponse<T>(
        success: false,
        message: 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
        data: null,
        error: e.message,
      );
    }
  }
}