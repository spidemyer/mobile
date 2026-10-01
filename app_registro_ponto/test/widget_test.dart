// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:app_registro_ponto/models/ponto_model.dart';

void main() {
  test('PontoModel converte para Map e de volta', () {
    final ponto = PontoModel(
      id: 'u1_1',
      userId: 'u1',
      dataHora: '2026-10-01T08:00:00.000',
      latitude: -23.55,
      longitude: -46.63,
      tipo: 'entrada',
      distanciaMetros: 12.0,
    );

    final copia = PontoModel.fromMap(ponto.toMap());

    expect(copia.userId, 'u1');
    expect(copia.tipo, 'entrada');
    expect(copia.latitude, -23.55);
    expect(copia.distanciaMetros, 12.0);
  });
}
