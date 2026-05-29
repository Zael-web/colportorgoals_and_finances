import 'package:flutter/material.dart';
import '../data/app_data.dart';

class PlanejamentoScreen extends StatefulWidget {
  const PlanejamentoScreen({super.key});

  @override
  State<PlanejamentoScreen> createState() =>
      _PlanejamentoScreenState();
}

class _PlanejamentoScreenState
    extends State<PlanejamentoScreen> {

  final TextEditingController metaController =
      TextEditingController();

  double metaBolsa = 18000;

  DateTime dataInicio = DateTime.now();

  DateTime dataFim =
      DateTime.now().add(const Duration(days: 30));

  double totalComprado() {

    double total = 0;

    for (var registro in registrosGlobais) {
      total += registro.comprado;
    }

    return total;
  }

  double quantoFalta() {

    double falta =
        metaBolsa - totalComprado();

    if (falta < 0) {
      return 0;
    }

    return falta;
  }

  int diasRestantes() {

    final hoje = DateTime.now();

    int dias =
        dataFim.difference(hoje).inDays;

    if (dias <= 0) {
      return 1;
    }

    return dias;
  }

  double mediaNecessaria() {

    return quantoFalta() /
        diasRestantes();
  }

  double progresso() {

    if (metaBolsa == 0) return 0;

    return totalComprado() / metaBolsa;
  }

  Future<void> selecionarDataInicio() async {

    DateTime? data = await showDatePicker(
      context: context,
      initialDate: dataInicio,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );

    if (data != null) {
      setState(() {
        dataInicio = data;
      });
    }
  }

  Future<void> selecionarDataFim() async {

    DateTime? data = await showDatePicker(
      context: context,
      initialDate: dataFim,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );

    if (data != null) {
      setState(() {
        dataFim = data;
      });
    }
  }

  Widget infoCard({
    required String titulo,
    required String valor,
    required IconData icone,
    required Color cor,
  }) {

    return Container(

      margin: const EdgeInsets.only(bottom: 16),

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),

        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            color: Colors.black.withOpacity(0.05),
          )
        ],
      ),

      child: Row(

        children: [

          CircleAvatar(
            backgroundColor: cor,
            radius: 28,

            child: Icon(
              icone,
              color: Colors.white,
            ),
          ),

          const SizedBox(width: 16),

          Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              Text(
                titulo,
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                valor,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          'Planejamento da Bolsa',
        ),
        backgroundColor: Colors.green,
      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(16),

        child: Column(

          children: [

            TextField(
              controller: metaController,
              keyboardType: TextInputType.number,

              decoration: const InputDecoration(
                labelText: 'Meta da Bolsa',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),

                onPressed: () {

                  setState(() {

                    metaBolsa =
                        double.tryParse(
                              metaController.text,
                            ) ??
                            metaBolsa;
                  });
                },

                child: const Text(
                  'Salvar Meta',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(

                onPressed: selecionarDataInicio,

                child: Text(
                  'Data Início: '
                  '${dataInicio.day}/${dataInicio.month}/${dataInicio.year}',
                ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(

                onPressed: selecionarDataFim,

                child: Text(
                  'Data Final: '
                  '${dataFim.day}/${dataFim.month}/${dataFim.year}',
                ),
              ),
            ),

            const SizedBox(height: 24),

            infoCard(
              titulo: 'Meta da Bolsa',
              valor:
                  'R\$ ${metaBolsa.toStringAsFixed(2)}',
              icone: Icons.flag,
              cor: Colors.green,
            ),

            infoCard(
              titulo: 'Total Comprado',
              valor:
                  'R\$ ${totalComprado().toStringAsFixed(2)}',
              icone: Icons.shopping_cart,
              cor: Colors.orange,
            ),

            infoCard(
              titulo: 'Quanto Falta',
              valor:
                  'R\$ ${quantoFalta().toStringAsFixed(2)}',
              icone: Icons.trending_up,
              cor: Colors.red,
            ),

            infoCard(
              titulo: 'Dias Restantes',
              valor: '${diasRestantes()} dias',
              icone: Icons.calendar_month,
              cor: Colors.blue,
            ),

            infoCard(
              titulo: 'Média Necessária/Dia',
              valor:
                  'R\$ ${mediaNecessaria().toStringAsFixed(2)}',
              icone: Icons.calculate,
              cor: Colors.purple,
            ),

            const SizedBox(height: 20),

            LinearProgressIndicator(
              value: progresso(),
              minHeight: 14,
              borderRadius:
                  BorderRadius.circular(20),
            ),

            const SizedBox(height: 12),

            Text(
              '${(progresso() * 100).toStringAsFixed(1)}% concluído',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}