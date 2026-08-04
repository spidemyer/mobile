import 'package:flutter/material.dart';
import '../controllers/produto_controller.dart';

class ProdutoListPage extends StatefulWidget {
  const ProdutoListPage({Key? key}) : super(key: key);

  @override
  _ProdutoListPageState createState() => _ProdutoListPageState();
}
// Página de Lista de Produtos
class _ProdutoListPageState extends State<ProdutoListPage> {
  final ProdutoController _controller = ProdutoController();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _valorController = TextEditingController();
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    await _controller.lerProdutos();
    setState(() {
      _carregando = false;
    });
  }

  void _salvarProduto() async {
    String nome = _nomeController.text.trim();
    String valorText = _valorController.text.trim();

    // Validação de campos
    if (nome.isEmpty || valorText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Preencha todos os campos!")),
      );
      return;
    }
    // Validação de valor numérico
    double? valor = double.tryParse(valorText.replaceAll(',', '.'));
    if (valor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Digite um valor numérico válido!")),
      );
      return;
    }

    await _controller.adicionarProduto(nome, valor);
    // Limpa os campos após salvar
    _nomeController.clear();
    _valorController.clear();
    FocusScope.of(context).unfocus();

    setState(() {});
  }

  void _removerProduto(int index) async {
    await _controller.removerProduto(index);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lista de Produtos"),
      ),
      body: _carregando
          ? const Center(
              child: CircularProgressIndicator(color: Colors.deepPurple),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Card de Cadastro
                  Card(
                    elevation: 4,
                    shadowColor: Colors.deepPurple.withOpacity(0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          TextField(
                            controller: _nomeController,
                            decoration: const InputDecoration(
                              labelText: "Nome do Produto",
                              prefixIcon: Icon(Icons.shopping_bag, color: Colors.deepPurple),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.deepPurple, width: 2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _valorController,
                            decoration: const InputDecoration(
                              labelText: "Valor (ex: 49.90)",
                              prefixIcon: Icon(Icons.attach_money, color: Colors.deepPurple),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.deepPurple, width: 2),
                              ),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: _salvarProduto,
                              child: const Text(
                                "Salvar Produto",
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Produtos Cadastrados:",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Lista de Itens
                  Expanded(
                    child: _controller.produtos.isEmpty
                        ? const Center(
                            child: Text(
                              "Nenhum produto cadastrado ainda.",
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _controller.produtos.length,
                            itemBuilder: (context, index) {
                              final prod = _controller.produtos[index];
                              return Card(
                                elevation: 2,
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.purple.shade50,
                                    child: const Icon(
                                      Icons.label,
                                      color: Colors.deepPurple,
                                    ),
                                  ),
                                  title: Text(
                                    prod.nome,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    "R\$ ${prod.valor.toStringAsFixed(2)}",
                                    style: TextStyle(
                                      color: Colors.deepPurple.shade700,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.redAccent,
                                    ),
                                    onPressed: () => _removerProduto(index),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}