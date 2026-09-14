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
          TextButton(
            onPressed: _confirmarSaida,
            child: const Text('Sair'),
          ),
          TextButton(
            onPressed: widget.onAlternarTema,
            child: Text(widget.modoEscuro ? 'Claro' : 'Escuro'),
          ),
        ],
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: Theme.of(context).brightness == Brightness.dark
                              ? const [Color(0xFF0B294D), Color(0xFF123F6C)]
                              : const [Color(0xFFDCECF8), Color(0xFFF5FAFF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white12
                              : Colors.blueGrey.shade100,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (Theme.of(context).brightness == Brightness.dark
                                    ? Colors.black
                                    : Colors.blueGrey)
                                .withValues(alpha: 0.05),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
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
                                      label: const Text('Foto'),
                                      onPressed: _selecionarFoto,
                                    ),
                                    ActionChip(
                                      label: const Text('Editar'),
                                      onPressed: _abrirTelaEdicao,
                                    ),
                                    ActionChip(
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
                    const SizedBox(height: 20),
                    Text(
                      'Dados pessoais',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: Theme.of(context).brightness == Brightness.dark
                              ? const [Color(0xFF0B294D), Color(0xFF123F6C)]
                              : const [Color(0xFFDCECF8), Color(0xFFF5FAFF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white12
                              : Colors.blueGrey.shade100,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (Theme.of(context).brightness == Brightness.dark
                                    ? Colors.black
                                    : Colors.blueGrey)
                                .withValues(alpha: 0.05),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            title: Text(
                              'Nome',
                              style: TextStyle(
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : const Color(0xFF123B68),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              _nomeController.text.trim().isNotEmpty
                                  ? _nomeController.text.trim()
                                  : 'Não informado',
                              style: TextStyle(
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white70
                                    : const Color(0xFF35607F),
                              ),
                            ),
                          ),
                          const Divider(height: 1),
                          ListTile(
                            title: Text(
                              'E-mail',
                              style: TextStyle(
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : const Color(0xFF123B68),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              emailExibido,
                              style: TextStyle(
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white70
                                    : const Color(0xFF35607F),
                              ),
                            ),
                          ),
                          const Divider(height: 1),
                          ListTile(
                            title: Text(
                              'Telefone',
                              style: TextStyle(
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : const Color(0xFF123B68),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              telefoneExibido,
                              style: TextStyle(
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white70
                                    : const Color(0xFF35607F),
                              ),
                            ),
                          ),
                          const Divider(height: 1),
                          ListTile(
                            title: Text(
                              'Cidade',
                              style: TextStyle(
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : const Color(0xFF123B68),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              cidadeExibida,
                              style: TextStyle(
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white70
                                    : const Color(0xFF35607F),
                              ),
                            ),
                          ),
                          const Divider(height: 1),
                          ListTile(
                            title: Text(
                              'Biografia',
                              style: TextStyle(
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : const Color(0xFF123B68),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              bioExibida,
                              style: TextStyle(
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white70
                                    : const Color(0xFF35607F),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
    );
  }
}
