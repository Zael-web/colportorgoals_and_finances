import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'data/app_data.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await carregarRegistrosGlobais();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(

      debugShowCheckedModeBanner: false,

      title: 'Colportor App',

      theme: ThemeData(
        primarySwatch: Colors.green,
      ),

      home: const HomeScreen(),
    );
  }
}