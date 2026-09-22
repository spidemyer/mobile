import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'novo_registro_screen.dart';
import 'lista_registros_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Definindo a paleta de cores (Roxo Claro)
    const Color primaryPurple = Color(0xFF9C27B0);
    const Color lightPurple = Color(0xFFE1BEE7);
    const Color backgroundLight = Color(0xFFF3E5F5);
    const Color darkPurpleText = Color(0xFF4A148C);
    
// Tela Inicial do App, usei a IA para auxiliar e agilizar o processo de estilização das telas, para manter um padrão.
    return Scaffold(
      backgroundColor: backgroundLight,
      appBar: AppBar(
        title: Text(
          'SENAI Check-in',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: primaryPurple,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cabeçalho de Boas-vindas
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: lightPurple.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
                // ignore: deprecated_member_use
                border: Border.all(color: primaryPurple.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bem-vindo(a)! 👋',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: darkPurpleText,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Gerencie seus check-ins e visualize seus registros salvos de forma rápida e prática.',
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Título da Seção de Ações
            Text(
              'Ações Rápidas',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: darkPurpleText,
              ),
            ),
            const SizedBox(height: 16),

            // Botão / Card: Novo Registro
            _buildMenuCard(
              context,
              icon: Icons.add_location_alt_rounded,
              title: 'Novo Check-in',
              subtitle: 'Cadastrar nova localização ou atividade',
              primaryColor: primaryPurple,
              onTap: () {
                // Navegar para a tela de Novo Registro:
                Navigator.push(context, MaterialPageRoute(builder: (context) => const NovoRegistroScreen()));
              },
            ),
            const SizedBox(height: 16),

            // Botão / Card: Histórico / Registros Cadastrados
            _buildMenuCard(
              context,
              icon: Icons.list_alt_rounded,
              title: 'Ver Registros',
              subtitle: 'Consultar histórico de check-ins salvos',
              primaryColor: primaryPurple,
              onTap: () {
                // Navegar para a tela de listagem de registros:
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ListaRegistrosScreen()));
              },
            ),
          ],
        ),
      ),
    );
  }

  // Widget auxiliar para criar os cards de menu padronizados
  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color primaryColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E5F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: primaryColor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF4A148C),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.roboto(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}