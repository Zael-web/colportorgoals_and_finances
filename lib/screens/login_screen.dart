import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _authService = AuthService();
  bool _carregando = false;
  bool _modoCadastro = false;
  bool _mostrarSenha = false;
  late final AnimationController _animacaoEntrada;
  late final Animation<double> _opacidadeEntrada;
  late final Animation<double> _escalaEntrada;

  @override
  void initState() {
    super.initState();
    _animacaoEntrada = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    final curvaEntrada = CurvedAnimation(
      parent: _animacaoEntrada,
      curve: Curves.easeOutCubic,
    );
    _opacidadeEntrada = curvaEntrada;
    _escalaEntrada = Tween<double>(begin: 0.94, end: 1).animate(curvaEntrada);
    _animacaoEntrada.forward();
  }

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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_mensagemErroAuth(e.code))));
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(mensagem)));
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
    final tema = Theme.of(context);
    final emailController = TextEditingController(
      text: _emailController.text.trim(),
    );
    var enviando = false;
    String? erro;

    final enviado = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          Future<void> enviar() async {
            final email = emailController.text.trim();
            final emailValido =
                email.isNotEmpty &&
                RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);

            if (!emailValido) {
              setDialogState(() => erro = 'Informe um e-mail válido.');
              return;
            }

            setDialogState(() {
              enviando = true;
              erro = null;
            });

            try {
              await _authService.recuperarSenha(email: email);
              if (dialogContext.mounted) {
                Navigator.of(dialogContext).pop(true);
              }
            } on FirebaseAuthException catch (e) {
              setDialogState(() => erro = _mensagemErroAuth(e.code));
            } catch (_) {
              setDialogState(() => erro = 'Não foi possível enviar o e-mail.');
            } finally {
              if (dialogContext.mounted) {
                setDialogState(() => enviando = false);
              }
            }
          }

          final corDestaque = tema.brightness == Brightness.dark
              ? const Color(0xFF8BC7FF)
              : const Color(0xFF1769AA);

          return AlertDialog(
            backgroundColor: tema.brightness == Brightness.dark
                ? const Color(0xFF102D4D)
                : const Color(0xFFF5FAFE),
            title: Row(
              children: [
                Icon(Icons.lock_reset, color: corDestaque),
                const SizedBox(width: 10),
                const Expanded(child: Text('Esqueci a senha')),
              ],
            ),
            content: SizedBox(
              width: 360,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Informe seu e-mail e enviaremos um link para criar uma nova senha.',
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: emailController,
                    autofocus: true,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'E-mail',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    onSubmitted: (_) => enviar(),
                  ),
                  if (erro != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      erro!,
                      style: TextStyle(color: tema.colorScheme.error),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: enviando
                    ? null
                    : () => Navigator.of(dialogContext).pop(false),
                child: const Text('Cancelar'),
              ),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: tema.brightness == Brightness.dark
                      ? const Color(0xFF4DA3FF)
                      : const Color(0xFF1769AA),
                  foregroundColor: tema.brightness == Brightness.dark
                      ? const Color(0xFF071826)
                      : Colors.white,
                ),
                onPressed: enviando ? null : enviar,
                icon: enviando
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
                label: const Text('Enviar link'),
              ),
            ],
          );
        },
      ),
    );

    final emailEnviado = emailController.text.trim();
    emailController.dispose();
    if (enviado == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('E-mail de recuperação enviado para $emailEnviado'),
        ),
      );
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
    _animacaoEntrada.dispose();
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final corBotao = tema.brightness == Brightness.dark
        ? const Color(0xFF4DA3FF)
        : const Color(0xFF1769AA);
    final corTextoBotao = tema.brightness == Brightness.dark
        ? const Color(0xFF071826)
        : Colors.white;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: FadeTransition(
              opacity: _opacidadeEntrada,
              child: ScaleTransition(
                scale: _escalaEntrada,
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
                            width: 108,
                            height: 108,
                            alignment: Alignment.center,
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              color: tema.colorScheme.primary.withValues(
                                alpha: 0.12,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Image.network(
                              'https://i.ibb.co/7tX6yPQD/app1.jpg',
                              width: 108,
                              height: 108,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return SizedBox(
                                      width: 108,
                                      height: 108,
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          value:
                                              loadingProgress
                                                      .expectedTotalBytes ==
                                                  null
                                              ? null
                                              : loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!,
                                        ),
                                      ),
                                    );
                                  },
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.person_add_alt_1_rounded,
                                  size: 72,
                                  color: tema.colorScheme.primary,
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _modoCadastro
                                ? 'Criar sua conta'
                                : 'Entrar com e-mail',
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
                              if (!RegExp(
                                r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                              ).hasMatch(email)) {
                                return 'E-mail inválido.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _senhaController,
                            obscureText: !_mostrarSenha,
                            decoration: InputDecoration(
                              labelText: 'Senha',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                tooltip: _mostrarSenha
                                    ? 'Ocultar senha'
                                    : 'Mostrar senha',
                                onPressed: () {
                                  setState(
                                    () => _mostrarSenha = !_mostrarSenha,
                                  );
                                },
                                icon: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 180),
                                  transitionBuilder: (child, animation) {
                                    return FadeTransition(
                                      opacity: animation,
                                      child: ScaleTransition(
                                        scale: animation,
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: Icon(
                                    _mostrarSenha
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    key: ValueKey(_mostrarSenha),
                                  ),
                                ),
                              ),
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
                                style: TextButton.styleFrom(
                                  foregroundColor:
                                      tema.brightness == Brightness.dark
                                      ? const Color(0xFF8BC7FF)
                                      : const Color(0xFF1769AA),
                                ),
                                onPressed: _carregando ? null : _recuperarSenha,
                                child: const Text('Esqueci a senha'),
                              ),
                            ),
                          const SizedBox(height: 10),
                          FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: corBotao,
                              foregroundColor: corTextoBotao,
                            ),
                            onPressed: _carregando ? null : _submit,
                            icon: _carregando
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.login),
                            label: Text(
                              _modoCadastro ? 'Criar conta' : 'Entrar',
                            ),
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
                            style: OutlinedButton.styleFrom(
                              foregroundColor:
                                  tema.brightness == Brightness.dark
                                  ? Colors.white
                                  : const Color(0xFF123B68),
                              side: BorderSide(
                                color: tema.brightness == Brightness.dark
                                    ? Colors.white54
                                    : const Color(0xFF1769AA),
                              ),
                            ),
                            onPressed: _carregando ? null : _entrarComGoogle,
                            icon: const Icon(Icons.g_mobiledata_rounded),
                            label: const Text('Entrar com Google'),
                          ),
                          const SizedBox(height: 14),
                          TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor:
                                  tema.brightness == Brightness.dark
                                  ? const Color(0xFF8BC7FF)
                                  : const Color(0xFF1769AA),
                            ),
                            onPressed: _carregando
                                ? null
                                : () {
                                    setState(
                                      () => _modoCadastro = !_modoCadastro,
                                    );
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
        ),
      ),
    );
  }
}
