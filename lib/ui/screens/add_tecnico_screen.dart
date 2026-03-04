import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/tecnico_model.dart';
import '../../providers/tecnico_provider.dart';

class AddTecnicoScreen extends StatefulWidget {
  const AddTecnicoScreen({super.key});

  @override
  State<AddTecnicoScreen> createState() => _AddTecnicoScreenState();
}

class _AddTecnicoScreenState extends State<AddTecnicoScreen> {
  final _formKey = GlobalKey<FormState>();
  String nombre = '', telefono = '', especialidad = '', zona = '', notas = '';
  String tipoDocumento = '', urlArchivo = '';
  bool _isLoading = false;

  void _save() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      setState(() => _isLoading = true);
      
      try {
        // Crear lista de documentos
        List<Map<String, dynamic>> documentos = [];
        if (tipoDocumento.isNotEmpty && urlArchivo.isNotEmpty) {
          documentos.add({
            "tipoDocumento": tipoDocumento,
            "urlArchivo": urlArchivo,
          });
        }
        
        final nuevo = Tecnico(
          nombre: nombre, 
          telefono: telefono, 
          especialidad: especialidad, 
          zona: zona, 
          notas: notas,
          documentos: documentos,
        );
        
        debugPrint('Enviando técnico: ${nuevo.toJson()}');
        
        await context.read<TecnicoProvider>().agregar(nuevo);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Técnico guardado exitosamente'))
          );
          Navigator.pop(context);
        }
      } catch (e) {
        setState(() => _isLoading = false);
        debugPrint('Error al guardar: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'), 
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            )
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nuevo Técnico")),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(decoration: const InputDecoration(labelText: "Nombre Completo"), onSaved: (v) => nombre = v!),
            TextFormField(decoration: const InputDecoration(labelText: "Teléfono"), onSaved: (v) => telefono = v!),
            TextFormField(decoration: const InputDecoration(labelText: "Especialidad"), onSaved: (v) => especialidad = v!),
            TextFormField(decoration: const InputDecoration(labelText: "Zona"), onSaved: (v) => zona = v!),
            TextFormField(decoration: const InputDecoration(labelText: "Notas"), maxLines: 3, onSaved: (v) => notas = v!),
            const SizedBox(height: 20),
            const Text("Documentos (Opcional)", style: TextStyle(fontWeight: FontWeight.bold)),
            TextFormField(
              decoration: const InputDecoration(labelText: "Tipo de Documento (ej: Cédula)"),
              onSaved: (v) => tipoDocumento = v ?? '',
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: "URL del Archivo"),
              onSaved: (v) => urlArchivo = v ?? '',
            ),
            const SizedBox(height: 20),
            _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton(onPressed: _save, child: const Text("Guardar Técnico")),
          ],
        ),
      ),
    );
  }
}