import 'package:flutter/material.dart';
import '../models/solicitud_model.dart';
import '../services/solicitud_service.dart';

class SolicitudProvider extends ChangeNotifier {
  final _service = SolicitudService();
  List<Solicitud> _solicitudes = [];
  bool _isLoading = false;

  List<Solicitud> get solicitudes => _solicitudes;
  bool get isLoading => _isLoading;

  Future<void> fetchSolicitudes(String? estado) async {
    _isLoading = true;
    notifyListeners();
    try {
      _solicitudes = await _service.getSolicitudes(estado);
    } catch (e) {
      debugPrint('Error al cargar solicitudes: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> cambiarEstado(int id, String nuevoEstado) async {
    try {
      await _service.actualizarEstado(id, nuevoEstado);
      // Removemos o actualizamos localmente para no recargar todo
      _solicitudes.removeWhere((s) => s.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error al cambiar estado: $e');
    }
  }
}