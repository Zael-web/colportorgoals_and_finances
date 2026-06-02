import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/app_data.dart';

class MetasScreen extends StatefulWidget {
  const MetasScreen({super.key});

  @override
  State<MetasScreen> createState() => _MetasScreenState();
}

class _MetasScreenState extends State<MetasScreen> {

  final TextEditingController metaController =
      TextEditingController();

  double metaBolsa = 18000;

  @override
  void initState() {
    super.initState();
    carregarMeta();
  }

  Future<void> salvarMeta() async {

    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setDouble(
      'metaBolsa',
      metaBolsa,
    );
  }

  Future<void> carregarMeta() async {

    final prefs =
        await SharedPreferences.getInstance();

    double? metaSalva =
        prefs.getDouble('metaBolsa');

    if (metaSalva != null) {

      setState(() {
        metaBolsa = metaSalva;
        metaBolsaGlobal = metaSalva;
      });
    }
  }

  double totalVendido() {

    double total = 0;

    for (var registro in registrosGlobais) {
      total += registro.vendido;
    }

    return total;
  }

  double progresso() {

    if (metaBolsa == 0) return 0;

    return totalVendido() / metaBolsa;
  }

  double falta() {
    return metaBolsa - totalVendido();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text('Metas'),
        backgroundColor: Colors.blue,
      ),

      body: Padding(

        padding: const EdgeInsets.all(16),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            const Text(
              'Meta da Bolsa',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: metaController,
              keyboardType: TextInputType.number,

              decoration: const InputDecoration(
                labelText: 'Digite sua meta',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 50,

              child: ElevatedButton(

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),

                onPressed: () {

                  setState(() {

                    metaBolsa =
                        double.tryParse(
                              metaController.text,) ??
                            metaBolsa;
                    metaBolsaGlobal = metaBolsa;
                  });

                  salvarMeta();

                  metaController.clear();
                },

                child: const Text(
                  'Salvar Meta',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            Container(

              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: Colors.blue.shade700,
                borderRadius: BorderRadius.circular(20),
              ),

              child: Column(

                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  Text(
                    'Meta: R\$ ${metaBolsa.toStringAsFixed(2)}',

                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  LinearProgressIndicator(
                    value: progresso(),
                    minHeight: 12,
                    borderRadius:
                        BorderRadius.circular(20),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    'Vendido: R\$ ${totalVendido().toStringAsFixed(2)}',

                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    'Falta: R\$ ${falta().toStringAsFixed(2)}',

                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    '${(progresso() * 100).toStringAsFixed(1)}% concluído',

                    style: const TextStyle(
                      color: Colors.white,
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