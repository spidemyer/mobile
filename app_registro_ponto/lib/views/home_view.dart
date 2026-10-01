import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/ponto_model.dart';
import '../services/firebase_service.dart';
import '../services/auth_service.dart';
import '../services/location_service.dart';
import 'historico_view.dart';
import 'package:local_auth/local_auth.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final LocationService _locationService = LocationService();
  final FirebaseService _firebaseService = FirebaseService();
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _isLoading = false;
  String _statusMessage = 'Aguardando registro...';
  String _tipo = 'entrada';

  Future<bool> _confirmarBiometria() async {
    if (!await _localAuth.isDeviceSupported()) return true;
    return _localAuth.authenticate(
      localizedReason: 'Confirme sua identidade para registrar o ponto',
      options: const AuthenticationOptions(
        biometricOnly: true,
        stickyAuth: true,
      ),
    );
  }

  Future<void> _registrarPonto() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Verificando localização...';
    });

    try {
      final confirmado = await _confirmarBiometria();
      if (!mounted) return;
      if (!confirmado) {
        setState(() => _statusMessage = 'Biometria não confirmada.');
        return;
      }

      // A mesma posição é usada na validação e no registro do ponto.
      final position = await _locationService.getCurrentLocation();
      final distancia = _locationService.distanceFromWorkplace(position);
      final dentroDoRaio = distancia <= LocationService.raioPermitidoMetros;

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
          tipo: _tipo,
          distanciaMetros: distancia,
        );
        await _firebaseService.salvarPonto(ponto);
        if (!mounted) return;
        setState(() {
          _statusMessage = 'Ponto registrado com sucesso em:\n$dataHoraAtual';
        });
      } else {
        setState(() {
          _statusMessage =
              'Você está a ${distancia.toStringAsFixed(0)} m do local. '
              'O máximo permitido é ${LocationService.raioPermitidoMetros.toStringAsFixed(0)} m.';
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
      appBar: AppBar(
        title: const Text('Registro de Ponto'),
        actions: [
          IconButton(
            tooltip: 'Sair',
            icon: const Icon(Icons.logout),
            onPressed: () => AuthService().signOut(),
          ),
        ],
      ),
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
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'entrada',
                    label: Text('Entrada'),
                    icon: Icon(Icons.login),
                  ),
                  ButtonSegment(
                    value: 'saida',
                    label: Text('Saída'),
                    icon: Icon(Icons.logout),
                  ),
                ],
                selected: {_tipo},
                onSelectionChanged: (selection) {
                  setState(() => _tipo = selection.first);
                },
              ),
              const SizedBox(height: 24),
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
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HistoricoView()),
                ),
                icon: const Icon(Icons.history),
                label: const Text('Ver histórico'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
