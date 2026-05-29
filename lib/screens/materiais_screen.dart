import 'package:flutter/material.dart';
import '../models/material_model.dart';


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

  List<MaterialModel> materiais = [];

  void adicionarMaterial() {

    String nome = nomeController.text;

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

      materiais.add(
        MaterialModel(
          nome: nome,
          valorCompra: compra,
          valorVenda: venda,
        ),
      );
    });

    nomeController.clear();
    compraController.clear();
    vendaController.clear();
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

                child: const Text(
                  'Adicionar Material',
                  style: TextStyle(
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

              child: materiais.isEmpty

                  ? const Center(
                      child: Text(
                        'Nenhum material cadastrado',
                      ),
                    )

                  : ListView.builder(

                      itemCount: materiais.length,

                      itemBuilder: (context, index) {

                        final material =
                            materiais[index];

                        return Card(

                          margin:
                              const EdgeInsets.only(
                            bottom: 12,
                          ),

                          child: ListTile(

                            leading: const CircleAvatar(
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

                            trailing: IconButton(

                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),

                              onPressed: () {

                                setState(() {

                                  materiais.removeAt(
                                    index,
                                  );
                                });
                              },
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