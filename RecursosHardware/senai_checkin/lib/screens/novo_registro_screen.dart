import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_fonts/google_fonts.dart'; // Fonte estilizada
import '../database/database_helper.dart';
import '../models/checkin_model.dart';

// Tela de novo registro, onde as APIs estão sendo utilizadas
class NovoRegistroScreen extends StatefulWidget {
  const NovoRegistroScreen({super.key});

  @override
  State<NovoRegistroScreen> createState() => _NovoRegistroScreenState();
}

class _NovoRegistroScreenState extends State<NovoRegistroScreen> {
  final TextEditingController _obsController = TextEditingController();
  File? _imageFile;
  Position? _currentPosition;
  bool _isLoading = false;

  // Paleta de Cores em Roxo Claro
  final Color primaryPurple = const Color(0xFF9C27B0);
  final Color lightPurple = const Color(0xFFE1BEE7);
  final Color backgroundLight = const Color(0xFFF3E5F5);
  final Color darkPurpleText = const Color(0xFF4A148C);

  Future<bool> _verificarPermissoes() async {
    var cameraStatus = await Permission.camera.request();
    var locationStatus = await Permission.location.request();

    if (cameraStatus.isGranted && locationStatus.isGranted) {
      return true;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Permissões de Câmera e Localização são obrigatórias!',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: primaryPurple,
        ),
      );
      return false;
    }
  }

  Future<void> _obterLocalizacao() async {
    bool serviceEnabled;
    LocationPermission permission;
    
    // Verifica se o serviço de localização está habilitado
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'O serviço de GPS está desativado.',
            style: GoogleFonts.poppins(),
          ),
        ),
      );
      return;
    }

    // Verifica as permissões de localização
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    // Obtém a posição atual do dispositivo
    setState(() => _isLoading = true);
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao obter GPS: $e', style: GoogleFonts.poppins()),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Função para capturar a foto usando a câmera
  Future<void> _tirarFoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    // Se o usuário capturou uma foto, atualiza o estado com o arquivo da imagem
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  // Função para salvar o registro no banco de dados
  Future<void> _salvarRegistro() async {
    if (_imageFile == null || _currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Capture a foto e aguarde o GPS antes de salvar!',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: primaryPurple,
        ),
      );
      return;
    }

    // Cria um novo registro de check-in com os dados coletados
    final novoRegistro = CheckInModel(
      dataHora: DateTime.now().toString().substring(0, 19),
      latitude: _currentPosition!.latitude,
      longitude: _currentPosition!.longitude,
      observacao: _obsController.text.isEmpty
          ? 'Sem observação'
          : _obsController.text,
      caminhoFoto: _imageFile!.path,
    );

    // Insere o novo registro no banco de dados
    await DatabaseHelper.instance.insertRegistro(novoRegistro);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Registro salvo com sucesso! 🔊',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        backgroundColor: primaryPurple,
      ),
    );

    Navigator.pop(context, true);
  }

  // Inicializa o estado do widget, verificando permissões e obtendo localização e foto
  @override
  void initState() {
    super.initState();
    _verificarPermissoes().then((granted) {
      if (granted) {
        _obterLocalizacao();
        _tirarFoto();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      appBar: AppBar(
        title: Text(
          'Novo Registro de Ponto',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: primaryPurple,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Preview da Foto com bordas arredondadas e sombra suave
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: _imageFile != null
                  ? Image.file(_imageFile!, height: 200, fit: BoxFit.cover)
                  : Container(
                      height: 200,
                      color: Colors.white,
                      child: Center(
                        child: Text(
                          'Nenhuma foto capturada',
                          style: GoogleFonts.roboto(color: Colors.grey[600]),
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 12),

            // Botão de Tirar Nova Foto Estilizado
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: primaryPurple,
                elevation: 1,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: lightPurple, width: 1.5),
                ),
              ),
              onPressed: _tirarFoto,
              icon: const Icon(Icons.camera_alt_rounded),
              label: Text(
                'Tirar Nova Foto',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 24),

            // Bloco de Informações de Localização / GPS
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: primaryPurple.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Text(
                          _currentPosition != null
                              ? 'Latitude: ${_currentPosition!.latitude}\nLongitude: ${_currentPosition!.longitude}'
                              : 'Localização não obtida.',
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: darkPurpleText,
                          ),
                        ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primaryPurple,
                      side: BorderSide(color: primaryPurple),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _obterLocalizacao,
                    icon: const Icon(Icons.gps_fixed),
                    label: Text(
                      'Atualizar GPS',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Campo de Observação Estilizado
            TextField(
              controller: _obsController,
              style: GoogleFonts.roboto(color: Colors.black87),
              decoration: InputDecoration(
                labelText: 'Observação / Diário de Campo',
                labelStyle: GoogleFonts.poppins(color: primaryPurple),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: primaryPurple, width: 2),
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 28),

            // Botão Principal de Salvar
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 3,
              ),
              onPressed: _salvarRegistro,
              child: Text(
                'Salvar Registro',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}