import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meu_primeiro_app/screens/login_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('exibe formulário de login por e-mail e botão de tema', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LoginScreen(
          modoEscuro: true,
          onAlternarTema: _alternarTemaNoTeste,
        ),
      ),
    );

    expect(find.text('Entrar com e-mail'), findsOneWidget);
    expect(find.text('E-mail'), findsWidgets);
    expect(find.text('Senha'), findsWidgets);
    expect(find.text('Claro'), findsOneWidget);
  });
}

void _alternarTemaNoTeste() {}
