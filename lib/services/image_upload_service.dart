import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import '../config/api_constants.dart';
import '../core/api_client.dart';
import 'dart:io';

/// Modelo para la respuesta de subida de imagen
class ImageUploadResponse {
  final String url;
  final String publicId;
  final String uploadedAt;

  ImageUploadResponse({
    required this.url,
    required this.publicId,
    required this.uploadedAt,
  });

  factory ImageUploadResponse.fromJson(Map<String, dynamic> json) {
    return ImageUploadResponse(
      url: json['url'] ?? '',
      publicId: json['publicId'] ?? json['public_id'] ?? '',
      uploadedAt: json['uploadedAt'] ?? json['uploaded_at'] ?? DateTime.now().toString(),
    );
  }
}

/// Servicio para subir imágenes a Cloudinary a través del backend
class ImageUploadService {
  final ApiClient _apiClient = ApiClient();

  /// Sube una imagen a Cloudinary
  /// Retorna la URL pública de la imagen
  Future<ImageUploadResponse?> uploadImage(
    File imageFile, {
    String folder = 'fixnow/solicitudes',
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
          contentType: MediaType('image', 'jpeg'),
        ),
        'folder': folder,
        'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
      });

      final response = await _apiClient.instance.post(
        ApiConstants.uploadImage,
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ImageUploadResponse.fromJson(response.data);
      }

      throw Exception('Error en la subida: ${response.statusCode}');
    } catch (e) {
      return null;
    }
  }

  /// Sube múltiples imágenes a Cloudinary
  /// Retorna una lista de URLs públicas
  Future<List<ImageUploadResponse>> uploadMultipleImages(
    List<File> imageFiles, {
    String folder = 'fixnow/solicitudes',
    Function(int, int)? onProgress,
  }) async {
    final results = <ImageUploadResponse>[];

    for (int i = 0; i < imageFiles.length; i++) {
      final response = await uploadImage(
        imageFiles[i],
        folder: folder,
      );

      if (response != null) {
        results.add(response);
      }

      // Notificar progreso
      onProgress?.call(i + 1, imageFiles.length);
    }

    return results;
  }

  /// Elimina una imagen de Cloudinary
  Future<bool> deleteImage(String publicId) async {
    try {
      final response = await _apiClient.instance.post(
        ApiConstants.deleteImage,
        data: {'publicId': publicId},
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
