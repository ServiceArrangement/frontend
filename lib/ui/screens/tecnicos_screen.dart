import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
                        leading: const CircleAvatar(child: Icon(Icons.person)),
                        title: Text(t.nombre),
                        subtitle: Text("${t.especialidad} • ${t.zona}"),
                        trailing: IconButton(
                          icon: const Icon(Icons.phone, color: Colors.green),
                          onPressed: () { /* Lógica para llamar */ },
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