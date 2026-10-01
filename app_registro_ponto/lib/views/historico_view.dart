import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/ponto_model.dart';
import '../services/firebase_service.dart';

class HistoricoView extends StatelessWidget {
  const HistoricoView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Sessão expirada. Faça login novamente.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Meus registros')),
      body: StreamBuilder<List<PontoModel>>(
        stream: FirebaseService().streamPontos(user.uid),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Erro ao carregar histórico: ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final pontos = snapshot.data!;
          if (pontos.isEmpty) {
            return const Center(child: Text('Nenhum ponto registrado ainda.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: pontos.length,
            separatorBuilder: (_, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final ponto = pontos[index];
              final data = DateTime.tryParse(ponto.dataHora);
              final dataFormatada = data == null
                  ? ponto.dataHora
                  : DateFormat('dd/MM/yyyy HH:mm:ss').format(data);
              final isEntrada = ponto.tipo == 'entrada';

              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primaryContainer,
                    child: Icon(
                      isEntrada ? Icons.login : Icons.logout,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  title: Text('${ponto.tipo.toUpperCase()} - $dataFormatada'),
                  subtitle: Text(
                    'Distância: ${ponto.distanciaMetros.toStringAsFixed(0)} m\n'
                    'Localização: ${ponto.latitude.toStringAsFixed(5)}, '
                    '${ponto.longitude.toStringAsFixed(5)}',
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
