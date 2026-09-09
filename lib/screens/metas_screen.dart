import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import '../data/app_data.dart';

class MetasScreen extends StatefulWidget {
  const MetasScreen({
    super.key,
    this.onMetaChanged,
    required this.modoEscuro,
    required this.onAlternarTema,
  });

  final VoidCallback? onMetaChanged;
  final bool modoEscuro;
  final VoidCallback onAlternarTema;

  @override
  State<MetasScreen> createState() => _MetasScreenState();
}

class _MetasScreenState extends State<MetasScreen> {
  final TextEditingController metaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    metaController.text = formatarMoedaSemSimbolo(metaBolsaGlobal);
    dadosGlobaisVersion.addListener(_atualizarDados);
  }

  @override
  void dispose() {
    dadosGlobaisVersion.removeListener(_atualizarDados);
    metaController.dispose();
    super.dispose();
  }

  void _atualizarDados() {
    if (mounted) {
      setState(() {});
    }
  }

  String formatarMoeda(double valor) {
    return NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$ ').format(valor);
  }

  String formatarMoedaSemSimbolo(double valor) {
    return NumberFormat.decimalPattern('pt_BR').format(valor);
  }

  Future<void> abrirAcoesDaMeta() async {
    metaController.text = formatarMoedaSemSimbolo(metaBolsaGlobal);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar Meta da Bolsa'),
          content: TextField(
            controller: metaController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              CurrencyInputFormatter(
                thousandSeparator: ThousandSeparator.Period,
                mantissaLength: 0, // sem centavos
              ),
            ],
            decoration: const InputDecoration(
              labelText: 'Novo valor da meta',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),

            OutlinedButton(
              onPressed: () async {
                await excluirPlanejamento();

                if (!mounted || !context.mounted) return;

                setState(() {
                  metaController.text = formatarMoedaSemSimbolo(
                    metaBolsaGlobal,
                  );
                });

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Planejamento resetado!')),
                );
              },
              child: const Text('Excluir'),
            ),

            ElevatedButton(
              onPressed: () async {
                final texto = metaController.text.replaceAll('.', '');

                double? valor = double.tryParse(texto);

                if (valor == null || valor <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Digite um valor válido')),
                  );
                  return;
                }

                metaBolsaGlobal = valor;

                await salvarPlanejamento();

                if (!mounted || !context.mounted) return;

                setState(() {});

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Meta atualizada!')),
                );
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  double totalPago() {
    return totalCompradoGlobal();
  }

  double progresso() {
    if (metaBolsaGlobal <= 0) {
      return 0;
    }

    double valor = totalPago() / metaBolsaGlobal;

    if (valor > 1) {
      return 1;
    }

    return valor;
  }

  double falta() {
    double valor = metaBolsaGlobal - totalPago();

    if (valor < 0) {
      return 0;
    }

    return valor;
  }

  @override
  Widget build(BuildContext context) {
    final temaEscuro = Theme.of(context).brightness == Brightness.dark;
    final corCard = temaEscuro
        ? const Color(0xFF0B294D)
        : const Color(0xFFDCECF8);
    final corTexto = temaEscuro ? Colors.white : const Color(0xFF123B68);

    final cardsResumo = [
      _ResumoItem(
        titulo: 'Pago',
        valor: formatarMoeda(totalPago()),
        icone: Icons.payments,
        cor: Colors.green,
      ),
      _ResumoItem(
        titulo: 'Falta',
        valor: formatarMoeda(falta()),
        icone: Icons.trending_down,
        cor: Colors.orange,
      ),
      _ResumoItem(
        titulo: 'Conclusão',
        valor: '${(progresso() * 100).toStringAsFixed(1)}%',
        icone: Icons.rocket_launch,
        cor: Colors.blue,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Metas'),
        actions: [
          IconButton(
            onPressed: planejamentoSelecionadoId == null
                ? null
                : abrirAcoesDaMeta,
            icon: const Icon(Icons.edit),
            tooltip: 'Editar meta',
          ),
        ],
      ),
      body: planejamentoSelecionadoId == null
          ? Center(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.flag_outlined,
                        size: 48,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Nenhum planejamento ativo.',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            )
          : SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 760;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Card(
                          clipBehavior: Clip.antiAlias,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: temaEscuro
                                    ? const [
                                        Color(0xFF0B294D),
                                        Color(0xFF133F6B),
                                      ]
                                    : const [
                                        Color(0xFFDCECF8),
                                        Color(0xFFF6FBFF),
                                      ],
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Meta da Bolsa',
                                      style: TextStyle(
                                        color: corTexto.withValues(alpha: 0.75),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Icon(
                                      Icons.emoji_events,
                                      color: corTexto,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  formatarMoeda(metaBolsaGlobal),
                                  style: TextStyle(
                                    color: corTexto,
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 18),
                                LinearProgressIndicator(
                                  value: progresso(),
                                  minHeight: 12,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${(progresso() * 100).toStringAsFixed(1)}% concluído',
                                      style: TextStyle(
                                        color: corTexto,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      'Meta ativa',
                                      style: TextStyle(
                                        color: corTexto.withValues(alpha: 0.75),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          child: Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: cardsResumo.map((item) {
                              return SizedBox(
                                width: isWide ? 220 : double.infinity,
                                child: Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 42,
                                          height: 42,
                                          decoration: BoxDecoration(
                                            color: item.cor.withValues(alpha: 0.12),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Icon(
                                            item.icone,
                                            color: item.cor,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.titulo,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .labelMedium,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                item.valor,
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Detalhes da campanha',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 12),
                                _InfoLinha(
                                  icon: Icons.inventory_2,
                                  label: 'Pago (material + dízimo)',
                                  valor: formatarMoeda(totalPago()),
                                ),
                                const Divider(),
                                _InfoLinha(
                                  icon: Icons.trending_up,
                                  label: 'Falta para atingir a meta',
                                  valor: formatarMoeda(falta()),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }
}

class _ResumoItem {
  const _ResumoItem({
    required this.titulo,
    required this.valor,
    required this.icone,
    required this.cor,
  });

  final String titulo;
  final String valor;
  final IconData icone;
  final Color cor;
}

class _InfoLinha extends StatelessWidget {
  const _InfoLinha({
    required this.icon,
    required this.label,
    required this.valor,
  });

  final IconData icon;
  final String label;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            valor,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
