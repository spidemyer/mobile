import 'package:flutter/material.dart';
import '../models/habito.dart';

class EcoProvider extends ChangeNotifier { //criar provider para os habitos 
    List<Habito> habitosPendentes = [ //criar lista de habitos pendentes
    Habito("Separar lixo reciclável"),
    Habito("Economizar água no banho"),
    Habito("Usar garrafa reutilizável"),
    Habito("Desligar as luzes ao sair de um cômodo"),
    Habito("Usar transporte público ou bicicleta"),
    ];

    List<Habito> habitosConcluidos = []; //cria uma lista com os habitos concluidos

    int telaSelecionada = 0; //cria uma variavel para a tela selecionada

    void alterarTela(int index) { //cria uma variavel para alterar a tela
        telaSelecionada = index;
        notifyListeners();
    }

    void concluirHabito(Habito habito) { //função para concluir um habito e remover ele de pendentes
        habitosPendentes.remove(habito);
        habitosConcluidos.add(habito);
        notifyListeners();
    }

    int get totalConcluidos => habitosConcluidos.length; //váriavel para contar o total de habitos concluidos
    int get totalPendentes => habitosPendentes.length; //váriavel para contar o total de habitos pndentes
}