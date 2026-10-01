class PontoModel {
  final String id;
  final String userId;
  final String dataHora;
  final double latitude;
  final double longitude;
  final String tipo;
  final double distanciaMetros;

  PontoModel({
    required this.id,
    required this.userId,
    required this.dataHora,
    required this.latitude,
    required this.longitude,
    required this.tipo,
    required this.distanciaMetros,
  });

  // Converte o objeto para um Map para salvar no Firestore
  Map<String, dynamic> toMap() {
    // Este mapa representa o formato salvo na coleção do Firestore.
    return {
      'id': id,
      'userId': userId,
      'dataHora': dataHora,
      'latitude': latitude,
      'longitude': longitude,
      'tipo': tipo,
      'distanciaMetros': distanciaMetros,
    };
  }

  // Cria um PontoModel a partir de um documento do Firestore
  factory PontoModel.fromMap(Map<String, dynamic> map) {
    return PontoModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      dataHora: map['dataHora'] ?? '',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      tipo: map['tipo']?.toString() ?? 'entrada',
      distanciaMetros: (map['distanciaMetros'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
