import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../data/app_data.dart';
import 'materiais_screen.dart';
import 'metas_screen.dart';
import 'planejamento_screen.dart';
import 'registro_screen.dart';
import 'usuario_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.modoEscuro,
    required this.onAlternarTema,
  });

  final bool modoEscuro;
  final VoidCallback onAlternarTema;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final List<Widget> paginas;

  @override
  void initState() {
    super.initState();
    paginas = [
      DashboardPage(
        onAbrirUsuario: () {
          setState(() {
            paginaAtual = 5;
          });
        },
      ),
      RegistroScreen(
        atualizarHome: atualizarMetaBolsa,
        modoEscuro: widget.modoEscuro,
        onAlternarTema: widget.onAlternarTema,
      ),
      MetasScreen(
        onMetaChanged: atualizarMetaBolsa,
        modoEscuro: widget.modoEscuro,
        onAlternarTema: widget.onAlternarTema,
      ),
      const MateriaisScreen(),
      PlanejamentoScreen(onMetaChanged: atualizarMetaBolsa),
      UsuarioScreen(
        modoEscuro: widget.modoEscuro,
        onAlternarTema: widget.onAlternarTema,
      ),
    ];
  }

  void atualizarMetaBolsa() {
    setState(() {});
  }

  int paginaAtual = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: paginaAtual, children: paginas),

      bottomNavigationBar: NavigationBar(
        selectedIndex: paginaAtual,

        onDestinationSelected: (index) {
          setState(() {
            paginaAtual = index;
          });
        },

        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Início'),

          NavigationDestination(icon: Icon(Icons.edit_note), label: 'Registro'),

          NavigationDestination(icon: Icon(Icons.flag), label: 'Metas'),

          NavigationDestination(
            icon: Icon(Icons.menu_book),
            label: 'Materiais',
          ),

          NavigationDestination(
            icon: Icon(Icons.timeline),
            label: 'Planejamento',
          ),
          NavigationDestination(
            icon: Icon(Icons.person),
            label: 'Usuário',
          ),
        ],
      ),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key, required this.onAbrirUsuario});

  final VoidCallback onAbrirUsuario;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    dadosGlobaisVersion.addListener(_atualizarDados);
  }

  @override
  void dispose() {
    dadosGlobaisVersion.removeListener(_atualizarDados);
    super.dispose();
  }

  void _atualizarDados() {
    if (mounted) {
      setState(() {});
    }
  }

  double totalVendido() {
    double total = 0;

    for (var registro in registrosDoPlanejamentoAtual()) {
      total += registro.vendido;
    }

    return total;
  }

  double totalComprado() {
    double total = 0;

    for (var registro in registrosDoPlanejamentoAtual()) {
      total += registro.comprado;
    }

    return total;
  }

  int totalLivros() {
    int total = 0;

    for (var registro in registrosDoPlanejamentoAtual()) {
      total += registro.quantidade;
    }

    return total;
  }

  @override
  Widget build(BuildContext context) {
    final temaEscuro = Theme.of(context).brightness == Brightness.dark;
    final corTextoPainel = temaEscuro ? Colors.white : const Color(0xFF123B68);
    final progresso = metaBolsaGlobal == 0
        ? 0.0
        : (totalComprado() / metaBolsaGlobal * 100).clamp(0.0, 100.0);
    final nomeUsuario = AuthService().getNomeUsuarioLogado();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Colporto planejamento'),
        actions: [
          TextButton(
            onPressed: widget.onAbrirUsuario,
            child: const Text('Perfil'),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bom dia, $nomeUsuario 👋',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Aqui está o resumo da sua campanha.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: temaEscuro
                          ? const [Color(0xFF0B294D), Color(0xFF123F6C)]
                          : const [Color(0xFFDCECF8), Color(0xFFF5FAFF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: temaEscuro ? Colors.white12 : Colors.blueGrey.shade100,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (temaEscuro ? Colors.black : Colors.blueGrey)
                            .withValues(alpha: 0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Meta da Bolsa',
                        style: TextStyle(
                          color: corTextoPainel.withValues(alpha: 0.72),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        formatarMoedaGlobal(metaBolsaGlobal),
                        style: TextStyle(
                          color: corTextoPainel,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 14),
                      LinearProgressIndicator(
                        value: progresso / 100,
                        minHeight: 12,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '$progresso% concluído',
                        style: TextStyle(
                          color: corTextoPainel,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Falta: ${formatarMoedaGlobal(faltaParaBolsa())}',
                        style: TextStyle(color: corTextoPainel, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Dias restantes: ${diasRestantes()}',
                        style: TextStyle(color: corTextoPainel, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Meta diária: ${formatarMoedaGlobal(metaDiariaNecessaria())}',
                        style: TextStyle(color: corTextoPainel, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Total comprado + dizimo: ${formatarMoedaGlobal(totalComprado())}',
                        style: TextStyle(color: corTextoPainel, fontSize: 16),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Resumo Geral',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: dashboardCard(
                        titulo: 'Vendido',
                        valor: formatarMoedaGlobal(totalVendido()),
                        cor: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: dashboardCard(
                        titulo: 'Total comprado',
                        valor: formatarMoedaGlobal(totalComprado()),
                        cor: Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: dashboardCard(
                    titulo: 'Lucro total',
                    valor: formatarMoedaGlobal(totalLucroGlobal()),
                    cor: Colors.teal,
                    isFullWidth: true,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: dashboardCard(
                        titulo: 'Total de Livros vendidos',
                        valor: '${totalLivros()}',
                        cor: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: dashboardCard(
                        titulo: 'Meta/Dia',
                        valor: formatarMoedaGlobal(metaDiariaNecessaria()),
                        cor: Colors.purple,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                const Text(
                  'Últimos Registros',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                if (registrosDoPlanejamentoAtual().isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('Nenhum registro ainda'),
                    ),
                  ),
                ...registrosDoPlanejamentoAtual().reversed.map((registro) {
                  return registroTile(
                    '${registro.data.day}/${registro.data.month}/${registro.data.year}',
                    formatarMoedaGlobal(registro.vendido),
                    '${registro.quantidade} livros',
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget dashboardCard({
    required String titulo,
    required String valor,
    required Color cor,
    bool isFullWidth = false,
  }) {
    final temaEscuro = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: isFullWidth ? 180 : 138,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: temaEscuro
              ? const [Color(0xFF0B294D), Color(0xFF123F6C)]
              : const [Color(0xFFDCECF8), Color(0xFFF5FAFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: temaEscuro ? Colors.white12 : Colors.blueGrey.shade100,
        ),
        boxShadow: [
          BoxShadow(
            color: (temaEscuro ? Colors.black : Colors.blueGrey)
                .withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: isFullWidth
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    titulo,
                    style: TextStyle(
                      color: temaEscuro ? Colors.white70 : const Color(0xFF35607F),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    valor,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: temaEscuro ? Colors.white : const Color(0xFF123B68),
                    ),
                  ),
                ],
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  titulo,
                  style: TextStyle(
                    color: temaEscuro ? Colors.white70 : const Color(0xFF35607F),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  valor,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: temaEscuro ? Colors.white : const Color(0xFF123B68),
                  ),
                ),
              ],
            ),
    );
  }

  Widget registroTile(String data, String valor, String livros) {
    final temaEscuro = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: temaEscuro
              ? const [Color(0xFF0B294D), Color(0xFF123F6C)]
              : const [Color(0xFFDCECF8), Color(0xFFF5FAFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: temaEscuro ? Colors.white12 : Colors.blueGrey.shade100,
        ),
        boxShadow: [
          BoxShadow(
            color: (temaEscuro ? Colors.black : Colors.blueGrey)
                .withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: temaEscuro ? Colors.white : const Color(0xFF123B68),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                livros,
                style: TextStyle(
                  color: temaEscuro ? Colors.white70 : const Color(0xFF35607F),
                ),
              ),
            ],
          ),
          Text(
            valor,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: temaEscuro ? Colors.white : Colors.blue,
            ),
          ),
        ],
      ),
    );
  }
}
