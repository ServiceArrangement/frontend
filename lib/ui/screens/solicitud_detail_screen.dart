import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

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
  bool _isSharing = false;

  // FUNCIÓN PARA LLAMAR AL CLIENTE
  Future<void> _llamarCliente(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  // FUNCIÓN PARA MANDAR WHATSAPP AL CLIENTE
  Future<void> _mensajeCliente(String phoneNumber) async {
    // Limpiamos el número de cualquier símbolo o espacio
    final String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    final String message = "Hola ${widget.solicitud.nombreCliente}, te contacto de FixNow sobre tu solicitud de ${widget.solicitud.tipoServicio}.";
    
    final Uri whatsappUri = Uri.parse(
      "https://wa.me/$cleanNumber?text=${Uri.encodeComponent(message)}"
    );

    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No se pudo abrir WhatsApp")),
        );
      }
    }
  }

  // FUNCIÓN PARA COMPARTIR CON EL TÉCNICO
  Future<void> _compartirSolicitud() async {
    setState(() => _isSharing = true);
    final solicitud = widget.solicitud;
    
    String mensaje = """
🛠️ *NUEVA SOLICITUD - FIXNOW*
-----------------------------
👤 *Cliente:* ${solicitud.nombreCliente}
📞 *Teléfono:* ${solicitud.telefonoCliente}
📍 *Dirección:* ${solicitud.direccion}
🔧 *Servicio:* ${solicitud.tipoServicio}
📝 *Problema:* ${solicitud.descripcion}
-----------------------------
""";

    try {
      if (solicitud.imagenes.isNotEmpty) {
        final response = await http.get(Uri.parse(solicitud.imagenes[0]));
        final documentDirectory = await getTemporaryDirectory();
        final file = File('${documentDirectory.path}/evidencia_problema.png');
        file.writeAsBytesSync(response.bodyBytes);

        await Share.shareXFiles([XFile(file.path)], text: mensaje);
      } else {
        await Share.share(mensaje);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error al preparar el envío")),
        );
      }
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final solicitud = widget.solicitud;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detalle de Solicitud"),
        actions: [
          if (_isSharing)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
            )
          else
            IconButton(
              icon: const Icon(Icons.share),
              tooltip: "Compartir con técnico",
              onPressed: _compartirSolicitud,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StatusBadge(estado: solicitud.estado),
            const SizedBox(height: 20),
            Text(solicitud.nombreCliente, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            
            // --- FILA DE CONTACTO: TELÉFONO + LLAMADA + WHATSAPP ---
            Row(
              children: [
                Text(solicitud.telefonoCliente, style: const TextStyle(color: Colors.grey, fontSize: 16)),
                const SizedBox(width: 15),
                // Botón Llamar
                IconButton(
                  icon: const Icon(Icons.phone, color: Colors.blue, size: 22),
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                  onPressed: () => _llamarCliente(solicitud.telefonoCliente),
                ),
                const SizedBox(width: 20),
                // Botón WhatsApp
                IconButton(
                  icon: const Icon(Icons.chat, color: Colors.green, size: 22),
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                  onPressed: () => _mensajeCliente(solicitud.telefonoCliente),
                ),
              ],
            ),
            
            const Divider(height: 30),
            
            const Text("Descripción del problema:", style: TextStyle(fontWeight: FontWeight.bold)),
            Text(solicitud.descripcion),
            const SizedBox(height: 25),
            
            if (solicitud.imagenes.isNotEmpty) ...[
              const Text("Imágenes de la solicitud:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 12),
              SizedBox(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: solicitud.imagenes.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          solicitud.imagenes[index],
                          width: 250, height: 180,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              width: 250, height: 180,
                              color: Colors.grey.shade100,
                              child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 25),
            ],
            
            const Text("Dirección de atención:", style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.red, size: 18),
                const SizedBox(width: 5),
                Expanded(child: Text(solicitud.direccion)),
              ],
            ),
            
            const SizedBox(height: 40),
            
            if (solicitud.estado == 'Pendiente')
              SizedBox(
                width: double.infinity, height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  onPressed: () async {
                    final navigator = Navigator.of(context);
                    await context.read<SolicitudProvider>().cambiarEstado(solicitud.id!, "En Proceso");
                    if (mounted) navigator.pop();
                  },
                  child: const Text("ACEPTAR Y EMPEZAR TRABAJO"),
                ),
              ),
              
            if (solicitud.estado == 'En Proceso')
              SizedBox(
                width: double.infinity, height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                  ),
                  onPressed: () => Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (_) => FinalizarSolicitudScreen(solicitudId: solicitud.id!))
                  ),
                  child: const Text("REGISTRAR EVIDENCIA Y FINALIZAR"),
                ),
              ),
          ],
        ),
      ),
    );
  }
}