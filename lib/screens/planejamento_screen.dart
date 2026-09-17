import 'package:flutter/material.dart';

import '../data/app_data.dart';
import '../models/campanha.dart';

class PlanejamentoScreen extends StatefulWidget {
  const PlanejamentoScreen({super.key, this.onMetaChanged});

  final VoidCallback? onMetaChanged;

  @override
  State<PlanejamentoScreen> createState() => _PlanejamentoScreenState();
}

class _PlanejamentoScreenState extends State<PlanejamentoScreen> {
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

  String formatarData(DateTime data) =>
      '${data.day}/${data.month}/${data.year}';

  Future<void> abrirEditor([Planejamento? planejamento]) async {
    final temaEscuro = Theme.of(context).brightness == Brightness.dark;
    final corAcao = temaEscuro
        ? const Color(0xFF4DA3FF)
        : const Color(0xFF1769AA);
    final corTextoAcao = temaEscuro ? const Color(0xFF071826) : Colors.white;
    final nomeController = TextEditingController(
      text: planejamento?.nome ?? '',
    );
    final metaController = TextEditingController(
      text: planejamento == null
          ? ''
          : formatarNumeroGlobal(planejamento.meta, casas: 0),
    );
    final diasController = TextEditingController(
      text: planejamento?.quantidadeDias.toString() ?? '',
    );
    var dataInicio = planejamento?.dataInicio ?? DateTime.now();
    var feriados = [...?planejamento?.feriados];
    var dataFim = planejamento?.dataFim ?? dataInicio;

    final resultado = await showDialog<Planejamento>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: temaEscuro
              ? const Color(0xFF102D4D)
              : const Color(0xFFF5FAFE),
          title: Text(
            planejamento == null ? 'Novo planejamento' : 'Editar planejamento',
            style: TextStyle(
              color: temaEscuro ? Colors.white : const Color(0xFF123B68),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nomeController,
                  autofocus: planejamento == null,
                  decoration: InputDecoration(
                    labelText: 'Nome',
                    labelStyle: TextStyle(
                      color: temaEscuro
                          ? Colors.white70
                          : const Color(0xFF35607F),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: metaController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Meta da bolsa',
                    labelStyle: TextStyle(
                      color: temaEscuro
                          ? Colors.white70
                          : const Color(0xFF35607F),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: diasController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Quantidade de dias úteis',
                    helperText: 'Sábados, domingos e feriados serão ignorados.',
                    helperMaxLines: 2,
                  ),
                  onChanged: (_) => setDialogState(() {
                    dataFim = Planejamento.calcularDataFim(
                      dataInicio: dataInicio,
                      quantidadeDias: int.tryParse(diasController.text) ?? 0,
                      feriados: feriados,
                    );
                  }),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Feriados',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                ...feriados.map(
                  (feriado) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    title: Text(formatarData(feriado)),
                    trailing: TextButton(
                      onPressed: () => setDialogState(() {
                        feriados.remove(feriado);
                        dataFim = Planejamento.calcularDataFim(
                          dataInicio: dataInicio,
                          quantidadeDias: int.tryParse(diasController.text) ?? 0,
                          feriados: feriados,
                        );
                      }),
                      child: const Text('Remover'),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final feriado = await showDatePicker(
                      context: context,
                      initialDate: dataInicio,
                      firstDate: DateTime(2024),
                      lastDate: DateTime(2035),
                    );
                    if (feriado != null &&
                        !feriados.any((item) =>
                            item.year == feriado.year &&
                            item.month == feriado.month &&
                            item.day == feriado.day)) {
                      setDialogState(() {
                        feriados.add(feriado);
                        dataFim = Planejamento.calcularDataFim(
                          dataInicio: dataInicio,
                          quantidadeDias: int.tryParse(diasController.text) ?? 0,
                          feriados: feriados,
                        );
                      });
                    }
                  },
                  child: const Text('Adicionar feriado'),
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Data de início',
                    style: TextStyle(
                      color: temaEscuro
                          ? Colors.white
                          : const Color(0xFF123B68),
                    ),
                  ),
                  subtitle: Text(
                    formatarData(dataInicio),
                    style: TextStyle(
                      color: temaEscuro
                          ? Colors.white70
                          : const Color(0xFF35607F),
                    ),
                  ),
                  onTap: () async {
                    final data = await showDatePicker(
                      context: context,
                      initialDate: dataInicio,
                      firstDate: DateTime(2024),
                      lastDate: DateTime(2035),
                    );
                    if (data != null) {
                      setDialogState(() {
                        dataInicio = data;
                        dataFim = Planejamento.calcularDataFim(
                          dataInicio: dataInicio,
                          quantidadeDias: int.tryParse(diasController.text) ?? 0,
                          feriados: feriados,
                        );
                      });
                    }
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Data final',
                    style: TextStyle(
                      color: temaEscuro
                          ? Colors.white
                          : const Color(0xFF123B68),
                    ),
                  ),
                  subtitle: Text(
                    formatarData(dataFim),
                    style: TextStyle(
                      color: temaEscuro
                          ? Colors.white70
                          : const Color(0xFF35607F),
                    ),
                  ),
                  onTap: () async {
                    final data = await showDatePicker(
                      context: context,
                      initialDate: dataFim,
                      firstDate: dataInicio,
                      lastDate: DateTime(2035),
                    );
                    if (data != null) {
                      setDialogState(() {
                        dataFim = data;
                        diasController.text = Planejamento
                            .calcularQuantidadeDias(
                              dataInicio: dataInicio,
                              dataFim: dataFim,
                              feriados: feriados,
                            )
                            .toString();
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: corAcao,
                foregroundColor: corTextoAcao,
              ),
              onPressed: () {
                final textoMeta = metaController.text.trim();
                final textoNormalizado = textoMeta
                  .replaceAll('.', '')
                  .replaceAll(',', '.');
                final meta = double.tryParse(textoNormalizado);
                final quantidadeDias = int.tryParse(diasController.text.trim());
                final nome = nomeController.text.trim();
                if (nome.isEmpty ||
                    meta == null ||
                    meta <= 0 ||
                  quantidadeDias == null ||
                  quantidadeDias <= 0 ||
                    dataFim.isBefore(dataInicio)) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Preencha o nome, uma meta válida e um período correto.',
                      ),
                    ),
                  );
                  return;
                }
                Navigator.pop(
                  dialogContext,
                  Planejamento(
                    id:
                        planejamento?.id ??
                        DateTime.now().microsecondsSinceEpoch.toString(),
                    nome: nome,
                    meta: meta,
                    dataInicio: dataInicio,
                    dataFim: dataFim,
                    quantidadeDias: quantidadeDias,
                    feriados: feriados,
                  ),
                );
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );

    nomeController.dispose();
    metaController.dispose();
    diasController.dispose();
    if (resultado == null) return;

    try {
      await salvarOuAtualizarPlanejamento(resultado);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível salvar o planejamento.'),
        ),
      );
      return;
    }
    if (!mounted) return;
    setState(() {});
    widget.onMetaChanged?.call();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          planejamento == null
              ? 'Planejamento adicionado!'
              : 'Planejamento atualizado!',
        ),
      ),
    );
  }

  Future<void> excluir(Planejamento planejamento) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir planejamento?'),
        content: Text('O planejamento "${planejamento.nome}" será removido.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmou != true) return;

    await excluirPlanejamentoPorId(planejamento.id);
    if (!mounted) return;
    setState(() {});
    widget.onMetaChanged?.call();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Planejamento excluído!')));
  }

  Widget resumo(String titulo, String valor, IconData icone, Color cor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: cor,
          child: Icon(icone, color: Colors.white),
        ),
        title: Text(titulo),
        subtitle: Text(
          valor,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final temaEscuro = Theme.of(context).brightness == Brightness.dark;
    final corAcao = temaEscuro
        ? const Color(0xFF4DA3FF)
        : const Color(0xFF1769AA);
    final corTextoAcao = temaEscuro ? const Color(0xFF071826) : Colors.white;
    final selecionado = planejamentosGlobais
        .where((item) => item.id == planejamentoSelecionadoId)
        .firstOrNull;
    final falta = (metaBolsaGlobal - totalCompradoGlobal()).clamp(
      0,
      double.infinity,
    );
    final quantidadeDiasRestantes = diasRestantes();
    final progresso = metaBolsaGlobal == 0
        ? 0.0
        : (totalCompradoGlobal() / metaBolsaGlobal).clamp(0.0, 1.0);

    final cardsResumo = [
      _ResumoItemPlanejamento(
        titulo: 'Meta',
        valor: formatarMoedaGlobal(metaBolsaGlobal),
        icone: Icons.flag,
        cor: Colors.blue,
      ),
      _ResumoItemPlanejamento(
        titulo: 'Meta diária',
        valor: formatarMoedaGlobal(metaDiariaNecessaria()),
        icone: Icons.today,
        cor: Colors.orange,
      ),
      _ResumoItemPlanejamento(
        titulo: 'Falta',
        valor: formatarMoedaGlobal(falta.toDouble()),
        icone: Icons.trending_up,
        cor: Colors.red,
      ),
      _ResumoItemPlanejamento(
        titulo: 'Dias',
        valor: '$quantidadeDiasRestantes dias',
        icone: Icons.calendar_month,
        cor: Colors.purple,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Planejamentos'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: corAcao,
                      foregroundColor: corTextoAcao,
                      minimumSize: const Size.fromHeight(52),
                    ),
                    onPressed: () => abrirEditor(),
                    icon: const Icon(Icons.add),
                    label: const Text('Adicionar planejamento'),
                  ),
                  const SizedBox(height: 16),
                  ...planejamentosGlobais.map(
                    (planejamento) => Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        selected: planejamento.id == planejamentoSelecionadoId,
                        leading: CircleAvatar(
                          backgroundColor: planejamento.id == planejamentoSelecionadoId
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                          child: Icon(
                            planejamento.id == planejamentoSelecionadoId
                                ? Icons.radio_button_checked
                                : Icons.radio_button_off,
                            color: planejamento.id == planejamentoSelecionadoId
                                ? Colors.white
                                : Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        title: Text(planejamento.nome),
                        subtitle: Text(
                          '${formatarMoedaGlobal(planejamento.meta)} | ${planejamento.quantidadeDias} dias úteis | ${formatarData(planejamento.dataInicio)} a ${formatarData(planejamento.dataFim)}',
                        ),
                        onTap: () async {
                          await selecionarPlanejamento(planejamento.id);
                          if (!mounted) return;
                          setState(() {});
                          widget.onMetaChanged?.call();
                        },
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'Editar',
                              onPressed: () => abrirEditor(planejamento),
                              icon: const Icon(Icons.edit),
                            ),
                            IconButton(
                              tooltip: 'Excluir',
                              onPressed: () => excluir(planejamento),
                              icon: const Icon(Icons.delete, color: Colors.redAccent),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (selecionado != null) ...[
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: temaEscuro
                              ? const [Color(0xFF0B294D), Color(0xFF123F6C)]
                              : const [Color(0xFFDCECF8), Color(0xFFF5FAFF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
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
                            'Resumo: ${selecionado.nome}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: temaEscuro ? Colors.white : const Color(0xFF123B68),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 12,
                            runSpacing: 12,
                            children: cardsResumo.map((item) {
                              return SizedBox(
                                width: 180,
                                height: 100,
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: temaEscuro
                                        ? const Color(0xFF102D45)
                                        : const Color(0xFFF6FBFF),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: temaEscuro
                                          ? Colors.white12
                                          : Colors.blueGrey.shade100,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 38,
                                        height: 38,
                                        decoration: BoxDecoration(
                                          color: item.cor.withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          item.icone,
                                          color: item.cor,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              item.titulo,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: temaEscuro
                                                    ? Colors.white70
                                                    : const Color(0xFF35607F),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              item.valor,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: temaEscuro
                                                    ? Colors.white
                                                    : const Color(0xFF123B68),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 18),
                          LinearProgressIndicator(
                            value: progresso,
                            minHeight: 12,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '${(progresso * 100).toStringAsFixed(1)}% concluído',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: temaEscuro ? Colors.white : const Color(0xFF123B68),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ResumoItemPlanejamento {
  const _ResumoItemPlanejamento({
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
