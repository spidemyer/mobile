import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'search_books_view.dart';
import 'shelves_view.dart';
import 'stats_view.dart';

class MainNavigationView extends StatefulWidget {
  const MainNavigationView({super.key});

  @override
  State<MainNavigationView> createState() => _MainNavigationViewState();
}

class _MainNavigationViewState extends State<MainNavigationView> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const SearchBooksView(),
    const _ShelvesTabView(),
    const StatsView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Emy's Versos",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () =>
                Provider.of<AuthService>(context, listen: false).signOut(),
          ),
        ],
      ),
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF6A1B9A),
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Buscar'),
          BottomNavigationBarItem(
            icon: Icon(Icons.collections_bookmark),
            label: 'Estantes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Estatísticas',
          ),
        ],
      ),
    );
  }
}

class _ShelvesTabView extends StatelessWidget {
  const _ShelvesTabView();

  @override
  Widget build(BuildContext context) {
    const statuses = ['Quero Ler', 'Lendo', 'Lidos'];

    return DefaultTabController(
      length: statuses.length,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'Quero Ler'),
              Tab(text: 'Lendo'),
              Tab(text: 'Lidos'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: statuses
                  .map((status) => ShelfList(status: status))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
