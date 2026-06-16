import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/contact_controller.dart';
import 'contact_form_view.dart';
import 'contact_list_view.dart';

class HomeScreen extends StatefulWidget { //tela inicial do app
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> { 
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ContactController>().fetchContacts();
    });
  }

  @override
  Widget build(BuildContext context) { //interface da tela inicial com widgets
    final controller = context.watch<ContactController>();
    final isDark = controller.isDarkMode;

    // Cores dinâmicas para suporte ao modo escuro
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final mainText = isDark ? Colors.white : const Color(0xFF1E293B);
    final subText = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Scaffold( //tela principal (usei a IA para estilizar melhor e otimizar o tempo)
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header com gradiente e botão de Modo Claro/Escuro
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 60, left: 24, right: 16, bottom: 40),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF3B82F6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.phone_android_rounded, color: Colors.white, size: 28), // Ícone alterado para telefone
                      ),
                      const SizedBox(width: 16),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Call Tel',
                            style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Seus contatos, organizados com o Call Tel',
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Botão de alternância de Tema
                  IconButton(
                    icon: Icon(
                      isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: () => controller.toggleTheme(),
                  ),
                ],
              ),
            ),

            // Card Resumo
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.04), blurRadius: 16, offset: const Offset(0, 8))
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('RESUMO', style: TextStyle(color: Color(0xFFA5B4FC), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                    const SizedBox(height: 12),
                    Row(
                      textBaseline: TextBaseline.alphabetic,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      children: [
                        Text(
                          '${controller.contacts.length}',
                          style: const TextStyle(color: Color(0xFF7C3AED), fontSize: 48, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        Text('contatos salvos', style: TextStyle(color: subText, fontSize: 16, fontWeight: FontWeight.w500)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: const LinearProgressIndicator(
                        value: 1.0,
                        backgroundColor: Color(0xFFEEF2FF),
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
                        minHeight: 6,
                      ),
                    )
                  ],
                ),
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Text('O QUE DESEJA FAZER?', style: TextStyle(color: Color(0xFFA5B4FC), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            ),

            // Botão Adicionar Contato (Roxo)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: InkWell(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ContactFormScreen())),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C3AED),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(16)),
                        child: const Icon(Icons.add, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 16),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Adicionar Contato', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          SizedBox(height: 2),
                          Text('Cadastre um novo contato', style: TextStyle(color: Colors.white70, fontSize: 13)),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),

            // Botão Ver Contatos
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: InkWell(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ContactListScreen())),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.03), blurRadius: 12, offset: const Offset(0, 4))
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(16)),
                        child: const Icon(Icons.list_rounded, color: Color(0xFF2563EB), size: 28),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Ver Contatos', style: TextStyle(color: mainText, fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 2),
                          Text('Lista completa em ordem A-Z', style: TextStyle(color: subText, fontSize: 13)),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),

            // Recentes
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Text('RECENTES', style: TextStyle(color: Color(0xFFA5B4FC), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: controller.recentContacts.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('Nenhum contato recente.', style: TextStyle(color: Colors.grey)),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: controller.recentContacts.length,
                        separatorBuilder: (_, __) => Divider(height: 24, color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9)),
                        itemBuilder: (context, index) {
                          final item = controller.recentContacts[index];
                          String initials = item.name.trim().split(' ').map((e) => e[0]).take(2).join().toUpperCase();
                          return Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: const Color(0xFF7C3AED),
                                child: Text(initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.name, style: TextStyle(color: mainText, fontSize: 16, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Text(item.phone, style: TextStyle(color: subText, fontSize: 14)),
                                ],
                              )
                            ],
                          );
                        },
                      ),
              ),
            ),
            const SizedBox(height: 40)
          ],
        ),
      ),
    );
  }
}