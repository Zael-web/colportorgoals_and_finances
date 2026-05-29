import 'package:flutter/material.dart';

class CalculadoraScreen extends StatelessWidget {
  const CalculadoraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculadora'),
      ),

      body: const Center(
        child: Text(
          'Tela da Calculadora',
          style: TextStyle(fontSize: 22),
        ),
      ),
    );
  }
}