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
  // Tela de Histórico de Registros, usei a IA para auxiliar e agilizar o processo de estilização das telas, para manter um padrão.
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

  Future<void> _carregarRegistros() async {
    setState(() => _isLoading = true);
    try {
      final dados = await DatabaseHelper.instance.getRegistros();
      setState(() {
        _registros = dados;
      });
    } catch (e) {
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
                                  Text(
                                    registro.dataHora,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: darkPurpleText,
                                    ),
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