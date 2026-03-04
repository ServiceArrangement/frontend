import '../core/api_client.dart';
import '../models/solicitud_model.dart';
import '../config/api_constants.dart';

class SolicitudService {
  final _apiClient = ApiClient();

  Future<List<Solicitud>> getSolicitudes(String? estado) async {
    try {
      final response = await _apiClient.instance.get(
        ApiConstants.solicitudes,
        queryParameters: estado != null ? {'estado': estado} : null,
      );
      return (response.data as List).map((s) => Solicitud.fromJson(s)).toList();
    } catch (e) {
      throw 'Error al obtener solicitudes';
    }
  }

  Future<void> actualizarEstado(int id, String nuevoEstado) async {
    try {
      await _apiClient.instance.patch(
        "${ApiConstants.solicitudes}/$id/estado",
        queryParameters: {'nuevoEstado': nuevoEstado},
      );
    } catch (e) {
      throw 'Error al actualizar estado';
    }
  }
}