import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/solicitud_provider.dart';

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
    // Cargar datos al iniciar
    Future.microtask(() {
      if (mounted) {
        context.read<SolicitudProvider>().fetchSolicitudes(widget.estado);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SolicitudProvider>();

    if (provider.isLoading) return const Center(child: CircularProgressIndicator());

    return RefreshIndicator(
      onRefresh: () => provider.fetchSolicitudes(widget.estado),
      child: ListView.builder(
        itemCount: provider.solicitudes.length,
        itemBuilder: (context, index) {
          final sol = provider.solicitudes[index];
          return Card(
            margin: const EdgeInsets.all(10),
            child: ListTile(
              title: Text(sol.nombreCliente, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("${sol.tipoServicio} - ${sol.direccion}"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Aquí iría el detalle de la solicitud
              },
            ),
          );
        },
      ),
    );
  }
}