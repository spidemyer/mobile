//tela inicial
//vai conter um botão para acessar o formulário e outro para acessar a tela de contato

import 'package:flutter/material.dart';

//Tela inicial -> logo do APplicativo e navegação para as outras telas
// Logo com SplashScreen
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Meu Aplicativo Interativo"),),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //logo do aplicativo com atraso de carregamento
              Image.network("https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQv3mw51hQpgaiqmcKrJLKwYdDPtfUXOg69hA&s",
                width: 150, height: 150,),
                //bloco de espaçamento entre objetos
                SizedBox(height: 20,),
                //botões de navegação para as outras telas
                ElevatedButton(
                  onPressed: ()=> Navigator.pushNamed(context, "/form"),
                  child: Text("Formulário")),
                SizedBox(height: 10,),
                ElevatedButton(
                  onPressed: ()=> Navigator.pushNamed(context, "/contato"),
                  child: Text("Contato")),
            ],
        ),
      ),)
    );
  }
}
