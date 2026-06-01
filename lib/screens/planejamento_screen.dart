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
      DateTime.now().add(
    const Duration(days: 30),
  );

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  Future<void> carregarDados() async {
    await carregarPlanejamento();

    setState(() {
      metaBolsa = metaBolsaGlobal;
      dataInicio = dataInicioGlobal;
      dataFim = dataFimGlobal;

      metaController.text =
          metaBolsa.toStringAsFixed(0);
    });
  }

  Future<void> salvarDados() async {

    metaBolsaGlobal = metaBolsa;
    dataInicioGlobal = dataInicio;
    dataFimGlobal = dataFim;

    await salvarPlanejamento();

    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          'Planejamento salvo!',
        ),
      ),
    );
  }

  double totalComprado() {
    return totalCompradoGlobal();
  }

  double quantoFalta() {
    double falta =
        metaBolsa - totalComprado();

    return falta < 0 ? 0 : falta;
  }

  int diasRestantes() {
    int dias =
        dataFim.difference(
          DateTime.now(),
        ).inDays;

    return dias <= 0 ? 1 : dias;
  }

  double mediaNecessaria() {
    return quantoFalta() /
        diasRestantes();
  }

  double progresso() {
    if (metaBolsa == 0) return 0;

    return totalComprado() /
        metaBolsa;
  }

  Future<void> selecionarDataInicio() async {

    DateTime? data =
        await showDatePicker(
      context: context,
      initialDate: dataInicio,
      firstDate: DateTime(2024),
      lastDate: DateTime(2035),
    );

    if (data != null) {
      setState(() {
        dataInicio = data;
      });

      await salvarDados();
    }
  }

  Future<void> selecionarDataFim() async {

    DateTime? data =
        await showDatePicker(
      context: context,
      initialDate: dataFim,
      firstDate: DateTime(2024),
      lastDate: DateTime(2035),
    );

    if (data != null) {
      setState(() {
        dataFim = data;
      });

      await salvarDados();
    }
  }

  Future<void> resetarPlanejamento() async {

    await excluirPlanejamento();

    setState(() {

      metaBolsa = 18000;

      dataInicio =
          DateTime.now();

      dataFim =
          DateTime.now().add(
        const Duration(days: 30),
      );

      metaController.clear();
    });
  }

  Widget infoCard({
    required String titulo,
    required String valor,
    required IconData icone,
    required Color cor,
  }) {
    return Card(
      margin:
          const EdgeInsets.only(
        bottom: 12,
      ),

      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: cor,
          child: Icon(
            icone,
            color: Colors.white,
          ),
        ),

        title: Text(titulo),

        subtitle: Text(
          valor,
          style: const TextStyle(
            fontSize: 18,
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          'Planejamento',
        ),
        backgroundColor:
            Colors.green,
      ),

      body: SingleChildScrollView(

        padding:
            const EdgeInsets.all(16),

        child: Column(

          children: [

            TextField(
              controller:
                  metaController,
              keyboardType:
                  TextInputType.number,

              decoration:
                  const InputDecoration(
                labelText:
                    'Meta da Bolsa',
                border:
                    OutlineInputBorder(),
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            SizedBox(
              width:
                  double.infinity,

              child:
                  ElevatedButton(

                onPressed:
                    () async {

                  setState(() {
                    metaBolsa =
                        double.tryParse(
                              metaController.text,
                            ) ??
                            metaBolsa;
                  });

                  await salvarDados();
                },

                child: const Text(
                  'Salvar Planejamento',
                ),
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            SizedBox(
              width:
                  double.infinity,

              child:
                  ElevatedButton(

                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.red,
                ),

                onPressed:
                    resetarPlanejamento,

                child: const Text(
                  'Excluir Planejamento',
                  style: TextStyle(
                    color:
                        Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            ElevatedButton(
              onPressed:
                  selecionarDataInicio,

              child: Text(
                'Data Início: ${dataInicio.day}/${dataInicio.month}/${dataInicio.year}',
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            ElevatedButton(
              onPressed:
                  selecionarDataFim,

              child: Text(
                'Data Final: ${dataFim.day}/${dataFim.month}/${dataFim.year}',
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            infoCard(
              titulo:
                  'Meta da Bolsa',
              valor:
                  'R\$ ${metaBolsa.toStringAsFixed(2)}',
              icone:
                  Icons.flag,
              cor:
                  Colors.green,
            ),

            infoCard(
              titulo:
                  'Total Comprado',
              valor:
                  'R\$ ${totalComprado().toStringAsFixed(2)}',
              icone:
                  Icons.shopping_cart,
              cor:
                  Colors.orange,
            ),

            infoCard(
              titulo:
                  'Quanto Falta',
              valor:
                  'R\$ ${quantoFalta().toStringAsFixed(2)}',
              icone:
                  Icons.trending_up,
              cor:
                  Colors.red,
            ),

            infoCard(
              titulo:
                  'Dias Restantes',
              valor:
                  '${diasRestantes()} dias',
              icone:
                  Icons.calendar_month,
              cor:
                  Colors.blue,
            ),

            infoCard(
              titulo:
                  'Meta Diária',
              valor:
                  'R\$ ${mediaNecessaria().toStringAsFixed(2)}',
              icone:
                  Icons.calculate,
              cor:
                  Colors.purple,
            ),

            const SizedBox(
              height: 20,
            ),

            LinearProgressIndicator(
              value: progresso(),
              minHeight: 14,
            ),

            const SizedBox(
              height: 10,
            ),

            Text(
              '${(progresso() * 100).toStringAsFixed(1)}% concluído',
            ),
          ],
        ),
      ),
    );
  }
}