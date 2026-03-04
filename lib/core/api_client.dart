import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'auth_storage.dart';

class ApiClient {
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
    ),
  );
  final AuthStorage _storage = AuthStorage();

  ApiClient() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        String? token = await _storage.getToken();
        if (token != null) {
          options.headers["Authorization"] = "Bearer $token";
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        // Log del error para debugging
        debugPrint('API Error [${e.response?.statusCode}]: ${e.message}');
        
        // Si es error 403 (Unauthorized), simplemente propagar
        // El provider manejará el redireccionamiento al login
        return handler.next(e);
      },
    ));
  }

  Dio get instance => _dio;
}