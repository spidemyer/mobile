import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../database/database_helper.dart';
import '../models/checkin_model.dart';

class ListaRegistrosScreen extends StatefulWidget {
  const ListaRegistrosScreen({super.key});

  @override
  State<ListaRegistrosScreen> createState() => _ListaRegistrosScreenState();
}

// Tela de Histórico de Registros com opções de Edição e Exclusão
class _ListaRegistrosScreenState extends State<ListaRegistrosScreen> {
  List<CheckInModel> _registros = [];
  bool _isLoading = true;

  // Paleta de Cores em Roxo Claro
  final Color primaryPurple = const Color(0xFF9C27B0);
  final Color lightPurple = const Color(0xFFE1BEE7);
  final Color backgroundLight = const Color(0xFFF3E5F5);
  final Color darkPurpleText = const Color(0xFF4A148C);

  @override
  void initState() {
    super.initState();
    _carregarRegistros();
  }
  // Função para carregar os registros do banco de dados
  Future<void> _carregarRegistros() async {
    setState(() => _isLoading = true);
    try {
      final dados = await DatabaseHelper.instance.getRegistros();
      setState(() {
        _registros = dados;
      });
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar registros: $e', style: GoogleFonts.poppins()),
          backgroundColor: primaryPurple,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Função para deletar um registro com confirmação
  Future<void> _deletarRegistro(int id) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Excluir Registro', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: darkPurpleText)),
        content: Text('Deseja realmente excluir este registro?', style: GoogleFonts.roboto()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(context);
              await DatabaseHelper.instance.deleteRegistro(id);
              _carregarRegistros();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Registro excluído com sucesso!', style: GoogleFonts.poppins(color: Colors.white)),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: Text('Excluir', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }

  // Função para editar a observação de um registro existente
  Future<void> _editarRegistro(CheckInModel registro) async {
    final TextEditingController _editController = TextEditingController(text: registro.observacao);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Editar Observação', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: darkPurpleText)),
        content: TextField(
          controller: _editController,
          style: GoogleFonts.roboto(),
          decoration: InputDecoration(
            labelText: 'Nova Observação',
            labelStyle: GoogleFonts.poppins(color: primaryPurple),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: primaryPurple, width: 2),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryPurple, foregroundColor: Colors.white),
            onPressed: () async {
              if (_editController.text.isNotEmpty) {
                // Cria um objeto atualizado mantendo o ID e demais dados originais
                final registroAtualizado = CheckInModel(
                  id: registro.id,
                  dataHora: registro.dataHora,
                  latitude: registro.latitude,
                  longitude: registro.longitude,
                  observacao: _editController.text,
                  caminhoFoto: registro.caminhoFoto,
                );

                await DatabaseHelper.instance.updateRegistro(registroAtualizado);
                Navigator.pop(context);
                _carregarRegistros();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Registro atualizado com sucesso!', style: GoogleFonts.poppins(color: Colors.white)),
                    backgroundColor: primaryPurple,
                  ),
                );
              }
            },
            child: Text('Salvar', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      appBar: AppBar(
        title: Text(
          'Histórico de Registros',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: primaryPurple,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _registros.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.folder_open_rounded, size: 64, color: primaryPurple.withOpacity(0.5)),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhum registro encontrado.',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: darkPurpleText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _registros.length,
                  itemBuilder: (context, index) {
                    final registro = _registros[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: primaryPurple.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Miniatura da Foto
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: registro.caminhoFoto.isNotEmpty && File(registro.caminhoFoto).existsSync()
                                  ? Image.file(
                                      File(registro.caminhoFoto),
                                      width: 70,
                                      height: 70,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      width: 70,
                                      height: 70,
                                      color: lightPurple.withOpacity(0.5),
                                      child: Icon(Icons.image_not_supported, color: primaryPurple),
                                    ),
                            ),
                            const SizedBox(width: 16),
                            
                            // Informações do Check-in
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          registro.dataHora,
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: darkPurpleText,
                                          ),
                                        ),
                                      ),
                                      // Botões de Ação (Editar e Excluir)
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          InkWell(
                                            onTap: () => _editarRegistro(registro),
                                            child: Padding(
                                              padding: const EdgeInsets.all(4.0),
                                              child: Icon(Icons.edit, size: 20, color: primaryPurple),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          InkWell(
                                            onTap: () {
                                              if (registro.id != null) {
                                                _deletarRegistro(registro.id!);
                                              }
                                            },
                                            child: const Padding(
                                              padding: EdgeInsets.all(4.0),
                                              child: Icon(Icons.delete, size: 20, color: Colors.red),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Obs: ${registro.observacao}',
                                    style: GoogleFonts.roboto(
                                      fontSize: 13,
                                      color: Colors.grey[700],
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Lat: ${registro.latitude.toStringAsFixed(4)}, Lon: ${registro.longitude.toStringAsFixed(4)}',
                                    style: GoogleFonts.roboto(
                                      fontSize: 11,
                                      color: primaryPurple,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}