
import 'package:biblioteca_json/model/book_model.dart';
import 'package:biblioteca_json/service/api_service.dart';

class BookController {
  Future<List<BookModel>> fetchAll() async {
    final list = await ApiService.getList(
      "books?_sort=title",
    ); //?_sort=title => flag para organizar em ordem alfabetica por título
    //retorna a Lista de Livros Convertidos para BookModel
    return list.map<BookModel>((item) => BookModel.fromMap(item)).toList();
  }

  Future<BookModel> create(BookModel b) async {
    final created = await ApiService.post("books", b.toMap());
    //adiciona um Livro e Retorna o LivroCriado => ID
    return BookModel.fromMap(created);

  }

  Future<BookModel> update(BookModel b) async {
    final updated = await ApiService.put("books", b.toMap(), b.id!);
    return BookModel.fromMap(updated);
  }

  Future<void> delete(String id) async {
    await ApiService.delete("books", id);
  }
}