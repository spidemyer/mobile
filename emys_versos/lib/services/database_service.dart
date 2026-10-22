import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Salvar/Adicionar Livro
  Future<void> saveBook(String userId, BookModel book) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('books')
        .doc(book.id)
        .set(book.toFirestore(), SetOptions(merge: true));
  }

  // Mover de Estante
  Future<void> updateBookStatus(
      String userId, String bookId, String newStatus) async {
    final docRef = _db
        .collection('users')
        .doc(userId)
        .collection('books')
        .doc(bookId);

    final docSnap = await docRef.get();
    if (!docSnap.exists) return;

    final data = docSnap.data()!;
    final int pageCount = data['pageCount'] ?? 200;

    Map<String, dynamic> updateData = {
      'status': newStatus,
      'updatedAt': DateTime.now().toIso8601String(),
    };

    // Se mudou para Lidos, marca as páginas lidas como total do livro
    if (newStatus == 'Lidos') {
      updateData['pagesRead'] = pageCount;
    }

    await docRef.update(updateData);

  }

  // Atualizar Detalhes do Livro (Total de Páginas)
  Future<void> updateBookDetails(
      String userId, String bookId, int newPageCount) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('books')
        .doc(bookId)
        .update({
      'pageCount': newPageCount,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  // Atualizar Páginas Lidas
  Future<void> updatePagesRead(
      String userId, String bookId, int pagesRead, int totalPages) async {
    final bool isCompleted = pagesRead >= totalPages && totalPages > 0;

    Map<String, dynamic> dataToUpdate = {
      'pagesRead': pagesRead,
      'updatedAt': DateTime.now().toIso8601String(),
    };

    if (isCompleted) {
      dataToUpdate['status'] = 'Lidos';
    }

    await _db
        .collection('users')
        .doc(userId)
        .collection('books')
        .doc(bookId)
        .update(dataToUpdate);

  }

  // Remover Livro da Estante do Usuário
  Future<void> deleteBook(String userId, String bookId) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('books')
        .doc(bookId)
        .delete();

  }

  // Streams de Leitura
  Stream<List<BookModel>> getUserBooksByStatus(
      String userId, String status) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('books')
        .where('status', isEqualTo: status)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BookModel.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  Stream<Map<String, dynamic>> getUserStats(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('stats')
        .doc('general')
        .snapshots()
        .map((doc) => doc.data() ?? {'livrosLidos': 0, 'paginasLidas': 0});
  }
}