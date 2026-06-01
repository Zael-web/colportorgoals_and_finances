import 'package:flutter/material.dart';
import '../models/material_model.dart';
import '../data/app_data.dart';

class MateriaisScreen extends StatefulWidget {
  const MateriaisScreen({super.key});

  @override
  State<MateriaisScreen> createState() =>
      _MateriaisScreenState();
}

class _MateriaisScreenState
    extends State<MateriaisScreen> {

  final TextEditingController nomeController =
      TextEditingController();

  final TextEditingController compraController =
      TextEditingController();

  final TextEditingController vendaController =
      TextEditingController();

  int? editandoIndex;

  @override
  void initState() {
    super.initState();
    carregar();
  }

  Future<void> carregar() async {
    await carregarMateriaisGlobais();
    setState(() {});
  }

  void adicionarMaterial() async {

    String nome = nomeController.text.trim();

    double compra =
        double.tryParse(compraController.text) ?? 0;

    double venda =
        double.tryParse(vendaController.text) ?? 0;

    if (nome.isEmpty || compra == 0 || venda == 0) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Preencha todos os campos',
          ),
        ),
      );

      return;
    }

    setState(() {

      if (editandoIndex != null) {

        materiaisGlobais[editandoIndex!] =
            MaterialModel(
          nome: nome,
          valorCompra: compra,
          valorVenda: venda,
        );

        editandoIndex = null;

      } else {

        materiaisGlobais.add(
          MaterialModel(
            nome: nome,
            valorCompra: compra,
            valorVenda: venda,
          ),
        );
      }
    });

    await salvarMateriaisGlobais();

    nomeController.clear();
    compraController.clear();
    vendaController.clear();
  }

  void editarMaterial(int index) {

    final material =
        materiaisGlobais[index];

    nomeController.text =
        material.nome;

    compraController.text =
        material.valorCompra.toString();

    vendaController.text =
        material.valorVenda.toString();

    editandoIndex = index;

    setState(() {});
  }

  Future<void> excluirMaterial(
      int index) async {

    setState(() {
      materiaisGlobais.removeAt(index);
    });

    await salvarMateriaisGlobais();
  }

  @override
  void dispose() {

    nomeController.dispose();
    compraController.dispose();
    vendaController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text('Materiais'),
        backgroundColor: Colors.green,
      ),

      body: Padding(

        padding: const EdgeInsets.all(16),

        child: Column(

          children: [

            TextField(
              controller: nomeController,

              decoration: const InputDecoration(
                labelText: 'Nome do Material',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: compraController,
              keyboardType: TextInputType.number,

              decoration: const InputDecoration(
                labelText: 'Valor de Compra',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: vendaController,
              keyboardType: TextInputType.number,

              decoration: const InputDecoration(
                labelText: 'Valor de Venda',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 50,

              child: ElevatedButton(

                onPressed: adicionarMaterial,

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),

                child: Text(
                  editandoIndex == null
                      ? 'Adicionar Material'
                      : 'Salvar Alteração',

                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            const Align(
              alignment: Alignment.centerLeft,

              child: Text(
                'Tabela de Materiais',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 16),

            Expanded(

              child: materiaisGlobais.isEmpty

                  ? const Center(
                      child: Text(
                        'Nenhum material cadastrado',
                      ),
                    )

                  : ListView.builder(

                      itemCount:
                          materiaisGlobais.length,

                      itemBuilder:
                          (context, index) {

                        final material =
                            materiaisGlobais[index];

                        return Card(

                          margin:
                              const EdgeInsets.only(
                            bottom: 12,
                          ),

                          child: ListTile(

                            leading:
                                const CircleAvatar(
                              backgroundColor:
                                  Colors.green,

                              child: Icon(
                                Icons.menu_book,
                                color: Colors.white,
                              ),
                            ),

                            title: Text(
                              material.nome,
                            ),

                            subtitle: Column(

                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,

                              children: [

                                Text(
                                  'Compra: R\$ ${material.valorCompra.toStringAsFixed(2)}',
                                ),

                                Text(
                                  'Venda: R\$ ${material.valorVenda.toStringAsFixed(2)}',
                                ),
                              ],
                            ),

                            trailing: Row(
                              mainAxisSize:
                                  MainAxisSize.min,

                              children: [

                                IconButton(

                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                  ),

                                  onPressed: () {
                                    editarMaterial(
                                      index,
                                    );
                                  },
                                ),

                                IconButton(

                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),

                                  onPressed: () {
                                    excluirMaterial(
                                      index,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
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