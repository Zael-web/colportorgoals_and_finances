import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/auth_service.dart';
import 'perfil_edicao_screen.dart';

class UsuarioScreen extends StatefulWidget {
  const UsuarioScreen({
    super.key,
    required this.modoEscuro,
    required this.onAlternarTema,
  });

  final bool modoEscuro;
  final VoidCallback onAlternarTema;

  @override
  State<UsuarioScreen> createState() => _UsuarioScreenState();
}

class _UsuarioScreenState extends State<UsuarioScreen> {
  String _perfilKeyUsuario() {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'anon';
    return 'perfil_usuario_$uid';
  }

  String _fotoKeyUsuario() {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'anon';
    return 'foto_perfil_$uid';
  }

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _cidadeController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  bool _carregando = true;
  Uint8List? _fotoPerfilBytes;

  Future<void> _selecionarFoto() async {
    final picker = ImagePicker();
    final imagem = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );

    if (imagem == null) return;

    final bytes = await imagem.readAsBytes();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_fotoKeyUsuario(), base64Encode(bytes));

    if (!mounted) return;

    setState(() {
      _fotoPerfilBytes = bytes;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Foto de perfil atualizada.')),
    );
  }

  Future<void> _abrirTelaEdicao() async {
    final resultado = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PerfilEdicaoScreen(
          nomeInicial: _nomeController.text,
          emailInicial: _emailController.text,
          telefoneInicial: _telefoneController.text,
          cidadeInicial: _cidadeController.text,
          bioInicial: _bioController.text,
        ),
      ),
    );

    if (resultado == true) {
      await _carregarPerfil();
    }
  }

  @override
  void initState() {
    super.initState();
    _carregarPerfil();
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

  Future<void> _carregarPerfil() async {
    final prefs = await SharedPreferences.getInstance();
    final usuario = FirebaseAuth.instance.currentUser;

    if (!mounted) return;

    final perfilString = prefs.getString(_perfilKeyUsuario());
    final fotoBase64 = prefs.getString(_fotoKeyUsuario());
    Map<String, dynamic> perfil = {};

    if (fotoBase64 != null && fotoBase64.isNotEmpty) {
      try {
        final fotoBytes = base64Decode(fotoBase64);
        if (fotoBytes.isNotEmpty) {
          _fotoPerfilBytes = fotoBytes;
        } else {
          _fotoPerfilBytes = null;
        }
      } catch (_) {
        _fotoPerfilBytes = null;
      }
    } else {
      _fotoPerfilBytes = null;
    }

    if (perfilString != null && perfilString.isNotEmpty) {
      try {
        perfil = Map<String, dynamic>.from(jsonDecode(perfilString));
      } catch (_) {
        perfil = {};
      }
    }

    final nomePadrao = perfil['nome'] ?? usuario?.displayName ?? AuthService().getNomeUsuarioLogado();
    final emailPadrao = perfil['email'] ?? usuario?.email ?? '';

    _nomeController.text = nomePadrao.toString();
    _emailController.text = emailPadrao.toString();
    _telefoneController.text = (perfil['telefone'] ?? '').toString();
    _cidadeController.text = (perfil['cidade'] ?? '').toString();
    _bioController.text = (perfil['bio'] ?? '').toString();

    setState(() {
      _carregando = false;
    });
  }

  Future<void> _excluirPerfil() async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir dados pessoais?'),
        content: const Text('Deseja remover os dados pessoais salvos?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmou != true) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_perfilKeyUsuario());
    await prefs.remove(_fotoKeyUsuario());

    final usuario = FirebaseAuth.instance.currentUser;

    _nomeController.text = usuario?.displayName ?? AuthService().getNomeUsuarioLogado();
    _emailController.text = usuario?.email ?? '';
    _telefoneController.clear();
    _cidadeController.clear();
    _bioController.clear();

    if (!mounted) return;

    setState(() {
      _fotoPerfilBytes = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Dados pessoais removidos.')),
    );
  }

  Future<void> _confirmarSaida() async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sair da conta?'),
        content: const Text('Você deseja sair da conta atual?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Sim'),
          ),
        ],
      ),
    );

    if (confirmou == true && mounted) {
      await AuthService().sair();
    }
  }

  @override
  Widget build(BuildContext context) {
    final nomeExibido = _nomeController.text.trim().isNotEmpty
        ? _nomeController.text.trim()
        : 'Usuário';
    final emailExibido = _emailController.text.trim().isNotEmpty
        ? _emailController.text.trim()
        : 'Sem e-mail cadastrado';
    final telefoneExibido = _telefoneController.text.trim().isNotEmpty
        ? _telefoneController.text.trim()
        : 'Telefone não informado';
    final cidadeExibida = _cidadeController.text.trim().isNotEmpty
        ? _cidadeController.text.trim()
        : 'Cidade não informada';
    final bioExibida = _bioController.text.trim().isNotEmpty
        ? _bioController.text.trim()
        : 'Sem biografia no momento.';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Usuário'),
        actions: [
          IconButton(
            onPressed: _confirmarSaida,
            icon: const Icon(Icons.logout),
            tooltip: 'Sair da conta',
          ),
          IconButton(
            onPressed: widget.onAlternarTema,
            icon: Icon(
              widget.modoEscuro ? Icons.light_mode : Icons.dark_mode,
            ),
            tooltip: widget.modoEscuro
                ? 'Ativar modo claro'
                : 'Ativar modo escuro',
          ),
        ],
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      clipBehavior: Clip.antiAlias,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: _selecionarFoto,
                              child: CircleAvatar(
                                radius: 38,
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                backgroundImage: _fotoPerfilBytes != null
                                    ? MemoryImage(_fotoPerfilBytes!)
                                    : null,
                                child: _fotoPerfilBytes == null
                                    ? Text(
                                        nomeExibido.substring(0, 1).toUpperCase(),
                                        style: const TextStyle(
                                          fontSize: 28,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    nomeExibido,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    emailExibido,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
                                        ),
                                  ),
                                  const SizedBox(height: 10),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      ActionChip(
                                        avatar: const Icon(Icons.photo_library_outlined, size: 18),
                                        label: const Text('Foto'),
                                        onPressed: _selecionarFoto,
                                      ),
                                      ActionChip(
                                        avatar: const Icon(Icons.edit_outlined, size: 18),
                                        label: const Text('Editar'),
                                        onPressed: _abrirTelaEdicao,
                                      ),
                                      ActionChip(
                                        avatar: const Icon(Icons.delete_outline, size: 18),
                                        label: const Text('Excluir'),
                                        onPressed: _excluirPerfil,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Dados pessoais',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.person_outline),
                              title: const Text('Nome'),
                              subtitle: Text(
                                _nomeController.text.trim().isNotEmpty
                                    ? _nomeController.text.trim()
                                    : 'Não informado',
                              ),
                            ),
                            const Divider(height: 1),
                            ListTile(
                              leading: const Icon(Icons.email_outlined),
                              title: const Text('E-mail'),
                              subtitle: Text(emailExibido),
                            ),
                            const Divider(height: 1),
                            ListTile(
                              leading: const Icon(Icons.phone_outlined),
                              title: const Text('Telefone'),
                              subtitle: Text(telefoneExibido),
                            ),
                            const Divider(height: 1),
                            ListTile(
                              leading: const Icon(Icons.location_on_outlined),
                              title: const Text('Cidade'),
                              subtitle: Text(cidadeExibida),
                            ),
                            const Divider(height: 1),
                            ListTile(
                              leading: const Icon(Icons.info_outline),
                              title: const Text('Biografia'),
                              subtitle: Text(bioExibida),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
