import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/contact_controller.dart';
import '../models/contact_model.dart';
import 'contact_form_view.dart';
import 'contact_detail_view.dart';

class ContactListScreen extends StatefulWidget { //tela para exibir a lista de contatos
  const ContactListScreen({super.key});

  @override
  State<ContactListScreen> createState() => _ContactListScreenState();
}

class _ContactListScreenState extends State<ContactListScreen> { 
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) { //interface da tela de lista de contatos
    final controller = context.watch<ContactController>();
    final isDark = controller.isDarkMode;

    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final mainText = isDark ? Colors.white : const Color(0xFF1E293B);
    final subText = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    
    final filteredContacts = controller.contacts.where((c) {
      return c.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    Map<String, List<Contact>> grouped = {}; // Agrupamento dos contatos por letra inicial do nome
    for (var contact in filteredContacts) {
      String firstLetter = contact.name.trim().substring(0, 1).toUpperCase();
      if (!RegExp(r'[A-Z]').hasMatch(firstLetter)) firstLetter = '#';
      if (!grouped.containsKey(firstLetter)) grouped[firstLetter] = [];
      grouped[firstLetter]!.add(contact);
    }

    final sortedKeys = grouped.keys.toList()..sort(); // Ordenação das chaves para exibição em ordem alfabética

    return Scaffold( //tela principal (usei a IA para estilizar melhor e otimizar o tempo)
      body: Column(
        children: [
          // Header com campo de busca
          Container(
            padding: const EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF3B82F6)]),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Contatos', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                            Text('${controller.contacts.length} contatos', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                          ],
                        )
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: Colors.white, size: 32),
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ContactFormScreen())),
                    )
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                  child: TextField(
                    onChanged: (val) => setState(() => _searchQuery = val),
                    style: const TextStyle(color: Colors.black87),
                    decoration: const InputDecoration(
                      hintText: 'Buscar contato...',
                      hintStyle: TextStyle(color: Color(0xFF94A3B8)),
                      prefixIcon: Icon(Icons.search, color: Color(0xFF3B82F6)),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                )
              ],
            ),
          ),

          // Lista de Registros Expandida com dados adicionais
          Expanded(
            child: controller.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredContacts.isEmpty
                    ? const Center(child: Text('Nenhum contato encontrado.'))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        itemCount: sortedKeys.length,
                        itemBuilder: (context, sectionIndex) {
                          final key = sortedKeys[sectionIndex];
                          final sectionContacts = grouped[key]!;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 8, top: 12, bottom: 8),
                                child: Text(key, style: const TextStyle(color: Color(0xFF7C3AED), fontSize: 16, fontWeight: FontWeight.bold)),
                              ),
                              ...sectionContacts.map((contact) {
                                String initials = contact.name.trim().split(' ').map((e) => e[0]).take(2).join().toUpperCase();
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: InkWell(
                                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ContactDetailScreen(contact: contact))),
                                    child: Container(
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(20)),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          CircleAvatar(
                                            radius: 24,
                                            backgroundColor: const Color(0xFF7C3AED),
                                            child: Text(initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                          ),
                                          const SizedBox(width: 14),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(contact.name, style: TextStyle(color: mainText, fontSize: 16, fontWeight: FontWeight.bold)),
                                                const SizedBox(height: 6),
                                                
                                                // Exibição de Telefone, E-mail e Endereço na própria lista
                                                Row(
                                                  children: [
                                                    const Icon(Icons.phone_outlined, size: 14, color: Color(0xFF3B82F6)),
                                                    const SizedBox(width: 6),
                                                    Text(contact.phone, style: TextStyle(color: subText, fontSize: 13)),
                                                  ],
                                                ),
                                                const SizedBox(height: 3),
                                                Row(
                                                  children: [
                                                    const Icon(Icons.mail_outline_rounded, size: 14, color: Color(0xFF3B82F6)),
                                                    const SizedBox(width: 6),
                                                    Expanded(child: Text(contact.email, style: TextStyle(color: subText, fontSize: 13), overflow: TextOverflow.ellipsis)),
                                                  ],
                                                ),
                                                const SizedBox(height: 3),
                                                Row(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    const Padding(
                                                      padding: EdgeInsets.only(top: 2),
                                                      child: Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF3B82F6)),
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Expanded(child: Text(contact.address, style: TextStyle(color: subText, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis)),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Column(
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(color: const Color(0xFFF3E8FF), borderRadius: BorderRadius.circular(8)),
                                                child: IconButton(
                                                  icon: const Icon(Icons.edit_outlined, color: Color(0xFF7C3AED)),
                                                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ContactFormScreen(contactToEdit: contact))),
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Container(
                                                decoration: BoxDecoration(color: const Color(0xFFFFE4E6), borderRadius: BorderRadius.circular(8)),
                                                child: IconButton(
                                                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                                                  onPressed: () => _confirmDelete(context, contact),
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ],
                          );
                        },
                      ),
          )
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, Contact contact) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir Contato'),
        content: Text('Tem certeza que deseja remover ${contact.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<ContactController>().removeContact(contact.id!);
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}