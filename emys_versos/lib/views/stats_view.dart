import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../models/book_model.dart';

class StatsView extends StatefulWidget {
  const StatsView({super.key});

  @override
  State<StatsView> createState() => _StatsViewState();
}

class _StatsViewState extends State<StatsView> {
  final List<int> _anosDisponiveis = [2026, 2025, 2024];
  late int _anoSelecionado;
  
  final Map<int, String> _meses = {
    1: 'Janeiro', 2: 'Fevereiro', 3: 'Março', 4: 'Abril',
    5: 'Maio', 6: 'Junho', 7: 'Julho', 8: 'Agosto',
    9: 'Setembro', 10: 'Outubro', 11: 'Novembro', 12: 'Dezembro'
  };
  
  late int _mesSelecionado;

  @override
  void initState() {
    super.initState();
    _anoSelecionado = DateTime.now().year;
    _mesSelecionado = DateTime.now().month;
  }

  // Função auxiliar para calcular livros e páginas de um ano/mês específico
  Map<String, int> _calcularEstatisticasPara(List<QueryDocumentSnapshot> docs, int targetYear, int targetMonth) {
    int livros = 0;
    int paginas = 0;

    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final book = BookModel.fromFirestore(data, doc.id);
      
      final pagesRead = (data['pagesRead'] as num?)?.toInt() ?? 0;
      final finishedDate = data['finishedDate'] as String?;
      final lastReadMonth = data['lastReadMonth'] as String?;
      final updatedAt = data['updatedAt'] as String?;

      // Conta livros lidos (concluídos) no período alvo
      if (book.status == 'Lidos' && finishedDate != null) {
        final partes = finishedDate.split('-');
        if (partes.length >= 2) {
          if (int.tryParse(partes[0]) == targetYear && int.tryParse(partes[1]) == targetMonth) {
            livros++;
          }
        }
      }

      // Verifica se o livro teve progresso ou conclusão no período alvo
      bool pertenceAoPeriodo = false;

      if (finishedDate != null) {
        final partesF = finishedDate.split('-');
        if (partesF.length >= 2) {
          if (int.tryParse(partesF[0]) == targetYear && int.tryParse(partesF[1]) == targetMonth) {
            pertenceAoPeriodo = true;
          }
        }
      }

      if (!pertenceAoPeriodo && lastReadMonth != null) {
        final partesM = lastReadMonth.split('-');
        if (partesM.length >= 2) {
          if (int.tryParse(partesM[0]) == targetYear && int.tryParse(partesM[1]) == targetMonth) {
            pertenceAoPeriodo = true;
          }
        }
      }

      if (!pertenceAoPeriodo && updatedAt != null && updatedAt.isNotEmpty) {
        try {
          final updateDate = DateTime.parse(updatedAt);
          if (updateDate.year == targetYear && updateDate.month == targetMonth) {
            pertenceAoPeriodo = true;
          }
        } catch (_) {}
      }

      if (pertenceAoPeriodo) {
        paginas += pagesRead;
      }
    }

    return {'livros': livros, 'paginas': paginas};
  }

  @override
  Widget build(BuildContext context) {
    final userId = Provider.of<AuthService>(context).currentUser?.uid;

    if (userId == null) {
      return const Scaffold(body: Center(child: Text("Usuário não autenticado")));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF3E5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6A1B9A),
        title: const Text(
          'Minhas Estatísticas',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('books')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF6A1B9A)));
          }

          final docs = snapshot.data?.docs ?? [];

          // 1. Estatísticas do período selecionado em cima (Ano + Mês)
          final statsSelecionado = _calcularEstatisticasPara(docs, _anoSelecionado, _mesSelecionado);
          final int livrosPeriodo = statsSelecionado['livros']!;
          final int paginasPeriodo = statsSelecionado['paginas']!;

          // 2. Estatísticas do Mês Atual real (para a seção inferior)
          final agora = DateTime.now();
          final statsAtual = _calcularEstatisticasPara(docs, agora.year, agora.month);
          final int livrosMesAtual = statsAtual['livros']!;
          final int paginasMesAtual = statsAtual['paginas']!;

          final nomeMesAtual = _meses[agora.month] ?? 'Mês Atual';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // SELETOR DE ANO
                const Text('Selecionar Ano', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF4A148C))),
                const SizedBox(height: 8),
                SizedBox(
                  height: 45,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _anosDisponiveis.length,
                    itemBuilder: (context, index) {
                      final ano = _anosDisponiveis[index];
                      final isSelected = _anoSelecionado == ano;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(ano.toString()),
                          selected: isSelected,
                          selectedColor: const Color(0xFFCE93D8),
                          backgroundColor: Colors.white,
                          labelStyle: TextStyle(color: isSelected ? const Color(0xFF4A148C) : Colors.grey[700], fontWeight: FontWeight.bold),
                          onSelected: (bool selected) => setState(() => _anoSelecionado = ano),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // SELETOR DE MÊS
                const Text('Filtrar por Mês', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF4A148C))),
                const SizedBox(height: 8),
                SizedBox(
                  height: 45,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _meses.length,
                    itemBuilder: (context, index) {
                      final mesNum = index + 1;
                      final mesNome = _meses[mesNum]!;
                      final isSelected = _mesSelecionado == mesNum;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(mesNome),
                          selected: isSelected,
                          selectedColor: const Color(0xFF6A1B9A),
                          backgroundColor: Colors.white,
                          labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.grey[700], fontWeight: FontWeight.bold),
                          onSelected: (bool selected) => setState(() => _mesSelecionado = mesNum),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // Título do Período Selecionado
                Text(
                  'Desempenho em ${_meses[_mesSelecionado]} de $_anoSelecionado',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF4A148C)),
                ),
                const SizedBox(height: 12),

                // CARDS SUPERIORES LADO A LADO
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(title: 'Livros Lidos', value: livrosPeriodo.toString(), icon: Icons.menu_book),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(title: 'Páginas Lidas', value: paginasPeriodo.toString(), icon: Icons.auto_stories),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // SEÇÃO INFERIOR: LEITURAS DO MÊS ATUAL
                Text(
                  'Leituras em $nomeMesAtual',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4A148C)),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.purple.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text('Livros no Mês', style: TextStyle(fontSize: 14, color: Colors.grey)),
                          const SizedBox(height: 8),
                          Text(livrosMesAtual.toString(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF6A1B9A))),
                        ],
                      ),
                      Container(height: 40, width: 1, color: Colors.grey[300]),
                      Column(
                        children: [
                          const Text('Páginas no Mês', style: TextStyle(fontSize: 14, color: Colors.grey)),
                          const SizedBox(height: 8),
                          Text(paginasMesAtual.toString(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF6A1B9A))),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard({required String title, required String value, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.purple.withOpacity(0.08), blurRadius: 6, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFF3E5F5),
            child: Icon(icon, color: const Color(0xFF6A1B9A)),
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF4A148C))),
        ],
      ),
    );
  }
}