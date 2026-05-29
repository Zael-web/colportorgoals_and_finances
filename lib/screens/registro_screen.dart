import 'package:flutter/material.dart';
import '../models/registro.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';


class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  
  List<Registro> registros = [];

  Future<void> salvarNoCelular() async {
    final  prefs = await SharedPreferences.getInstance();

    List<String> lista =
       registros.map((r) => jsonEncode(r.toMap())).toList();

       await prefs.setStringList('registros', lista);
  }

  Future<void> carregarRegistros() async {
  final prefs = await SharedPreferences.getInstance();

  List<String>? lista = prefs.getStringList('registros');

  if (lista != null) {
    setState(() {
      registros = lista
          .map(
            (item) => Registro.fromMap(
              jsonDecode(item),
            ),
          )
          .toList();
    });
  }
}


@override
void initState() {
  super.initState();
  carregarRegistros();
}

  final TextEditingController vendidoController =
      TextEditingController();

  final TextEditingController compradoController =
      TextEditingController();

  final TextEditingController quantidadeController =
      TextEditingController();

  final TextEditingController observacaoController =
      TextEditingController();

  void salvarRegistro() {
    double vendido =
        double.tryParse(vendidoController.text) ?? 0;

    double comprado =
        double.tryParse(compradoController.text) ?? 0;

    int quantidade =
        int.tryParse(quantidadeController.text) ?? 0;

    String observacao = observacaoController.text;

    if (vendido == 0 && comprado == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Informe ao menos um valor!',
          ),
        ),
      );
      return;
    }

    setState(() {
      registros.add(
        Registro(
        vendido: vendido,
        comprado: comprado,
        quantidade: quantidade,
        observacao: observacao,
        data: DateTime.now(),
        ),
      );
    });
    salvarNoCelular();

    vendidoController.clear();
    compradoController.clear();
    quantidadeController.clear();
    observacaoController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Registro salvo com sucesso!'),
      ),
    );
  }

  String formatarMoeda(double valor) {
    return 'R\$ ${valor.toStringAsFixed(2)}';
  }

  @override
   void dispose() {
    vendidoController.dispose();
    compradoController.dispose();
    quantidadeController.dispose();
    observacaoController.dispose();
    super.dispose();
  }

  @override
  Widget build (BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro Diário'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  TextField(
                    controller: vendidoController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Valor Vendido',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextField(
                    controller: compradoController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Valor Comprado',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextField(
                    controller: quantidadeController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Quantidade de Livros',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextField(
                    controller: observacaoController,
                    decoration: const InputDecoration(
                      labelText: 'Observação',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: salvarRegistro,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: const Text(
                        'Salvar Registro',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Registros Salvos',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  if (registros.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          'Nenhum registro ainda',
                        ),
                      ),
                    ),

                  ...registros.reversed.map((registro) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.green,
                          child: Icon(
                            Icons.book,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          'Venda: ${formatarMoeda(registro.vendido)}',
                        ),
                        subtitle: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Compra: ${formatarMoeda(registro.comprado)}',
                            ),
                            Text(
                              'Livros: ${registro.quantidade}',
                            ),
                            if (registro.observacao.isNotEmpty)
                              Text(
                                'Obs: ${registro.observacao}',
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
                              registros.remove(registro);
                            });
                            salvarNoCelular();
                          },
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}