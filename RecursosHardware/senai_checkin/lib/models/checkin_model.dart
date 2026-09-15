// Modelo de dados para o registro de check-in
class CheckInModel {
  final int? id;
  final String dataHora;
  final double latitude;
  final double longitude;
  final String observacao;
  final String caminhoFoto;

  CheckInModel({
    this.id,
    required this.dataHora,
    required this.latitude,
    required this.longitude,
    required this.observacao,
    required this.caminhoFoto,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'data_hora': dataHora,
      'latitude': latitude,
      'longitude': longitude,
      'observacao': observacao,
      'caminho_da_foto': caminhoFoto,
    };
  }

  factory CheckInModel.fromMap(Map<String, dynamic> map) {
    return CheckInModel(
      id: map['id'],
      dataHora: map['data_hora'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      observacao: map['observacao'],
      caminhoFoto: map['caminho_da_foto'],
    );
  }
}