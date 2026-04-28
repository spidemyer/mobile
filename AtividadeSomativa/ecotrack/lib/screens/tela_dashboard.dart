import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/eco_provider.dart';

class TelaDashboard extends StatelessWidget {
  const TelaDashboard({super.key});

    @override
    Widget build(BuildContext context) {
        final provider = Provider.of<EcoProvider>(context); //pega o provider para ascessar os habitos e calcular o impacto

        return Scaffold(
            appBar: AppBar(
                title: Text("Meu Impacto"),
            ),
            body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                        _buildCard("Pendentes", provider.totalPendentes.toString(), Colors.orange),
                        _buildCard("Concluídos", provider.totalConcluidos.toString(), Colors.green),
                        _buildCard("Eficiência", "${_calcularEficiencia(provider)}%", Colors.blue),
                        _buildCard("Nível Eco", _definirNivel(provider), Colors.purple),
                    ],
                ),
            ),
        );
    }

    Widget _buildCard(String titulo, String Valor, Color cor) {
        return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), //cria um card para mostrar as informações do dashboard
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                    Text(titulo, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    SizedBox(height: 10),
                    Text(Valor, style: TextStyle(fontSize: 24, color: cor, fontWeight: FontWeight.bold)),
                ],
            ),
        );
    }

    int _calcularEficiencia(EcoProvider p) {
        int total = p.totalPendentes + p.totalConcluidos;
        if (total == 0) return 0;
        return ((p.totalConcluidos / total) * 100).toInt();
    }

    String _definirNivel(EcoProvider p) {
        if (p.totalConcluidos >= 5) return "Eco Expert";
        if (p.totalConcluidos >= 3) return "Quase lá";
        return "Iniciante";
    }
}