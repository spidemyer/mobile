//pagina de contato
//campo para nome, email, telefone e mensagem
//botão para enviar

import 'package:flutter/material.dart';

class ContatoPage extends StatefulWidget {
  const ContatoPage({super.key});

  @override
  State<ContatoPage> createState() => _ContatoPageState();
}

class _ContatoPageState extends State<ContatoPage> {
  //atributos
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _mensagemController = TextEditingController();

  //métodos
  //build da tela
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Contato"), centerTitle: true),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          children: [
            // não usaremos form
            TextField(
              controller: _nomeController,
              decoration: InputDecoration(labelText: "Nome"),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: "Email"),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _telefoneController,
              //mascara de telefone (XX) XXXXX-XXXX
              decoration: InputDecoration(
                labelText: "Telefone",
                hintText: "(XX) XXXXX-XXXX",
              ),
            ),
            SizedBox(height: 20),
            //campo para mensagem com multiplas linhas
            TextField(
              controller: _mensagemController,
              decoration: InputDecoration(labelText: "Mensagem"),
              maxLines: 5, //Limita o Campo a 5 Linhas
            ),
            SizedBox(height: 20),
            //enviar mensagem
            ElevatedButton(
              onPressed: () => _enviarMenssagem(),
              child: Text("Enviar Mensagem"),
            ),
          ],
        ),
      ),
    );
  }

  void _enviarMenssagem() {
    //exibir um dialogo de confirmação
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirmação de envio"),
        content: ListBody(children: [
          Text("Deseja enviar a seguinte mensagem?"),
          SizedBox(height: 20,),
          Text("Nome: ${_nomeController.text}"),
          Text("Email: ${_emailController.text}"),
          Text("Telefone: ${_telefoneController.text}"),
          Text("Mensagem: ${_mensagemController.text}"),
        ],),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              _nomeController.clear();
              _emailController.clear();
              _telefoneController.clear();
              _mensagemController.clear();
              Navigator.pop(context);
            },
            child: Text("Enviar"),
          ),
        ],
      ),
    );
  }
}
