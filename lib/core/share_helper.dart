import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/solicitud_model.dart';

class ShareHelper {
  static Future<void> compartirSolicitud(Solicitud sol, String? imageUrl) async {
    // 1. Preparar el mensaje de texto
    String mensaje = """
🛠️ *TRABAJO FIXNOW*
👤 *Cliente:* ${sol.nombreCliente}
📍 *Dirección:* ${sol.direccion}
🔧 *Servicio:* ${sol.tipoServicio}
📝 *Descripción:* ${sol.descripcion}
""";

    try {
      if (imageUrl != null && imageUrl.isNotEmpty) {
        // 2. Si hay imagen, hay que descargarla temporalmente para compartirla
        final response = await http.get(Uri.parse(imageUrl));
        final documentDirectory = await getTemporaryDirectory();
        
        // Creamos un archivo temporal
        final file = File('${documentDirectory.path}/problema.png');
        file.writeAsBytesSync(response.bodyBytes);

        // 3. Compartir Imagen + Texto
        await Share.shareXFiles(
          [XFile(file.path)],
          text: mensaje,
        );
      } else {
        // 4. Si no hay imagen, compartir solo texto
        await Share.share(mensaje);
      }
    } catch (e) {
      print("Error al compartir: $e");
    }
  }
}