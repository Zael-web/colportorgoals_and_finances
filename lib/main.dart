import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  await carregarPlanejamentos();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _modoEscuro = true;
  bool _alternandoTema = false;

  @override
  void initState() {
    super.initState();
    _carregarTema();
  }

  Future<void> _carregarTema() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => _modoEscuro = prefs.getBool('modoEscuro') ?? true);
  }

  Future<void> _alternarTema() async {
    if (_alternandoTema) return;
    _alternandoTema = true;
    final novoModoEscuro = !_modoEscuro;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      setState(() => _modoEscuro = novoModoEscuro);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('modoEscuro', novoModoEscuro);
      if (mounted) _alternandoTema = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Colportor App',
      themeMode: _modoEscuro ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData.light(useMaterial3: true).copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _navyEnd,
          brightness: Brightness.light,
        ).copyWith(primary: _navyEnd, secondary: const Color(0xFF1769AA)),
        scaffoldBackgroundColor: Colors.transparent,
        canvasColor: Colors.transparent,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: _navyStart,
          elevation: 0,
          centerTitle: false,
        ),
        navigationBarTheme: const NavigationBarThemeData(
          backgroundColor: Color(0xFFF3F7FB),
          indicatorColor: Color(0xFFB9D8F2),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFFF3F7FB),
        ),
      ),
      darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
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
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _modoEscuro
                  ? const [_navyStart, _navyMid, _navyEnd]
                  : const [Color(0xFFEAF4FC), Color(0xFFD7EAF8), Colors.white],
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: HomeScreen(modoEscuro: _modoEscuro, onAlternarTema: _alternarTema),
    );
  }
}
