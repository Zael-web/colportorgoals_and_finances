import 'package:flutter/material.dart';

class MateriaisScreen extends StatelessWidget {
  const MateriaisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Materiais'),
      ),

      body: const Center(
        child: Text(
          'Tela de Materiais',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}