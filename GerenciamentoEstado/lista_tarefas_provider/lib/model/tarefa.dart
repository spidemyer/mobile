//Modelagem dos Dados

class Tarefa {
  //atributos
  String titulo; //armazena o titulo da tarefa
  bool concluida; //status da Tarefa
  //classe que armazena informações de data
  DateTime dataCriacao;

  //construtor padrão
  // Tarefa(String titulo){
  //   this.titulo = titulo;
  //   this.concluida = false;
  //   this.criacao = DateTime.now();
  // }

  //construtor resumido
  Tarefa({
    required this.titulo,
    this.concluida = false,
    DateTime? dataCriacao,}) : dataCriacao = dataCriacao ?? DateTime.now();
    //se Data de Criação for Nulo, atribui uma data DateTime.now() -> pega a data atual

// classe de modelagem de dados, toda tarefa criada é um obj da classe Tarefa
// toda tarefa tem um tiulo, um status de conclusão e uma data de criação

}