import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/contact_controller.dart';
import '../models/contact_model.dart';

class ContactDetailScreen extends StatefulWidget { //cria a tela de detalhes do contato, onde é possível 
//visualizar as informações do contato e os campos adicionais relacionados
  final Contact contact; 
  const ContactDetailScreen({super.key, required this.contact});

  @override
  State<ContactDetailScreen> createState() => _ContactDetailScreenState();
}

class _ContactDetailScreenState extends State<ContactDetailScreen> { //cria o estado da tela de detalhes do contato
  final _fieldValueController = TextEditingController();
  String _selectedType = 'Telefone';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ContactController>().fetchFieldsForContact(widget.contact.id!);
    });
  }

  void _addField() async { //método para adicionar um campo adicional para o contato
    if (_fieldValueController.text.trim().isEmpty) return;

    final success = await context.read<ContactController>().addAdditionalField(
          widget.contact.id!,
          _selectedType,
          _fieldValueController.text,
        );

    if (success) {
      _fieldValueController.clear();
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) { //interface da tela de detalhes do contato
    final controller = context.watch<ContactController>();

    return Scaffold( //estrutura básica da tela (usei a IA para otimizar meu tempo nessa parte)
      backgroundColor: const Color(0xFFF6F8FF),
      appBar: AppBar(
        title: const Text('Informações', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF3B82F6)]),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card de Informações Base
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 36,
                    backgroundColor: Color(0xFFEEF2FF),
                    child: Icon(Icons.person, size: 36, color: Color(0xFF6366F1)),
                  ),
                  const SizedBox(height: 16),
                  Text(widget.contact.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                  const SizedBox(height: 20),
                  _buildDetailRow(Icons.phone, 'Principal', widget.contact.phone),
                  _buildDetailRow(Icons.email, 'E-mail', widget.contact.email),
                  _buildDetailRow(Icons.location_on, 'Endereço', widget.contact.address),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('CAMPOS ADICIONAIS', style: TextStyle(color: Color(0xFFA5B4FC), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                ElevatedButton.icon(
                  onPressed: () => _showAddFieldModal(context),
                  icon: const Icon(Icons.add, size: 16, color: Colors.white),
                  label: const Text('Adicionar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7C3AED), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), visualDensity: VisualDensity.compact),
                )
              ],
            ),
            const SizedBox(height: 12),

            // Lista de Campos Extras Relacionados
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
              child: controller.currentFields.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: Text('Nenhum campo adicional cadastrado.', style: TextStyle(color: Colors.grey))),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.currentFields.length,
                      separatorBuilder: (_, __) => const Divider(color: Color(0xFFF1F5F9)),
                      itemBuilder: (context, index) {
                        final field = controller.currentFields[index];
                        IconData icon = Icons.label_important_outline;
                        if (field.fieldType == 'Telefone') icon = Icons.phone_android;
                        if (field.fieldType == 'Aniversário') icon = Icons.cake_outlined;
                        if (field.fieldType == 'Observações') icon = Icons.chat_bubble_outline;

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              Icon(icon, color: const Color(0xFF6366F1)),
                              const SizedBox(width: 14),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(field.fieldType, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                                  Text(field.fieldValue, style: const TextStyle(color: Color(0xFF1E293B), fontSize: 16, fontWeight: FontWeight.w500)),
                                ],
                              )
                            ],
                          ),
                        );
                      },
                    ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF94A3B8), size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
                Text(value, style: const TextStyle(fontSize: 15, color: Color(0xFF334155), fontWeight: FontWeight.w500)),
              ],
            ),
          )
        ],
      ),
    );
  }

  void _showAddFieldModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Adicionar Elemento Relacionado', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedType,
                    items: ['Telefone', 'Aniversário', 'Observações']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => setModalState(() => _selectedType = v!),
                    decoration: InputDecoration(filled: true, fillColor: const Color(0xFFF8FAFC), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _fieldValueController,
                    decoration: InputDecoration(hintText: 'Digite o valor do campo...', filled: true, fillColor: const Color(0xFFF8FAFC), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _addField,
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7C3AED), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: const Text('Adicionar Elemento', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }
}