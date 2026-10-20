import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveBook(String userId, BookModel book) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('books')
        .doc(book.id)
        .set(book.toFirestore(), SetOptions(merge: true));
  }

  Future<void> updateBookStatus(
      String userId, String bookId, String newStatus) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('books')
        .doc(bookId)
        .update({
      'status': newStatus,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  // NOVO: Atualizar o número de páginas lidas
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