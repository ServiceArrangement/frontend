class Tecnico {
  final int? id;
  final String nombre;
  final String telefono;
  final String especialidad;
  final String zona;
  final double? latitud;
  final double? longitud;
  final String notas;
  final List<Map<String, dynamic>>? documentos;

  Tecnico({
    this.id,
    required this.nombre,
    required this.telefono,
    required this.especialidad,
    required this.zona,
    this.latitud,
    this.longitud,
    required this.notas,
    this.documentos,
  });

  factory Tecnico.fromJson(Map<String, dynamic> json) => Tecnico(
    id: json['id'],
    nombre: json['nombre'] ?? '',
    telefono: json['telefono'] ?? '',
    especialidad: json['especialidad'] ?? '',
    zona: json['zona'] ?? '',
    latitud: json['latitud']?.toDouble(),
    longitud: json['longitud']?.toDouble(),
    notas: json['notas'] ?? '',
    documentos: json['documentos'] != null ? List<Map<String, dynamic>>.from(json['documentos']) : [],
  );

  Map<String, dynamic> toJson() {
    final map = {
      "nombre": nombre,
      "telefono": telefono,
      "especialidad": especialidad,
      "zona": zona,
      "latitud": latitud ?? 0.0,
      "longitud": longitud ?? 0.0,
      "notas": notas,
      "documentos": documentos ?? [],
    };
    // Solo incluir 'id' si no es null (para actualizar)
    if (id != null) {
      map["id"] = id as Object;
    }
    return map;
  }
}