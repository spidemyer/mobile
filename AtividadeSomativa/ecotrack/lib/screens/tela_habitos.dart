import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/eco_provider.dart';
import '../widgets/habitos_widget.dart';

class TelaHabitos extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
        final provider = Provider.of<EcoProvider>(context); //pega o provider para acessar os habitos e a tela selecionada

        return DefaultTabController( //cria um DefaultTabController para as abas de pendentes e concluidos
            length: 2,
            child: Scaffold(
                appBar: AppBar(
                    title: Text("Hábitos Sustentáveis"),
                    bottom: TabBar(
                        tabs: [
                            Tab(text: "Pendentes"),
                            Tab(text: "Concluídos"),
                        ],
                    ),
                ),
                body: TabBarView(
                    children: [
                        HabitosWidget(habitos: provider.habitosPendentes, isConcluidos: false), // mostra os habitos pendentes 
                        HabitosWidget(habitos: provider.habitosConcluidos, isConcluidos: true), //mostra os habitos concluidos
                    ],
                ),
            ),
        );
    }
}