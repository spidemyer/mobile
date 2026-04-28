import 'package:flutter/material.dart';
import '../models/habito.dart';
import '../providers/eco_provider.dart';
import 'package:provider/provider.dart';

class HabitosWidget extends StatelessWidget {
    final List<Habito> habitos;
    final bool isConcluidos;

    HabitosWidget({required this.habitos, required this.isConcluidos});

    @override
    Widget build(BuildContext context) {
        final provider = Provider.of<EcoProvider>(context); //pega o provider para acessar a função de concluir habito

        return ListView.builder( //cria um ListView para mostrar os habitos, com um botão para concluir os habitos pendentes
            itemCount: habitos.length,
            itemBuilder: (context, index) {
                final habito = habitos[index];
                return ListTile(
                    title: Text(habito.nome),
                    trailing: isConcluidos
                        ? null
                        : IconButton(
                            icon: Icon(Icons.check),
                            onPressed: () {
                                provider.concluirHabito(habito);
                            },
                        ),
                );
            },
        );
    }
}