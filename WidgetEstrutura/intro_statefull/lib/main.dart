// aplicativo usando StateFul ( com Mudança de Estado => ReBuild da Tela)

import 'package:flutter/material.dart';

void main(List<String> args) {
  runApp(MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  // método que identifica as mudanças de estado e chama a reconstrução da tela
  @override
  State<MyApp> createState() => _MyAppState();
  //arrow function
}

//classe criada para construir a janela, toda ação é escrita aqui
class _MyAppState extends State<MyApp> {
  //variável para identificar o nº de clicks no botão
  int contador = 0;

  //build da tela
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Aplicativo com StateFul - Contador")),
      //container Padding => espaçamento interno
      body: Padding(
        // espaçamento em todos os lados de 8px
        padding: EdgeInsets.all(8),
        //container Center => centraliza os elementos no meio da tela(Lateral- margens Direita e Esquerda)
        child: Center(
          // Column permite adicionar mais de um Elementos
          child: Column(
            // Centraliza os Elementos com relação ao Top e Botton
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Nº de Click: $contador", style: TextStyle(fontSize: 20)),
              //adicionar um botão => todo botão permite criar uma ação ao ser pressionado!!!
              ElevatedButton(
                onPressed: () {
                  // adicionar setState
                  setState(() {
                    contador++;
                  });
                }, // ação do botão (){} ou ()=>
                child: Text("Adicionar +1"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
