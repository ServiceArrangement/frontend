import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/solicitud_provider.dart';
import '../../models/solicitud_model.dart';
import '../screens/solicitud_detail_screen.dart';
import 'status_badge.dart';

class SolicitudesListView extends StatefulWidget {
  final String estado;

  const SolicitudesListView({required this.estado, super.key});

  @override
  State<SolicitudesListView> createState() => _SolicitudesListViewState();
}

class _SolicitudesListViewState extends State<SolicitudesListView> {
  @override
  void initState() {
    super.initState();
    // Cargamos los datos del servidor apenas se construye este widget
    // Usamos microtask para evitar errores de construcción de Flutter
    Future.microtask(() {
      if (mounted) {
        context.read<SolicitudProvider>().fetchSolicitudes(widget.estado);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SolicitudProvider>();

    // 1. Mostrar cargando si la petición está en curso
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // 2. Mostrar mensaje si no hay solicitudes en este estado
    if (provider.solicitudes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_late_outlined, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 10),
            Text(
              "No hay solicitudes ${widget.estado.toLowerCase()}s",
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      );
    }

    // 3. Mostrar la lista con "Deslizar para refrescar"
    return RefreshIndicator(
      onRefresh: () => provider.fetchSolicitudes(widget.estado),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 10),
        itemCount: provider.solicitudes.length,
        itemBuilder: (context, index) {
          final Solicitud sol = provider.solicitudes[index];

          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(15),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      sol.nombreCliente,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  StatusBadge(estado: sol.estado), // El badge que hicimos en la Parte 5
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.build, size: 14, color: Colors.blue),
                      const SizedBox(width: 5),
                      Text(sol.tipoServicio, style: const TextStyle(color: Colors.black87)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: Colors.redAccent),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          sol.direccion,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              onTap: () {
                // Navegación al detalle enviando el objeto solicitud
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SolicitudDetailScreen(solicitud: sol),
                  ),
                ).then((_) {
                  // Al regresar del detalle, refrescamos la lista por si hubo cambios
                  provider.fetchSolicitudes(widget.estado);
                });
              },
            ),
          );
        },
      ),
    );
  }
}