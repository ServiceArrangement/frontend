import 'package:flutter/material.dart';
import 'dart:io';
import '../../services/image_helper.dart';
import '../../services/image_upload_service.dart';

/// Widget para capturar, mostrar y subir imágenes a Cloudinary
class ImageCaptureWidget extends StatefulWidget {
  final Function(List<String>) onImagesUploaded;
  final int maxImages;
  final String label;

  const ImageCaptureWidget({
    required this.onImagesUploaded,
    this.maxImages = 5,
    this.label = "Capturar o seleccionar fotos",
    super.key,
  });

  @override
  State<ImageCaptureWidget> createState() => _ImageCaptureWidgetState();
}

class _ImageCaptureWidgetState extends State<ImageCaptureWidget> {
  final ImageHelper _imageHelper = ImageHelper();
  final ImageUploadService _uploadService = ImageUploadService();
  final List<File> _selectedImages = [];
  final List<String> _uploadedUrls = [];
  final Map<String, bool> _uploadingStatus = {};
  bool _isLoading = false;

  Future<void> _captureFromCamera() async {
    setState(() => _isLoading = true);
    final image = await _imageHelper.takePhoto();
    if (image != null) {
      setState(() {
        if (_selectedImages.length < widget.maxImages) {
          _selectedImages.add(File(image.path));
        }
      });
    }
    setState(() => _isLoading = false);
  }

  Future<void> _pickFromGallery() async {
    setState(() => _isLoading = true);
    final images = await _imageHelper.pickMultipleImages();
    if (images.isNotEmpty) {
      setState(() {
        for (var image in images) {
          if (_selectedImages.length < widget.maxImages) {
            _selectedImages.add(File(image.path));
          }
        }
      });
    }
    setState(() => _isLoading = false);
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
      // Resetear URLs si se elimina una imagen
      if (_selectedImages.length < _uploadedUrls.length) {
        _uploadedUrls.clear();
      }
    });
  }

  Future<void> _uploadImages() async {
    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecciona al menos una imagen")),
      );
      return;
    }

    setState(() {
      for (var i = 0; i < _selectedImages.length; i++) {
        if (!_uploadingStatus.containsKey('image_$i')) {
          _uploadingStatus['image_$i'] = true;
        }
      }
      _isLoading = true;
    });

    try {
      final uploadedImages = await _uploadService.uploadMultipleImages(
        _selectedImages,
        folder: 'fixnow/solicitudes',
        onProgress: (current, total) {
          if (mounted) {
            setState(() {
              _uploadingStatus['image_${current - 1}'] = false;
            });
          }
        },
      );

      if (mounted) {
        _uploadedUrls.clear();
        for (var img in uploadedImages) {
          _uploadedUrls.add(img.url);
        }
        
        if (mounted) {
          setState(() => _isLoading = false);
          widget.onImagesUploaded(_uploadedUrls);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "${uploadedImages.length} imagen(es) subida(s) exitosamente",
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error al subir imágenes: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título
        Text(
          widget.label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),

        // Botones de acción (solo si no está subiendo)
        if (!_isLoading && _selectedImages.length < widget.maxImages)
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _captureFromCamera,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text("Cámara"),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _pickFromGallery,
                  icon: const Icon(Icons.photo_library),
                  label: const Text("Galería"),
                ),
              ),
            ],
          ),

        const SizedBox(height: 12),

        // Contador y estado
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "${_selectedImages.length}/${widget.maxImages} fotos",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            if (_uploadedUrls.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      "${_uploadedUrls.length} subida(s)",
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),

        const SizedBox(height: 12),

        // Grid de imágenes seleccionadas
        if (_selectedImages.isNotEmpty)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _selectedImages.length,
            itemBuilder: (context, index) {
              final imageFile = _selectedImages[index];
              final isUploading = _uploadingStatus['image_$index'] ?? false;
              final isUploaded = index < _uploadedUrls.length;

              return Stack(
                children: [
                  // Imagen
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      imageFile,
                      fit: BoxFit.cover,
                    ),
                  ),

                  // Overlay: Cargando
                  if (isUploading)
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.black.withValues(alpha: 0.5),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                    ),

                  // Overlay: Subida exitosa
                  if (isUploaded && !isUploading)
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.green.withValues(alpha: 0.3),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 32,
                        ),
                      ),
                    ),

                  // Botón para eliminar
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: !isUploading ? () => _removeImage(index) : null,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.red.shade600,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          isUploading ? Icons.hourglass_empty : Icons.close,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

        const SizedBox(height: 16),

        // Botón para subir imágenes
        if (_selectedImages.isNotEmpty && _uploadedUrls.length < _selectedImages.length)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _uploadImages,
              icon: _isLoading
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor,
                        ),
                      ),
                    )
                  : const Icon(Icons.cloud_upload),
              label: Text(_isLoading ? "Subiendo..." : "Subir a la nube"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
            ),
          ),
      ],
    );
  }
}
