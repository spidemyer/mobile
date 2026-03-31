//função principal ( faz o aplicativo rodar)
import 'package:flutter/material.dart';

void main(List<String> args) {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false, //remove a flag do debug
    home: ToDoList(),
  ));
}

//st -> snipets (atalhos para código)

//janela do aplicativvo
//1º Class identifica a mudança de estado => chama o build
class ToDoList extends StatefulWidget {
  const ToDoList({super.key});

  @override // chama o rebuild da Tela
  State<ToDoList> createState() => _ToDoListState();
}

//2º class => lógica da construção da janela
class _ToDoListState extends State<ToDoList> {
  //atributos
  //final => permite a mudança de valor uma única vez (escopo da variável)
  // _ o uso do underLine , transforma a variável em private
  final TextEditingController _tarefaController = TextEditingController();//pega o valor do input
  final List<Map<String,dynamic>> _tarefas = []; // Lista do Tipo Coleção (Chave, Valor)

  //métodos
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Lista de Tarefas"),centerTitle: true,),//centraliza o texto no meio da Appbar
      body: Padding(
        //espaçamento geral de 8px
        padding: EdgeInsets.all(8),
        child: Column(
          children: [
            //input para adicionar novas tarefas
            TextField(
              controller: _tarefaController,// passa o valor do texto para o controller
              decoration: InputDecoration(
                labelText: "Digite uma Tarefa"
              ),
            ),
            SizedBox(height: 10,), //espaçamento de altura
            ElevatedButton( // botão para adicioanr tarefa
              onPressed: _adicionarTarefa, 
              child: Text("Adicionar Tarefa")),
            //campo para listar as tarefas
            Expanded(
              //Listar as Tarefas da Coleção
              child: ListView.builder(
                itemCount: _tarefas.length, //conta o nº de item na lista
                itemBuilder: (context,index)=>
                  //exibe o elemento da Lista
                  ListTile(
                    title: Text(_tarefas[index]["titulo"], style: TextStyle(
                      //operador Ternário (if,else) => se tarefa concluida , coloca um risco no texto
                      decoration: _tarefas[index]["concluida"] ? TextDecoration.lineThrough : null
                    ),),
                    leading: Checkbox( //permite mudar o valor da tarefa para concluida ou o contrário
                      value: _tarefas[index]["concluida"], 
                      onChanged: (bool? valor)=> setState(() {
                        _tarefas[index]["concluida"] = valor!;
                      })),
                      //botão para excluir a tarefa da lista
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => setState(() {
                        _tarefas.removeAt(index);
                      }),
                    ),
                  ),
              ),
            )
          ],
        ),),
    );
  }
  //método para adicionar tarefa na lista
  void _adicionarTarefa() {
    if(_tarefaController.text.trim().isNotEmpty){
      setState(() {
        //adiciona a tarefa na lista
        _tarefas.add({"titulo":_tarefaController.text,"concluida":false});
        //limpa o campo do input
        _tarefaController.clear();
      });
    }
  }
}