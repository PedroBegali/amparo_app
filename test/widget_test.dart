import 'package:amparo_sus_app/main.dart';
import 'package:amparo_sus_app/models/visita.dart';
import 'package:amparo_sus_app/utils/cores_sus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets("Login valida campos vazios", (WidgetTester tester) async {
    await tester.pumpWidget(const AmparoApp());

    expect(find.text("Identificação do agente"), findsOneWidget);
    await tester.ensureVisible(find.text("Entrar"));
    await tester.tap(find.text("Entrar"));
    await tester.pump();

    expect(find.text("Informe o e-mail."), findsOneWidget);
    expect(find.text("Informe a senha."), findsOneWidget);
  });

  testWidgets("Usuário de teste preenche o formulário", (WidgetTester tester) async {
    await tester.pumpWidget(const AmparoApp());

    await tester.ensureVisible(find.text("Agente"));
    await tester.tap(find.text("Agente"));
    await tester.pump();

    final email = tester.widget<TextField>(find.byType(TextField).first);
    final senha = tester.widget<TextField>(find.byType(TextField).last);
    expect(email.controller!.text, "agente@amparo.gov.br");
    expect(senha.controller!.text, "amparo123");
  });

  test("Visita converte o JSON da API", () {
    final visita = Visita.fromJson({
      "id": 1,
      "pacienteId": 1,
      "pacienteNome": "José Carlos da Silva",
      "pacienteEndereco": "Rua das Palmeiras, 120",
      "agenteId": 1,
      "nivelRisco": "CRITICO",
      "score": 110,
      "motivo": "Botão SOS acionado nas últimas 24h",
      "status": "PENDENTE",
      "dataGeracao": "2026-11-12T15:36:37.833664",
    });
    expect(visita.score, 110);
    expect(visita.dataGeracao.hour, 15);
  });

  test("Condições aparecem por extenso", () {
    expect(condicoesPorExtenso("HAS,ICC"), "Hipertensão, Insuf. cardíaca");
    expect(rotuloDoNivel("CRITICO"), "Crítico");
  });
}
