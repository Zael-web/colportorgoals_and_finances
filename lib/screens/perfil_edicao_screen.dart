import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PerfilEdicaoScreen extends StatefulWidget {
  const PerfilEdicaoScreen({
    super.key,
    required this.nomeInicial,
    required this.emailInicial,
    required this.telefoneInicial,
    required this.cidadeInicial,
    required this.bioInicial,
  });

  final String nomeInicial;
  final String emailInicial;
  final String telefoneInicial;
  final String cidadeInicial;
  final String bioInicial;

  @override
  State<PerfilEdicaoScreen> createState() => _PerfilEdicaoScreenState();
}

class _PerfilEdicaoScreenState extends State<PerfilEdicaoScreen> {
  String _perfilKeyUsuario() {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'anon';
    return 'perfil_usuario_$uid';
  }

  late final TextEditingController _nomeController;
  late final TextEditingController _emailController;
  late final TextEditingController _telefoneController;
  late final TextEditingController _cidadeController;
  late final TextEditingController _bioController;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.nomeInicial);
    _emailController = TextEditingController(text: widget.emailInicial);
    _telefoneController = TextEditingController(text: widget.telefoneInicial);
    _cidadeController = TextEditingController(text: widget.cidadeInicial);
    _bioController = TextEditingController(text: widget.bioInicial);
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    _cidadeController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _salvarPerfil() async {
    final nome = _nomeController.text.trim();
    final email = _emailController.text.trim();
    final telefone = _telefoneController.text.trim();
    final cidade = _cidadeController.text.trim();
    final bio = _bioController.text.trim();

    if (nome.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe o nome completo.')),
      );
      return;
    }

    final perfil = {
      'nome': nome,
      'email': email,
      'telefone': telefone,
      'cidade': cidade,
      'bio': bio,
      'atualizadoEm': DateTime.now().toIso8601String(),
    };

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_perfilKeyUsuario(), jsonEncode(perfil));

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Perfil salvo com sucesso.')),
    );

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar perfil'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome completo',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'E-mail',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _telefoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Telefone',
                prefixIcon: Icon(Icons.phone),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _cidadeController,
              decoration: const InputDecoration(
                labelText: 'Cidade',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _bioController,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Biografia',
                prefixIcon: Icon(Icons.info_outline),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _salvarPerfil,
                icon: const Icon(Icons.save),
                label: const Text('Salvar alterações'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
