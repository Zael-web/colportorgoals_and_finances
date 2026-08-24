import 'package:flutter/material.dart';

import '../data/app_data.dart';
import '../models/material_model.dart';

class MateriaisScreen extends StatefulWidget {
  const MateriaisScreen({super.key});

  @override
  State<MateriaisScreen> createState() => _MateriaisScreenState();
}

class _MateriaisScreenState extends State<MateriaisScreen> {
  final TextEditingController buscaController = TextEditingController();

  String busca = '';

  @override
  void dispose() {
    buscaController.dispose();
    super.dispose();
  }

  double _parseValor(String texto) {
    final normalizado = texto.trim().contains(',')
        ? texto.trim().replaceAll('.', '').replaceAll(',', '.')
        : texto.trim();
    return double.tryParse(normalizado) ?? 0.0;
  }

  Future<void> _abrirFormulario({MaterialModel? material}) async {
    final nomeController = TextEditingController(text: material?.nome ?? '');
    final compraController = TextEditingController(
      text: material == null ? '' : formatarNumeroGlobal(material.valorCompra),
    );
    final vendaController = TextEditingController(
      text: material == null ? '' : formatarNumeroGlobal(material.valorVenda),
    );
    final formKey = GlobalKey<FormState>();

    try {
      final confirmou = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text(material == null ? 'Novo material' : 'Editar material'),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nomeController,
                      decoration: const InputDecoration(
                        labelText: 'Nome',
                        border: OutlineInputBorder(),
                      ),
                      textCapitalization: TextCapitalization.words,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Informe o nome do material';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: compraController,
                      decoration: const InputDecoration(
                        labelText: 'Valor de compra',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (value) {
                        if (_parseValor(value ?? '') <= 0) {
                          return 'Informe um valor válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: vendaController,
                      decoration: const InputDecoration(
                        labelText: 'Valor de venda',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (value) {
                        if (_parseValor(value ?? '') <= 0) {
                          return 'Informe um valor válido';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () {
                  if (formKey.currentState?.validate() ?? false) {
                    Navigator.of(dialogContext).pop(true);
                  }
                },
                child: const Text('Salvar'),
              ),
            ],
          );
        },
      );

      if (confirmou != true) {
        return;
      }

      final materialSalvo = MaterialModel(
        id: material?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
        nome: nomeController.text.trim(),
        valorCompra: _parseValor(compraController.text),
        valorVenda: _parseValor(vendaController.text),
      );

      if (material == null) {
        materiaisGlobais.add(materialSalvo);
      } else {
        final index = material.id == null
            ? materiaisGlobais.indexOf(material)
            : materiaisGlobais.indexWhere(
                (item) => item.id == materialSalvo.id,
              );
        if (index != -1) {
          materiaisGlobais[index] = materialSalvo;
        }
      }
      await salvarMateriaisGlobais();

      if (!mounted) {
        return;
      }

      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            material == null
                ? 'Material adicionado com sucesso'
                : 'Material atualizado com sucesso',
          ),
        ),
      );
    } finally {
      nomeController.dispose();
      compraController.dispose();
      vendaController.dispose();
    }
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

    if (confirmou != true || material.id == null) {
      return;
    }

    materiaisGlobais.removeWhere((item) => item.id == material.id);
    await salvarMateriaisGlobais();

    if (!mounted) {
      return;
    }

    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Material excluído com sucesso')),
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
