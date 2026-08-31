import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meu_primeiro_app/firebase_options.dart';
import 'package:meu_primeiro_app/screens/login_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  });

  testWidgets('exibe formulário de login por e-mail', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LoginScreen(),
      ),
    );

    expect(find.text('Entrar com e-mail'), findsOneWidget);
    expect(find.text('E-mail'), findsWidgets);
    expect(find.text('Senha'), findsWidgets);
  });
}
