import '../core/api_client.dart';
import '../models/tecnico_model.dart';
import '../config/api_constants.dart';

class TecnicoService {
  final _apiClient = ApiClient();

  Future<List<Tecnico>> getTecnicos() async {
    final response = await _apiClient.instance.get(ApiConstants.tecnicos);
    return (response.data as List).map((t) => Tecnico.fromJson(t)).toList();
  }

  Future<List<Tecnico>> buscarTecnicos(String query) async {
    final response = await _apiClient.instance.get(
      "${ApiConstants.tecnicos}/buscar",
      queryParameters: {'query': query},
    );
    return (response.data as List).map((t) => Tecnico.fromJson(t)).toList();
  }

  Future<void> registrarTecnico(Tecnico tecnico) async {
    await _apiClient.instance.post(ApiConstants.tecnicos, data: tecnico.toJson());
  }

  Future<void> eliminarTecnico(int id) async {
    await _apiClient.instance.delete("${ApiConstants.tecnicos}/$id");
  }
}