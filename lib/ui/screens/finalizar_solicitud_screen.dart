import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/solicitud_provider.dart';
import '../widgets/image_capture_widget.dart';

class FinalizarSolicitudScreen extends StatefulWidget {
  final int solicitudId;
  const FinalizarSolicitudScreen({required this.solicitudId, super.key});

  @override
  State<FinalizarSolicitudScreen> createState() => _FinalizarSolicitudScreenState();
}

class _FinalizarSolicitudScreenState extends State<FinalizarSolicitudScreen> {
  final _comentarioController = TextEditingController();
  final List<String> _imageUrls = [];

  void _handleImagesUploaded(List<String> urls) {
    setState(() {
      _imageUrls.clear();
      _imageUrls.addAll(urls);
    });
  }

  void _finalizar() async {
    // Guardar el estado a 'Finalizado' con referencias a las imágenes
    // El backend puede actualizar la solicitud con las URLs de las imágenes
    await context.read<SolicitudProvider>().cambiarEstado(widget.solicitudId, "Finalizado");
    if (mounted) {
      Navigator.popUntil(context, (route) => route.isFirst);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_imageUrls.isEmpty
              ? "Trabajo finalizado con éxito"
              : "Trabajo finalizado con ${_imageUrls.length} foto(s) en la nube"),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cerrar Solicitud")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sección de comentarios
              const Text(
                "Comentarios sobre la solución:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _comentarioController,
                maxLines: 4,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: "Describe el trabajo realizado...",
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
              const SizedBox(height: 24),

              // Sección de captura de imágenes
              ImageCaptureWidget(
                onImagesUploaded: _handleImagesUploaded,
                maxImages: 5,
                label: "Fotos de la solución",
              ),

              const SizedBox(height: 24),

              // Información útil
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  border: Border.all(color: Colors.blue.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue.shade700, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Las imágenes se optimizan automáticamente (máx 800x800px) para ahorrar datos.",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Botón principal
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _finalizar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "CONFIRMAR FINALIZACIÓN",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}