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

    // Recalcula estatísticas após adicionar
    await recalculateStats(userId);
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

    // Se mudou para Lidos, marca as páginas lidas como total do livro e define a data padrão do mês atual
    if (newStatus == 'Lidos') {
      updateData['pagesRead'] = pageCount;
      final agora = DateTime.now();
      updateData['finishedDate'] = "${agora.year}-${agora.month.toString().padLeft(2, '0')}-01";
    }

    await docRef.update(updateData);

    // Recalcula estatísticas após mover
    await recalculateStats(userId);
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

    await recalculateStats(userId);
  }

  // Atualizar Páginas Lidas (Com registro do mês/ano atual para estatísticas dinâmicas)
  Future<void> updatePagesRead(
      String userId, String bookId, int pagesRead, int totalPages) async {
    final bool isCompleted = pagesRead >= totalPages && totalPages > 0;
    
    final agora = DateTime.now();
    final anoMesAtual = "${agora.year}-${agora.month.toString().padLeft(2, '0')}-01";

    Map<String, dynamic> dataToUpdate = {
      'pagesRead': pagesRead,
      'lastReadMonth': anoMesAtual,
      'updatedAt': DateTime.now().toIso8601String(),
    };

    if (isCompleted) {
      dataToUpdate['status'] = 'Lidos';
      dataToUpdate['finishedDate'] = anoMesAtual;
    }

    await _db
        .collection('users')
        .doc(userId)
        .collection('books')
        .doc(bookId)
        .update(dataToUpdate);

    // Recalcula estatísticas após ler páginas
    await recalculateStats(userId);
  }

  // Atualizar Data de Término Específica (Ano e Mês escolhidos pelo usuário)
  Future<void> updateBookFinishedDate(
      String userId, String bookId, String finishedDate) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('books')
        .doc(bookId)
        .update({
      'finishedDate': finishedDate,
      'status': 'Lidos',
      'updatedAt': DateTime.now().toIso8601String(),
    });

    await recalculateStats(userId);
  }

  // Remover Livro da Estante do Usuário
  Future<void> deleteBook(String userId, String bookId) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('books')
        .doc(bookId)
        .delete();

    // Recalcula as estatísticas após remover o livro
    await recalculateStats(userId);
  }

  // Recalcular Estatísticas Gerais do Usuário no Firestore
  Future<void> recalculateStats(String userId) async {
    final booksQuery = await _db
        .collection('users')
        .doc(userId)
        .collection('books')
        .get();

    int totalLivrosLidos = 0;
    int totalPaginasLidas = 0;

    for (var doc in booksQuery.docs) {
      final data = doc.data();
      final status = data['status'] ?? '';
      final pagesRead = (data['pagesRead'] as num?)?.toInt() ?? 0;

      totalPaginasLidas += pagesRead;
      if (status == 'Lidos') {
        totalLivrosLidos++;
      }
    }

    await _db
        .collection('users')
        .doc(userId)
        .collection('stats')
        .doc('general')
        .set({
      'livrosLidos': totalLivrosLidos,
      'paginasLidas': totalPaginasLidas,
      'updatedAt': DateTime.now().toIso8601String(),
    }, SetOptions(merge: true));
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