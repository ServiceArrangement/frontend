class Documento {
  final int? id;
  final String tipoDocumento;
  final String urlArchivo;

  Documento({
    this.id,
    required this.tipoDocumento,
    required this.urlArchivo,
  });

  factory Documento.fromJson(Map<String, dynamic> json) => Documento(
    id: json['id'],
    tipoDocumento: json['tipoDocumento'] ?? '',
    urlArchivo: json['urlArchivo'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    "tipoDocumento": tipoDocumento,
    "urlArchivo": urlArchivo,
  };
}
