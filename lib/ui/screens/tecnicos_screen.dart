import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart'; // IMPORTANTE: Agregamos esto
import '../../providers/tecnico_provider.dart';
import 'add_tecnico_screen.dart';

class TecnicosScreen extends StatefulWidget {
  const TecnicosScreen({super.key});

  @override
  State<TecnicosScreen> createState() => _TecnicosScreenState();
}

class _TecnicosScreenState extends State<TecnicosScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<TecnicoProvider>().fetchTecnicos();
      }
    });
  }

  // FUNCIÓN PARA REALIZAR LA LLAMADA
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      debugPrint('No se pudo abrir el marcador para $phoneNumber');
    }
  }

  // FUNCIÓN PARA WHATSAPP (Opcional pero recomendada)
  Future<void> _openWhatsApp(String phoneNumber) async {
    final String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    final Uri whatsappUri = Uri.parse("https://wa.me/$cleanNumber?text=Hola, te contacto de FixNow.");
    
    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TecnicoProvider>();

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: "Buscar por especialidad o zona...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (val) => provider.buscar(val),
            ),
          ),
          Expanded(
            child: provider.isLoading 
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: () => provider.fetchTecnicos(),
                  child: ListView.builder(
                    itemCount: provider.tecnicos.length,
                    itemBuilder: (context, index) {
                      final t = provider.tecnicos[index];
                      return ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.blueAccent,
                          child: Icon(Icons.person, color: Colors.white)
                        ),
                        title: Text(t.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("${t.especialidad} • ${t.zona}"),
                        trailing: Row( // Agregamos Row para tener dos botones
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // BOTÓN DE WHATSAPP
                            IconButton(
                              icon: const Icon(Icons.message, color: Colors.green),
                              onPressed: () => _openWhatsApp(t.telefono),
                            ),
                            // BOTÓN DE LLAMADA
                            IconButton(
                              icon: const Icon(Icons.phone, color: Colors.blue),
                              onPressed: () => _makePhoneCall(t.telefono),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context, 
            MaterialPageRoute(builder: (_) => const AddTecnicoScreen())
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}