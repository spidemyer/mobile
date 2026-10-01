import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/ponto_model.dart';
import '../services/firebase_service.dart';
import '../services/location_service.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final LocationService _locationService = LocationService();
  final FirebaseService _firebaseService = FirebaseService();
  bool _isLoading = false;
  String _statusMessage = 'Aguardando registro...';

  Future<void> _registrarPonto() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Verificando localização...';
    });

    try {
      // A mesma posição é usada na validação e no registro do ponto.
      final position = await _locationService.getCurrentLocation();
      final dentroDoRaio =
          _locationService.distanceFromWorkplace(position) <=
          LocationService.raioPermitidoMetros;

      if (dentroDoRaio) {
        final agora = DateTime.now();
        final dataHoraAtual = DateFormat('dd/MM/yyyy - HH:mm:ss').format(agora);
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          throw 'Sua sessão expirou. Faça login novamente.';
        }

        final ponto = PontoModel(
          id: '${user.uid}_${agora.microsecondsSinceEpoch}',
          userId: user.uid,
          dataHora: agora.toIso8601String(),
          latitude: position.latitude,
          longitude: position.longitude,
        );
        await _firebaseService.salvarPonto(ponto);
        setState(() {
          _statusMessage = 'Ponto registrado com sucesso em:\n$dataHoraAtual';
        });
      } else {
        setState(() {
          _statusMessage =
              'Falha: Você está a mais de 100 metros do local de trabalho!';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _statusMessage = 'Erro: $e';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro de Ponto')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_pin,
                size: 60,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 20),
              Text(
                _statusMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 40),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                      onPressed: _registrarPonto,
                      icon: const Icon(Icons.access_time),
                      label: const Text('Bater Ponto'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
