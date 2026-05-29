import 'package:flutter/material.dart';

import 'registro_screen.dart';
import 'metas_screen.dart';
import 'calculadora_screen.dart';
import 'materiais_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  int paginaAtual = 0;

  final List<Widget> paginas = [
    const DashboardPage(),
    const RegistroScreen(),
    const MetasScreen(),
    const CalculadoraScreen(),
    const MateriaisScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: paginas[paginaAtual],

      bottomNavigationBar: NavigationBar(

        selectedIndex: paginaAtual,

        onDestinationSelected: (index) {
          setState(() {
            paginaAtual = index;
          });
        },

        destinations: const [

          NavigationDestination(
            icon: Icon(Icons.home),
            label: 'Início',
          ),

          NavigationDestination(
            icon: Icon(Icons.edit_note),
            label: 'Registro',
          ),

          NavigationDestination(
            icon: Icon(Icons.flag),
            label: 'Metas',
          ),

          NavigationDestination(
            icon: Icon(Icons.calculate),
            label: 'Calculadora',
          ),

          NavigationDestination(
            icon: Icon(Icons.menu_book),
            label: 'Materiais',
          ),
        ],
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {

    double progresso = 45;

    return Scaffold(

      appBar: AppBar(
        title: const Text('Colportor App'),
      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(16),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            const Text(
              'Bom dia, Colportor 👋',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'Aqui está o resumo da sua campanha.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 24),

            // CARD PROGRESSO
            Container(
              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: Colors.green.shade700,
                borderRadius: BorderRadius.circular(20),
              ),

              child: Column(

                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,

                    children: [

                      Text(
                        'Meta da Bolsa',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),

                      Icon(
                        Icons.emoji_events,
                        color: Colors.white,
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'R\$ 18.000',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 14),

                  LinearProgressIndicator(
                    value: progresso / 100,
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(20),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    '$progresso% concluído',
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Resumo de Hoje',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [

                Expanded(
                  child: dashboardCard(
                    titulo: 'Vendido',
                    valor: 'R\$ 350',
                    cor: Colors.green,
                    icone: Icons.attach_money,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: dashboardCard(
                    titulo: 'Comprado',
                    valor: 'R\$ 220',
                    cor: Colors.orange,
                    icone: Icons.shopping_cart,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [

                Expanded(
                  child: dashboardCard(
                    titulo: 'Livros',
                    valor: '12',
                    cor: Colors.blue,
                    icone: Icons.menu_book,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: dashboardCard(
                    titulo: 'Meta/Dia',
                    valor: 'R\$ 720',
                    cor: Colors.purple,
                    icone: Icons.flag,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            const Text(
              'Últimos Registros',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            registroTile(
              '20/05/2026',
              'R\$ 350',
              '12 livros',
            ),

            registroTile(
              '19/05/2026',
              'R\$ 420',
              '15 livros',
            ),

            registroTile(
              '18/05/2026',
              'R\$ 180',
              '7 livros',
            ),
          ],
        ),
      ),
    );
  }

  Widget dashboardCard({
    required String titulo,
    required String valor,
    required Color cor,
    required IconData icone,
  }) {
    return Container(

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),

        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            color: Colors.black.withOpacity(0.05),
          )
        ],
      ),

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          CircleAvatar(
            backgroundColor: cor,

            child: Icon(
              icone,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 14),

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
    );
  }

  Widget registroTile(
    String data,
    String valor,
    String livros,
  ) {
    return Container(

      margin: const EdgeInsets.only(bottom: 12),

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),

        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            color: Colors.black.withOpacity(0.04),
          )
        ],
      ),

      child: Row(

        mainAxisAlignment: MainAxisAlignment.spaceBetween,

        children: [

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              Text(
                data,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                livros,
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),
            ],
          ),

          Text(
            valor,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}