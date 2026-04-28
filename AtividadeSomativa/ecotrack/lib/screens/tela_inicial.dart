import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import 'tela_habitos.dart';
import 'tela_dashboard.dart';
import '../providers/theme_provider.dart';

class TelaInicial extends StatelessWidget { //tela inicial do app, com um botão para começar e um drawer para acessar as configurações de tema
  const TelaInicial({super.key});

  @override
  Widget build(BuildContext context) { //pega o provider de tema para alternar entre modo claro e escuro

    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("EcoTrack", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart_rounded),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => TelaDashboard())); //navega para a tela de dashboard ao clicar no ícone de gráfico
            },
          ),
        ],
      ),
      drawer: Drawer( //cria um drawer para acessar as configurações de tema
        child: Column(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.green),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.eco, size: 50, color: Colors.white),
                    SizedBox(height: 10),
                    Text("Configurações", style: TextStyle(color: Colors.white, fontSize: 20)),
                  ],
                ),
              ),
            ),
            // SWITCH PARA MODO ESCURO
            SwitchListTile(
              title: const Text("Modo Escuro"),
              subtitle: const Text("Alternar visual do app"),
              secondary: Icon(
                themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode, // muda o ícone dependendo do modo atual
                color: Colors.green,
              ),
              value: themeProvider.isDarkMode,
              onChanged: (value) {
                themeProvider.toggleTheme(value);
              },
            ),
          ],
        ),
      ),

      body: Padding( //conteúdo central da tela inicial, com um ícone, uma descrição e um botão para começar
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.eco_rounded, size: 100, color: Colors.green),
            const SizedBox(height: 30),
            const Text(
              "Acompanhe seus hábitos sustentáveis e veja seu impacto positivo no mundo!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity, //o botão ocupa toda a largura disponível
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => TelaHabitos()));
                },
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text("Começar", style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}