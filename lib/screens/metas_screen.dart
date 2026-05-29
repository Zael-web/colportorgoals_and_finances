import 'package:flutter/material.dart';

class MetasScreen extends StatelessWidget {
  const MetasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Metas'),
      ),

      body: const Center(
        child: Text(
          'Tela de Metas',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}