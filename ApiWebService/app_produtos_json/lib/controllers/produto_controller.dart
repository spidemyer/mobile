import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/produto_model.dart';

class ProdutoController { // para gerenciar a lista de produtos e persistência
  List<ProdutoModel> produtos = [];

  Future<File> _getArquivo() async { // Obtém o arquivo json nos diretórios do dispositivo
    final diretorio = await getApplicationDocumentsDirectory(); 
    final caminho = '${diretorio.path}/produtos.json'; 
    return File(caminho); // retorna o arquivo json
  }

  // Lê os produtos do arquivo para atualizar a lista
  Future<List<ProdutoModel>> lerProdutos() async {
    try {
      final arquivo = await _getArquivo();
      if (!await arquivo.exists()) {
        return [];
      }
      String conteudo = await arquivo.readAsString();
      List<dynamic> dados = json.decode(conteudo);

      produtos = dados.map((item) => ProdutoModel.fromMap(item)).toList();
      return produtos;
    } catch (e) {
      produtos = [];
      return [];
    }
  }

  // Salva a lista de produtos no arquivo 
  Future<void> _salvarNoArquivo() async { 
    final arquivo = await _getArquivo();
    List<Map<String, dynamic>> listaMap =
        produtos.map((p) => p.toMap()).toList();
    String jsonString = json.encode(listaMap);
    await arquivo.writeAsString(jsonString);
  }

  // Adiciona um novo produto e persiste no arquivo
  Future<void> adicionarProduto(String nome, double valor) async {
    final novo = ProdutoModel(nome: nome, valor: valor);
    produtos.add(novo);
    await _salvarNoArquivo();
  }

  // Remove um produto pelo índice e atualiza o arquivo
  Future<void> removerProduto(int index) async {
    produtos.removeAt(index);
    await _salvarNoArquivo();
  }
}