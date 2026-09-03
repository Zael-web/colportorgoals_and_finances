import 'package:flutter_test/flutter_test.dart';
import 'package:meu_primeiro_app/models/campanha.dart';

void main() {
  test('calcula dias úteis ignorando fim de semana e feriado', () {
    final dataFim = Planejamento.calcularDataFim(
      dataInicio: DateTime(2026, 9, 4),
      quantidadeDias: 3,
      feriados: [DateTime(2026, 9, 7)],
    );

    expect(dataFim, DateTime(2026, 9, 9));
  });

  test('mantém dados antigos sem quantidade de dias', () {
    final planejamento = Planejamento.fromMap({
      'id': 'antigo',
      'nome': 'Planejamento antigo',
      'meta': 1000,
      'dataInicio': '2026-09-01T00:00:00.000',
      'dataFim': '2026-09-07T00:00:00.000',
    });

    expect(planejamento.quantidadeDias, 5);
    expect(planejamento.feriados, isEmpty);
  });
}
