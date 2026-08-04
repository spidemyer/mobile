// Exemplo de Uso de Convert Json

//importar a biblioteca nativa
import 'dart:convert';

void main(List<String> args) {
  //string declarada em formaro de coleção json
  String dbJson = ''' {
    "id" : "1",
    "nome" : "Davi",
    "login" : "davi_user",
    "status" : true,
    "senha" : "1234",
    "endereco" : {"Rua" : "A", "numero" : "537"},
    "email" : ["davi@gmail.com", "martins@gmail.com"]
  } ''';

  //converter o texto Json => Map Dart usando Decode
  Map<String, dynamic> usuario = json.decode(dbJson);

  print(usuario["nome"]); //print da informação da chave nome
  print(usuario["login"]); //print da informação da chave login

  //mudar um valor
  usuario["senha"] = "1111";

  //converter o Map => texto Json usando Encode
  String dbJson2 = json.encode(usuario);

  print(dbJson2); //print 
}
