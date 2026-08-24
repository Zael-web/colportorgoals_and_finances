import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import '../data/app_data.dart';

class MetasScreen extends StatefulWidget {
  const MetasScreen({super.key, this.onMetaChanged});

  final VoidCallback? onMetaChanged;

  @override
  State<MetasScreen> createState() => _MetasScreenState();
}

class _MetasScreenState extends State<MetasScreen> {
  final TextEditingController metaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    metaController.text = formatarMoedaSemSimbolo(metaBolsaGlobal);
  }

  @override
  void dispose() {
    metaController.dispose();
    super.dispose();
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

  double totalVendido() {
    return totalVendidoGlobal();
  }

  double progresso() {
    if (metaBolsaGlobal <= 0) {
      return 0;
    }

    double valor = totalVendido() / metaBolsaGlobal;

    if (valor > 1) {
      return 1;
    }

    return valor;
  }

  double falta() {
    double valor = metaBolsaGlobal - totalVendido();

    if (valor < 0) {
      return 0;
    }

    return valor;
  }

  @override
  Widget build(BuildContext context) {
    final temaEscuro = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Metas'),
        actions: [
          IconButton(
            onPressed: planejamentoSelecionadoId == null
                ? null
                : abrirAcoesDaMeta,
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
      body: planejamentoSelecionadoId == null
          ? const Center(child: Text('Nenhum planejamento ativo.'))
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Meta da Bolsa',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 20),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: temaEscuro
                          ? const Color(0xFF0B294D)
                          : const Color(0xFFDCECF8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Meta: ${formatarMoeda(metaBolsaGlobal)}',
                          style: TextStyle(
                            color: temaEscuro
                                ? Colors.white
                                : const Color(0xFF123B68),
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 20),

                        LinearProgressIndicator(
                          value: progresso(),
                          minHeight: 12,
                          borderRadius: BorderRadius.circular(20),
                        ),

                        const SizedBox(height: 20),

                        Text(
                          'Vendido: ${formatarMoeda(totalVendido())}',
                          style: TextStyle(
                            color: temaEscuro
                                ? Colors.white
                                : const Color(0xFF123B68),
                            fontSize: 18,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          'Falta: ${formatarMoeda(falta())}',
                          style: TextStyle(
                            color: temaEscuro
                                ? Colors.white
                                : const Color(0xFF123B68),
                            fontSize: 18,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          '${(progresso() * 100).toStringAsFixed(1)}% concluído',
                          style: TextStyle(
                            color: temaEscuro
                                ? Colors.white
                                : const Color(0xFF123B68),
                            fontSize: 18,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          'Meta diária: ${formatarMoeda(metaDiariaNecessaria())}',
                          style: TextStyle(
                            color: temaEscuro
                                ? Colors.white
                                : const Color(0xFF123B68),
                            fontSize: 18,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          'Dias restantes: ${diasRestantes()}',
                          style: TextStyle(
                            color: temaEscuro
                                ? Colors.white
                                : const Color(0xFF123B68),
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
