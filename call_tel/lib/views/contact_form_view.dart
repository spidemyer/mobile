import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/contact_controller.dart';
import '../models/contact_model.dart';

class ContactFormScreen extends StatefulWidget { //tela para criar ou editar um contato
  final Contact? contactToEdit;
  const ContactFormScreen({super.key, this.contactToEdit});

  @override
  State<ContactFormScreen> createState() => _ContactFormScreenState();
}

class _ContactFormScreenState extends State<ContactFormScreen> { //estado da tela de formulário de contato
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;

  @override
  void initState() { 
    super.initState();
    _nameController = TextEditingController(text: widget.contactToEdit?.name ?? '');
    _phoneController = TextEditingController(text: widget.contactToEdit?.phone ?? '');
    _emailController = TextEditingController(text: widget.contactToEdit?.email ?? '');
    _addressController = TextEditingController(text: widget.contactToEdit?.address ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _submit() async { //método para salvar o contato 
    if (!_formKey.currentState!.validate()) return;

    final contact = Contact(
      id: widget.contactToEdit?.id,
      name: _nameController.text,
      phone: _phoneController.text,
      email: _emailController.text,
      address: _addressController.text,
    );

    final success = await context.read<ContactController>().saveContact(contact); //chama o método de salvar contato do controller e aguarda o resultado

    if (mounted) { //verifica se o widget ainda está montado antes de mostrar a mensagem de sucesso ou erro
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.contactToEdit == null ? 'Contato salvo com sucesso!' : 'Contato atualizado!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ocorreu um erro ao salvar localmente.'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) { //constrói a interface do formulário de contato, adaptando as cores e estilos para o modo escuro ou claro
    final controller = context.watch<ContactController>();
    final isDark = controller.isDarkMode;
    final isEditing = widget.contactToEdit != null;

    // Definição da paleta dinâmica para o modo Dark/Light
    final scaffoldBg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF6F8FF);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final mainText = isDark ? Colors.white : const Color(0xFF1E293B);
    final labelColor = isDark ? const Color(0xFFA5B4FC) : const Color(0xFF4C1D95);
    final inputBg = isDark ? const Color(0xFF334155) : const Color(0xFFF8FAFC);
    final hintColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFFC7D2FE);

    return Scaffold( //tela do formulário de contato (usei a IA para estilizar melhor e otimizar o tempo)
      backgroundColor: scaffoldBg,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header com Gradiente
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 50, left: 16, bottom: 32),
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF3B82F6)]),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEditing ? 'Editar Contato' : 'Novo Contato', 
                          style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                        ),
                        const Text('Preencha os dados abaixo', style: TextStyle(color: Colors.white70, fontSize: 14)),
                      ],
                    ),
                  )
                ],
              ),
            ),

            // Form Card Espelhado dinamicamente
            Transform.translate(
              offset: const Offset(0, -20),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: CircleAvatar(
                            radius: 40,
                            backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFEFF6FF),
                            child: Icon(Icons.person, color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB), size: 40),
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        _buildLabel('Nome completo', labelColor),
                        _buildTextField(_nameController, 'Ex: Maria Santos', Icons.person_outline, inputBg, mainText, hintColor, (v) => v!.isEmpty ? 'Campo obrigatório' : null),
                        
                        _buildLabel('Telefone principal', labelColor),
                        _buildTextField(_phoneController, '(11) 99999-9999', Icons.phone_outlined, inputBg, mainText, hintColor, (v) => v!.isEmpty ? 'Campo obrigatório' : null, TextInputType.phone),
                        
                        _buildLabel('E-mail', labelColor),
                        _buildTextField(_emailController, 'email@exemplo.com', Icons.mail_outline, inputBg, mainText, hintColor, (v) => !v!.contains('@') ? 'Insira um e-mail válido' : null, TextInputType.emailAddress),
                        
                        _buildLabel('Endereço', labelColor),
                        _buildTextField(_addressController, 'Rua, número - Cidade, UF', Icons.location_on_outlined, inputBg, mainText, hintColor, (v) => v!.isEmpty ? 'Campo obrigatório' : null),
                        
                        const SizedBox(height: 32),
                        
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD946EF), // Lilás / Roxo claro constante do layout
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 0,
                            ),
                            child: const Text('Salvar Contato', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 15)),
    );
  }

  Widget _buildTextField(
    TextEditingController controller, 
    String hint, 
    IconData icon, 
    Color bg, 
    Color text, 
    Color hintColor,
    String? Function(String?)? validator, 
    [TextInputType type = TextInputType.text]
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        validator: validator,
        style: TextStyle(color: text),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: hintColor),
          prefixIcon: Icon(icon, color: const Color(0xFF93C5FD)),
          filled: true,
          fillColor: bg,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}