class BookModel {
  final String id;
  final String title;
  final List<String> authors;
  final String? description;
  final int pageCount;
  final int pagesRead; // Campo novo para progresso
  final String? thumbnailUrl;
  final String status; // 'Quero Ler', 'Lendo', 'Lidos'
  final String? previewLink; // Link para leitura/prévia

// Construtor
  BookModel({
    required this.id,
    required this.title,
    required this.authors,
    this.description,
    required this.pageCount,
    this.pagesRead = 0,
    this.thumbnailUrl,
    this.status = 'Quero Ler',
    this.previewLink,
  });

  factory BookModel.fromApiJson(Map<String, dynamic> json) {
    final volumeInfo = json['volumeInfo'] ?? {};
    final imageLinks = volumeInfo['imageLinks'] ?? {};

    return BookModel(
      id: json['id'] ?? '',
      title: volumeInfo['title'] ?? 'Título desconhecido',
      authors: (volumeInfo['authors'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          ['Autor desconhecido'],
      description: volumeInfo['description'],
      pageCount: volumeInfo['pageCount'] ?? 0,
      pagesRead: 0,
      thumbnailUrl: imageLinks['thumbnail']?.replaceAll('http://', 'https://'),
      previewLink: volumeInfo['previewLink'] ?? volumeInfo['infoLink'],
    );
  }

  factory BookModel.fromFirestore(Map<String, dynamic> json, String docId) {
    return BookModel(
      id: docId,
      title: json['title'] ?? '',
      authors: List<String>.from(json['authors'] ?? []),
      description: json['description'],
      pageCount: json['pageCount'] ?? 0,
      pagesRead: json['pagesRead'] ?? 0,
      thumbnailUrl: json['thumbnailUrl'],
      status: json['status'] ?? 'Quero Ler',
      previewLink: json['previewLink'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'authors': authors,
      'description': description,
      'pageCount': pageCount,
      'pagesRead': pagesRead,
      'thumbnailUrl': thumbnailUrl,
      'status': status,
      'previewLink': previewLink,
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }
}