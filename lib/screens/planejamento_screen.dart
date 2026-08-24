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
    var dataInicio = planejamento?.dataInicio ?? DateTime.now();
    var dataFim =
        planejamento?.dataFim ?? DateTime.now().add(const Duration(days: 30));

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
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today),
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
                      setDialogState(() => dataInicio = data);
                    }
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.event),
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
                      firstDate: DateTime(2024),
                      lastDate: DateTime(2035),
                    );
                    if (data != null) {
                      setDialogState(() => dataFim = data);
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
                final textoNormalizado = textoMeta.contains(',')
                    ? textoMeta.replaceAll('.', '').replaceAll(',', '.')
                    : textoMeta;
                final meta = double.tryParse(textoNormalizado);
                final nome = nomeController.text.trim();
                if (nome.isEmpty ||
                    meta == null ||
                    meta <= 0 ||
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
    final dias = dataFimGlobal.difference(DateTime.now()).inDays;
    final diasRestantes = dias <= 0 ? 1 : dias;
    final progresso = metaBolsaGlobal == 0
        ? 0.0
        : (totalCompradoGlobal() / metaBolsaGlobal).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(title: const Text('Planejamentos')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: corAcao,
                foregroundColor: corTextoAcao,
              ),
              onPressed: () => abrirEditor(),
              icon: const Icon(Icons.add),
              label: const Text('Adicionar planejamento'),
            ),
            const SizedBox(height: 12),
            ...planejamentosGlobais.map(
              (planejamento) => Card(
                child: ListTile(
                  selected: planejamento.id == planejamentoSelecionadoId,
                  leading: Icon(
                    planejamento.id == planejamentoSelecionadoId
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                  ),
                  title: Text(planejamento.nome),
                  subtitle: Text(
                    '${formatarMoedaGlobal(planejamento.meta)} | ${formatarData(planejamento.dataInicio)} a ${formatarData(planejamento.dataFim)}',
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
              const SizedBox(height: 20),
              Text(
                'Resumo: ${selecionado.nome}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              resumo(
                'Meta da Bolsa',
                formatarMoedaGlobal(metaBolsaGlobal),
                Icons.flag,
                Colors.blue,
              ),
              resumo(
                'Total Comprado',
                formatarMoedaGlobal(totalCompradoGlobal()),
                Icons.shopping_cart,
                Colors.orange,
              ),
              resumo(
                'Quanto Falta',
                formatarMoedaGlobal(falta.toDouble()),
                Icons.trending_up,
                Colors.red,
              ),
              resumo(
                'Dias Restantes',
                '$diasRestantes dias',
                Icons.calendar_month,
                Colors.blue,
              ),
              resumo(
                'Meta Diária',
                formatarMoedaGlobal((falta / diasRestantes).toDouble()),
                Icons.calculate,
                Colors.purple,
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(value: progresso, minHeight: 14),
              const SizedBox(height: 8),
              Text(
                '${(progresso * 100).toStringAsFixed(1)}% concluído',
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
