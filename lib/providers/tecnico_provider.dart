import 'package:flutter/material.dart';
import '../models/tecnico_model.dart';
import '../services/tecnico_service.dart';

class TecnicoProvider extends ChangeNotifier {
  final _service = TecnicoService();
  List<Tecnico> _tecnicos = [];
  bool _isLoading = false;

  List<Tecnico> get tecnicos => _tecnicos;
  bool get isLoading => _isLoading;

  Future<void> fetchTecnicos() async {
    _isLoading = true;
    notifyListeners();
    try {
      _tecnicos = await _service.getTecnicos();
    } catch (e) {
      debugPrint('Error al cargar técnicos: $e');
      _tecnicos = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> buscar(String query) async {
    _isLoading = true;
    notifyListeners();
    try {
      _tecnicos = await _service.buscarTecnicos(query);
    } catch (e) {
      debugPrint('Error al buscar técnicos: $e');
      _tecnicos = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> agregar(Tecnico tecnico) async {
    try {
      await _service.registrarTecnico(tecnico);
      await fetchTecnicos();
    } catch (e) {
      debugPrint('Error al agregar técnico: $e');
    }
  }
}