class BookModel {
  final String id;
  final String title;
  final List<String> authors;
  final String description;
  final int pageCount;
  final int pagesRead;
  final String status;
  final String? thumbnailUrl;
  final String? previewLink;
  final String? finishedDate; // Novo campo: formato "YYYY-MM-DD"

  BookModel({
    required this.id,
    required this.title,
    required this.authors,
    required this.description,
    required this.pageCount,
    required this.pagesRead,
    required this.status,
    this.thumbnailUrl,
    this.previewLink,
    this.finishedDate,
  });

  factory BookModel.fromFirestore(Map<String, dynamic> data, String id) {
    return BookModel(
      id: id,
      title: data['title'] ?? '',
      authors: List<String>.from(data['authors'] ?? ['Desconhecido']),
      description: data['description'] ?? '',
      pageCount: (data['pageCount'] as num?)?.toInt() ?? 200,
      pagesRead: (data['pagesRead'] as num?)?.toInt() ?? 0,
      status: data['status'] ?? 'Quero Ler',
      thumbnailUrl: data['thumbnailUrl'],
      previewLink: data['previewLink'],
      finishedDate: data['finishedDate'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'authors': authors,
      'description': description,
      'pageCount': pageCount,
      'pagesRead': pagesRead,
      'status': status,
      'thumbnailUrl': thumbnailUrl,
      'previewLink': previewLink,
      'finishedDate': finishedDate,
    };
  }

  static BookModel fromApiJson(Map<String, dynamic> item) {
    final volumeInfo = item['volumeInfo'] as Map<String, dynamic>? ?? {};
    final imageLinks = volumeInfo['imageLinks'] as Map<String, dynamic>? ?? {};
    final rawAuthors = volumeInfo['authors'] as List<dynamic>?;

    return BookModel(
      id: item['id'] as String? ?? '',
      title: volumeInfo['title'] as String? ?? 'Título desconhecido',
      authors:
          rawAuthors?.map((author) => author.toString()).toList() ??
          ['Autor desconhecido'],
      description: volumeInfo['description'] as String? ?? '',
      pageCount: (volumeInfo['pageCount'] as num?)?.toInt() ?? 0,
      pagesRead: 0,
      status: 'Quero Ler',
      thumbnailUrl: (imageLinks['thumbnail'] as String?)?.replaceFirst(
        'http://',
        'https://',
      ),
      previewLink:
          volumeInfo['previewLink'] as String? ??
          volumeInfo['infoLink'] as String?,
    );
  }
}
