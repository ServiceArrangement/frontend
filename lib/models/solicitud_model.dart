class Solicitud {
  final int? id;
  final String nombreCliente;
  final String telefonoCliente;
  final String direccion;
  final String descripcion;
  final String tipoServicio;
  final String estado;
  final String? fecha;
  final List<String> imagenes;

  Solicitud({
    this.id,
    required this.nombreCliente,
    required this.telefonoCliente,
    required this.direccion,
    required this.descripcion,
    required this.tipoServicio,
    required this.estado,
    this.fecha,
    this.imagenes = const [],
  });

  factory Solicitud.fromJson(Map<String, dynamic> json) {
    // Parsear imagenes - pueden venir como array de objetos o array de strings
    List<String> imagesList = [];
    if (json['imagenes'] != null && json['imagenes'] is List) {
      final imagenesRaw = json['imagenes'] as List;
      imagesList = imagenesRaw.map((img) {
        if (img is String) {
          return img;
        } else if (img is Map && img.containsKey('urlImagen')) {
          return img['urlImagen'].toString();
        }
        return '';
      }).where((img) => img.isNotEmpty).toList();
    }

    return Solicitud(
      id: json['id'],
      nombreCliente: json['nombreCliente'] ?? '',
      telefonoCliente: json['telefonoCliente'] ?? '',
      direccion: json['direccion'] ?? '',
      descripcion: json['descripcion'] ?? '',
      tipoServicio: json['tipoServicio'] ?? '',
      estado: json['estado'] ?? 'Pendiente',
      fecha: json['fecha'],
      imagenes: imagesList,
    );
  }
}