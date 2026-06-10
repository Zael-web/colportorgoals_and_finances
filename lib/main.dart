import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

import 'screens/home_screen.dart';
import 'data/app_data.dart';

const Color _navyStart = Color(0xFF071826);
const Color _navyMid = Color(0xFF0B2A4D);
const Color _navyEnd = Color(0xFF123B68);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Dados locais
  await carregarRegistrosGlobais();
  await carregarMateriaisGlobais();
  await carregarPlanejamento();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Colportor App',
      themeMode: ThemeMode.dark,
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        colorScheme:
            ColorScheme.fromSeed(
              seedColor: _navyEnd,
              brightness: Brightness.dark,
            ).copyWith(
              primary: _navyEnd,
              secondary: const Color(0xFF4DA3FF),
              surface: _navyStart,
            ),
        scaffoldBackgroundColor: Colors.transparent,
        canvasColor: Colors.transparent,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: _navyStart.withValues(alpha: 0.92),
          indicatorColor: _navyEnd,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFF0F2747),
        ),
      ),
      builder: (context, child) {
        return DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_navyStart, _navyMid, _navyEnd],
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const HomeScreen(),
    );
  }
}
