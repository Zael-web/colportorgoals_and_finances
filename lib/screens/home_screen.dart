import 'package:flutter/material.dart';

import 'registro_screen.dart';
import 'metas_screen.dart';

import 'materiais_screen.dart';
import '../data/app_data.dart';
import 'planejamento_screen.dart';

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
      const DashboardPage(),
      RegistroScreen(atualizarHome: atualizarMetaBolsa),
      MetasScreen(onMetaChanged: atualizarMetaBolsa),
      const MateriaisScreen(),
      PlanejamentoScreen(onMetaChanged: atualizarMetaBolsa),
    ];
  }

  void atualizarMetaBolsa() {
    setState(() {});
  }

  int paginaAtual = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(index: paginaAtual, children: paginas),
          Positioned(
            top: MediaQuery.paddingOf(context).top + 4,
            right: 8,
            child: Material(
              color: Theme.of(
                context,
              ).colorScheme.surface.withValues(alpha: 0.85),
              shape: const CircleBorder(),
              child: IconButton(
                tooltip: widget.modoEscuro
                    ? 'Ativar modo claro'
                    : 'Ativar modo escuro',
                onPressed: widget.onAlternarTema,
                icon: Icon(
                  widget.modoEscuro ? Icons.light_mode : Icons.dark_mode,
                ),
              ),
            ),
          ),
        ],
      ),

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
        ],
      ),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  double totalVendido() {
    double total = 0;

    for (var registro in registrosGlobais) {
      total += registro.vendido;
    }

    return total;
  }

  double totalComprado() {
    double total = 0;

    for (var registro in registrosGlobais) {
      total += registro.comprado;
    }

    return total;
  }

  int totalLivros() {
    int total = 0;

    for (var registro in registrosGlobais) {
      total += registro.quantidade;
    }

    return total;
  }

  @override
  Widget build(BuildContext context) {
    final temaEscuro = Theme.of(context).brightness == Brightness.dark;
    final corPainel = temaEscuro
        ? const Color(0xFF0B294D)
        : const Color(0xFFDCECF8);
    final corTextoPainel = temaEscuro ? Colors.white : const Color(0xFF123B68);
    double progresso = metaBolsaGlobal == 0
        ? 0
        : (totalComprado() / metaBolsaGlobal * 100);

    return Scaffold(
      appBar: AppBar(title: const Text('Colportor App')),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const Text(
              'Bom dia, Colportor 👋',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
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
              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: corPainel,
                borderRadius: BorderRadius.circular(20),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,

                    children: [
                      Text(
                        'Meta da Bolsa',
                        style: TextStyle(
                          color: corTextoPainel.withValues(alpha: 0.72),
                          fontSize: 16,
                        ),
                      ),

                      Icon(Icons.emoji_events, color: corTextoPainel),
                    ],
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
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(20),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    '$progresso% concluído',
                    style: TextStyle(color: corTextoPainel),
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
                    'totalComprado: ${formatarMoedaGlobal(totalComprado())}',
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
                    icone: Icons.attach_money,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: dashboardCard(
                    titulo: 'Comprado',
                    valor: formatarMoedaGlobal(totalComprado()),
                    cor: Colors.orange,
                    icone: Icons.shopping_cart,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: dashboardCard(
                    titulo: 'Livros',
                    valor: '${totalLivros()}',
                    cor: Colors.blue,
                    icone: Icons.menu_book,
                  ),
                ),

                const SizedBox(width: 12),
                Expanded(
                  child: dashboardCard(
                    titulo: 'Meta/Dia',
                    valor: formatarMoedaGlobal(metaDiariaNecessaria()),
                    cor: Colors.purple,
                    icone: Icons.flag,
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

            if (registrosGlobais.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('Nenhum registro ainda'),
                ),
              ),

            ...registrosGlobais.reversed.map((registro) {
              return registroTile(
                '${registro.data.day}/${registro.data.month}/${registro.data.year}',
                formatarMoedaGlobal(registro.vendido),
                '${registro.quantidade} livros',
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget dashboardCard({
    required String titulo,
    required String valor,
    required Color cor,
    required IconData icone,
  }) {
    final temaEscuro = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: temaEscuro ? const Color(0xFF0B294D) : const Color(0xFFE4F1FA),
        borderRadius: BorderRadius.circular(18),

        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            color: Colors.black.withValues(alpha: 0.05),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          CircleAvatar(
            backgroundColor: cor,

            child: Icon(icone, color: Colors.white),
          ),

          const SizedBox(height: 14),

          Text(
            titulo,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            valor,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
        color: temaEscuro ? const Color(0xFF143A60) : Colors.white,
        borderRadius: BorderRadius.circular(16),

        boxShadow: [
          BoxShadow(blurRadius: 8, color: Colors.black.withValues(alpha: 0.04)),
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
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                livros,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),

          Text(
            valor,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }
}
