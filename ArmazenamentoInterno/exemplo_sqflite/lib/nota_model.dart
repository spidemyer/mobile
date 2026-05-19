//modelagem de dados

class Nota {
  //atributos
  final int? id; //permitir que a variavel seja nula
  // em um primeiro momento a váriavel é nula
  // somente quando cair no DB ira receber um valor para o ID
  final String titulo;
  final String conteudo;

  //construtor
  Nota({this.id, required this.titulo, required this.conteudo});

  // métodos de serialização de dados (toMap() fromMap())

  //toMap() => converter um obj da Classe Nota para MAP de DB (inserir dados no db)
  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "titulo": titulo,
      "conteudo": conteudo,
    }; //mapeando as colunas do DB com os atributos da classe
  }

  //converter um MAP para obj da classe Nota
  //para fazer o from vamos usar um factory
  factory Nota.fromMap(Map<String, dynamic> map) {
    return Nota(
      id: map["id"] as int, //se esta voltando do db então já possui um id
      titulo: map["titulo"] as String,
      conteudo: map["conteudo"] as String,
    );
  }

  //metodo para imprimir dados
  @override
  String toString() {
    // TODO: implement toString
    return "Nota{id: $id, titulo: $titulo, conteudo: $conteudo}";
  }
}
