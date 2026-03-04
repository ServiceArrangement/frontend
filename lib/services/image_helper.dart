import 'package:image_picker/image_picker.dart';
import 'dart:io';

/// Helper para capturar y optimizar imágenes
class ImageHelper {
  final ImagePicker _picker = ImagePicker();

  /// Permite al usuario seleccionar una imagen desde la galería o cámara
  /// y la optimiza redimensionándola a máximo 800x800 px con 85% de calidad
  Future<XFile?> pickAndResizeImage({
    ImageSource source = ImageSource.gallery,
    double? maxWidth = 800,
    double? maxHeight = 800,
    int imageQuality = 85,
  }) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: maxWidth!,
        maxHeight: maxHeight!,
        imageQuality: imageQuality,
      );
      return pickedFile;
    } catch (e) {
      return null;
    }
  }

  /// Abre directamente la cámara para capturar una foto
  Future<XFile?> takePhoto({
    double maxWidth = 800,
    double maxHeight = 800,
    int imageQuality = 85,
  }) async {
    return await pickAndResizeImage(
      source: ImageSource.camera,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      imageQuality: imageQuality,
    );
  }

  /// Abre la galería para elegir una imagen
  Future<XFile?> pickFromGallery({
    double maxWidth = 800,
    double maxHeight = 800,
    int imageQuality = 85,
  }) async {
    return await pickAndResizeImage(
      source: ImageSource.gallery,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      imageQuality: imageQuality,
    );
  }

  /// Obtiene múltiples imágenes de la galería
  Future<List<XFile>> pickMultipleImages({
    double maxWidth = 800,
    double maxHeight = 800,
    int imageQuality = 85,
  }) async {
    try {
      final pickedFiles = await _picker.pickMultiImage(
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
      );
      return pickedFiles;
    } catch (e) {
      return [];
    }
  }

  /// Obtiene información del archivo (tamaño en KB)
  String getFileSizeInKB(XFile file) {
    int fileLength = File(file.path).lengthSync();
    return (fileLength / 1024).toStringAsFixed(2);
  }
}
