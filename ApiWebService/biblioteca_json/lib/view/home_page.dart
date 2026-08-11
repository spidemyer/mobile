import 'package:biblioteca_json/view/book_list_page.dart';
import 'package:biblioteca_json/view/loan_list_page.dart';
import 'package:biblioteca_json/view/user_list_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0; //indice de navegação entre páginas

  //lista de págians
  final List<Widget> _pages = [
    const BookListPage(),
    const LoanListPage(),
    const UserListPage()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Gerenciamento de Biblioteca"),),
      // no corpo da págian vai aparecer o elemento de navegação 
      body: _pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (value) => setState(()=>_index=value),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: "Livros"),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: "Empréstimos"),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Usuários"),
        ]),
    );

  }
}
