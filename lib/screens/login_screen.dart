import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _authService = AuthService();
  bool _carregando = false;
  bool _modoCadastro = false;

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() => _carregando = true);

    try {
      if (_modoCadastro) {
        final credential = await _authService.cadastrarComEmailSenha(
          email: _emailController.text,
          senha: _senhaController.text,
        );

        if (credential.user != null && _nomeController.text.trim().isNotEmpty) {
          await credential.user!.updateDisplayName(_nomeController.text.trim());
          await credential.user!.reload();
        }
      } else {
        await _authService.entrarComEmailSenha(
          email: _emailController.text,
          senha: _senhaController.text,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_mensagemErroAuth(e.code))),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível concluir a operação.')),
      );
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<void> _entrarComGoogle() async {
    setState(() => _carregando = true);

    try {
      await _authService.entrarComGoogle();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      final mensagem = e.code == 'sign_in_canceled'
          ? 'Login com Google cancelado.'
          : _mensagemErroAuth(e.code);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensagem)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível entrar com Google.')),
      );
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<void> _recuperarSenha() async {
    final email = _emailController.text.trim();

    if (email.isEmpty || !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe um e-mail válido para recuperar a senha.')),
      );
      return;
    }

    setState(() => _carregando = true);

    try {
      await _authService.recuperarSenha(email: email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('E-mail de recuperação enviado para $email')),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_mensagemErroAuth(e.code))),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível enviar o e-mail de recuperação.')),
      );
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  String _mensagemErroAuth(String code) {
    switch (code) {
      case 'invalid-email':
        return 'E-mail inválido.';
      case 'user-not-found':
        return 'Nenhuma conta encontrada com este e-mail.';
      case 'wrong-password':
        return 'Senha incorreta.';
      case 'email-already-in-use':
        return 'Este e-mail já está em uso.';
      case 'weak-password':
        return 'A senha é muito fraca.';
      case 'too-many-requests':
        return 'Muitas tentativas. Tente novamente mais tarde.';
      case 'network-request-failed':
        return 'Erro de rede. Verifique sua conexão.';
      default:
        return 'Erro ao autenticar. Tente novamente.';
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Card(
              elevation: 0,
              color: tema.colorScheme.surface.withValues(alpha: 0.92),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: tema.colorScheme.primary.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.person_add_alt_1_rounded,
                          size: 72,
                          color: tema.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _modoCadastro ? 'Criar sua conta' : 'Entrar com e-mail',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (_modoCadastro)
                        TextFormField(
                          controller: _nomeController,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            labelText: 'Nome completo',
                            prefixIcon: Icon(Icons.badge_outlined),
                          ),
                          validator: (value) {
                            final nome = value?.trim() ?? '';
                            if (_modoCadastro && nome.isEmpty) {
                              return 'Informe seu nome.';
                            }
                            return null;
                          },
                        ),
                      if (_modoCadastro) const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'E-mail',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        validator: (value) {
                          final email = value?.trim() ?? '';
                          if (email.isEmpty) {
                            return 'Informe seu e-mail.';
                          }
                          if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
                            return 'E-mail inválido.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _senhaController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Senha',
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Informe sua senha.';
                          }
                          if (value.length < 6) {
                            return 'A senha deve ter pelo menos 6 caracteres.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),
                      if (!_modoCadastro)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _carregando ? null : _recuperarSenha,
                            child: const Text('Esqueci a senha'),
                          ),
                        ),
                      const SizedBox(height: 10),
                      FilledButton.icon(
                        onPressed: _carregando ? null : _submit,
                        icon: _carregando
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.login),
                        label: Text(_modoCadastro ? 'Criar conta' : 'Entrar'),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: const [
                          Expanded(child: Divider()),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text('ou'),
                          ),
                          Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: 14),
                      OutlinedButton.icon(
                        onPressed: _carregando ? null : _entrarComGoogle,
                        icon: const Icon(Icons.g_mobiledata_rounded),
                        label: const Text('Entrar com Google'),
                      ),
                      const SizedBox(height: 14),
                      TextButton(
                        onPressed: _carregando
                            ? null
                            : () {
                                setState(() => _modoCadastro = !_modoCadastro);
                              },
                        child: Text(
                          _modoCadastro
                              ? 'Já tenho conta. Entrar'
                              : 'Criar conta com e-mail',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
