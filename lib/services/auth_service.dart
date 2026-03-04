import 'package:dio/dio.dart';
import '../config/api_constants.dart';

class AuthService {
  final Dio _dio = Dio();

  Future<Map<String, dynamic>> login(String usuario, String password) async {
    try {
      final response = await _dio.post(
        ApiConstants.authLogin,
        data: {'usuario': usuario, 'password': password},
      );
      return response.data; // Retorna {token: "...", usuario: "..."}
    } on DioException catch (e) {
      throw e.response?.data['error'] ?? 'Error al conectar con el servidor';
    }
  }
}