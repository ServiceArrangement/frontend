import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/solicitud_model.dart';
import '../../providers/solicitud_provider.dart';
import '../widgets/status_badge.dart';
import 'finalizar_solicitud_screen.dart';

class SolicitudDetailScreen extends StatefulWidget {
  final Solicitud solicitud;
  const SolicitudDetailScreen({required this.solicitud, super.key});

  @override
  State<SolicitudDetailScreen> createState() => _SolicitudDetailScreenState();
}

class _SolicitudDetailScreenState extends State<SolicitudDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final solicitud = widget.solicitud;
    return Scaffold(
      appBar: AppBar(title: const Text("Detalle de Solicitud")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StatusBadge(estado: solicitud.estado),
            const SizedBox(height: 20),
            Text(solicitud.nombreCliente, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text(solicitud.telefonoCliente, style: const TextStyle(color: Colors.grey)),
            const Divider(height: 30),
            const Text("Descripción del problema:", style: TextStyle(fontWeight: FontWeight.bold)),
            Text(solicitud.descripcion),
            const SizedBox(height: 20),
            
            // Mostrar imágenes si existen
            if (solicitud.imagenes.isNotEmpty) ...[
              const Text("Imágenes de la solicitud:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 12),
              SizedBox(
                height: 150,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: solicitud.imagenes.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          solicitud.imagenes[index],
                          width: 150,
                          height: 150,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Center(
                                child: Icon(Icons.image_not_supported, color: Colors.grey),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
            
            const Text("Dirección:", style: TextStyle(fontWeight: FontWeight.bold)),
            Text(solicitud.direccion),
            const SizedBox(height: 40),
            
            if (solicitud.estado == 'Pendiente')
              SizedBox(width: double.infinity, child: ElevatedButton(
                onPressed: () async {
                  final navigator = Navigator.of(context);
                  await context.read<SolicitudProvider>().cambiarEstado(solicitud.id!, "En Proceso");
                  if (mounted) navigator.pop();
                },
                child: const Text("Aceptar y empezar trabajo"),
              )),
              
            if (solicitud.estado == 'En Proceso')
              SizedBox(width: double.infinity, child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => FinalizarSolicitudScreen(solicitudId: solicitud.id!))),
                child: const Text("Registrar Evidencia y Finalizar"),
              )),
          ],
        ),
      ),
    );
  }
}