import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ponto_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> salvarPonto(PontoModel ponto) async {
    // O ID combina usuário e horário para evitar sobrescrever registros.
    try {
      await _firestore
          .collection('registros_ponto')
          .doc(ponto.id)
          .set(ponto.toMap());
    } catch (e) {
      throw 'Erro ao salvar ponto no Firebase: $e';
    }
  }

  Stream<List<PontoModel>> streamPontos(String userId) {
    return _firestore
        .collection('registros_ponto')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final pontos = snapshot.docs
              .map((document) => PontoModel.fromMap(document.data()))
              .toList();
          pontos.sort((a, b) => b.dataHora.compareTo(a.dataHora));
          return pontos;
        });
  }
}
