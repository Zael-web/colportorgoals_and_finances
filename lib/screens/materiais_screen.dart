import 'dart:async';

import 'package:flutter/material.dart';

import '../data/app_data.dart';
import '../models/material_model.dart';
import '../services/firestore_service.dart';

class MateriaisScreen extends StatefulWidget {
  const MateriaisScreen({super.key});

  @override
  State<MateriaisScreen> createState() => _MateriaisScreenState();
}

class _MateriaisScreenState extends State<MateriaisScreen> {
  final TextEditingController buscaController = TextEditingController();
  final _firestoreService = FirestoreService();

  String busca = '';

  Future<bool> _sincronizarComFirestore(Future<void> operacao) async {
    try {
      await operacao.timeout(const Duration(seconds: 8));
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  void dispose() {
    buscaController.dispose();
    super.dispose();
  }

  Future<void> _abrirFormulario({MaterialModel? material}) async {
    final materialSalvo = await showDialog<MaterialModel>(
      context: context,
      builder: (_) => _MaterialFormDialog(material: material),
    );

    if (materialSalvo == null || !mounted) return;

    String? mensagemErro;
    var materialConfirmado = materialSalvo;

    try {
      if (material == null) {
        final id = await _firestoreService.adicionarMaterial(materialSalvo);
        materialConfirmado = materialSalvo.copyWith(id: id);
        materiaisGlobais.add(materialConfirmado);
      } else {
        await _firestoreService.atualizarMaterial(materialSalvo);
        final index = materiaisGlobais.indexWhere(
          (item) => item.id == materialSalvo.id,
        );
        if (index != -1) materiaisGlobais[index] = materialSalvo;
      }
      await salvarMateriaisGlobais();
    } catch (erro) {
      mensagemErro = _firestoreService.mensagemDeErro(erro);
    }

    if (!mounted) return;
    setState(() {});
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          mensagemErro == null
              ? (material == null
                    ? 'Material adicionado no Firebase'
                    : 'Material atualizado no Firebase')
              : 'Erro ao salvar no Firebase: $mensagemErro',
        ),
      ),
    );
  }

  Future<void> _confirmarExclusao(MaterialModel material) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Excluir material'),
          content: Text('Deseja excluir "${material.nome}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton.tonal(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (confirmou != true) {
      return;
    }

    materiaisGlobais.removeWhere((item) => item == material);
    await salvarMateriaisGlobais();

    if (!mounted) {
      return;
    }

    setState(() {});
    final sincronizado = await _sincronizarComFirestore(
      _firestoreService.excluirMaterial(material),
    );
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          sincronizado
              ? 'Material excluído com sucesso'
              : 'Material excluído neste dispositivo. Sincronização pendente.',
        ),
      ),
    );
  }

  Widget _materialCard(MaterialModel material) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.blue,
          child: Icon(Icons.menu_book, color: Colors.white),
        ),
        title: Text(
          material.nome,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Compra: ${formatarMoedaGlobal(material.valorCompra)}'),
              Text('Venda: ${formatarMoedaGlobal(material.valorVenda)}'),
            ],
          ),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'editar') {
              _abrirFormulario(material: material);
            }

            if (value == 'excluir') {
              _confirmarExclusao(material);
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(value: 'editar', child: Text('Editar')),
            PopupMenuItem(value: 'excluir', child: Text('Excluir')),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Materiais'),
        actions: [
          IconButton(
            onPressed: () => _abrirFormulario(),
            icon: const Icon(Icons.add),
            tooltip: 'Adicionar material',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(),
        icon: const Icon(Icons.add),
        label: const Text('Novo material'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: buscaController,
              decoration: InputDecoration(
                labelText: 'Pesquisar material',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: busca.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          buscaController.clear();
                          setState(() {
                            busca = '';
                          });
                        },
                        icon: const Icon(Icons.clear),
                      ),
                border: const OutlineInputBorder(),
              ),
              onChanged: (valor) {
                setState(() {
                  busca = valor;
                });
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Builder(
                builder: (context) {
                  final materiaisFiltrados = materiaisGlobais.where((material) {
                    return material.nome.toLowerCase().contains(
                      busca.toLowerCase(),
                    );
                  }).toList();

                  if (materiaisFiltrados.isEmpty) {
                    return Center(
                      child: Text(
                        busca.isEmpty
                            ? 'Nenhum material cadastrado.'
                            : 'Nenhum material encontrado para "$busca".',
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: materiaisFiltrados.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _materialCard(materiaisFiltrados[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MaterialFormDialog extends StatefulWidget {
  const _MaterialFormDialog({this.material});

  final MaterialModel? material;

  @override
  State<_MaterialFormDialog> createState() => _MaterialFormDialogState();
}

class _MaterialFormDialogState extends State<_MaterialFormDialog> {
  late final TextEditingController _nomeController;
  late final TextEditingController _compraController;
  late final TextEditingController _vendaController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final material = widget.material;
    _nomeController = TextEditingController(text: material?.nome ?? '');
    _compraController = TextEditingController(
      text: material == null ? '' : formatarNumeroGlobal(material.valorCompra),
    );
    _vendaController = TextEditingController(
      text: material == null ? '' : formatarNumeroGlobal(material.valorVenda),
    );
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _compraController.dispose();
    _vendaController.dispose();
    super.dispose();
  }

  double _parseValor(String texto) {
    final normalizado = texto.trim().contains(',')
        ? texto.trim().replaceAll('.', '').replaceAll(',', '.')
        : texto.trim();
    return double.tryParse(normalizado) ?? 0.0;
  }

  void _salvar() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final material = widget.material;
    Navigator.of(context).pop(
      MaterialModel(
        id: material?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
        nome: _nomeController.text.trim(),
        valorCompra: _parseValor(_compraController.text),
        valorVenda: _parseValor(_vendaController.text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.material == null ? 'Novo material' : 'Editar material',
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Informe o nome do material'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _compraController,
                decoration: const InputDecoration(
                  labelText: 'Valor de compra',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) => _parseValor(value ?? '') <= 0
                    ? 'Informe um valor válido'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _vendaController,
                decoration: const InputDecoration(
                  labelText: 'Valor de venda',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) => _parseValor(value ?? '') <= 0
                    ? 'Informe um valor válido'
                    : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _salvar, child: const Text('Salvar')),
      ],
    );
  }
}
