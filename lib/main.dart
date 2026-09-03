import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/app_data.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';

const Color _navyStart = Color(0xFF071826);
const Color _navyMid = Color(0xFF0B2A4D);
const Color _navyEnd = Color(0xFF123B68);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (kIsWeb) {
    const webClientId = 'SEU_WEB_CLIENT_ID_DO_GOOGLE';
    await GoogleSignIn.instance.initialize(clientId: webClientId);
  } else {
    await GoogleSignIn.instance.initialize();
  }

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
          labelStyle: TextStyle(color: Color(0xFF35607F)),
          floatingLabelStyle: TextStyle(color: _navyEnd),
          prefixIconColor: Color(0xFF35607F),
          suffixIconColor: Color(0xFF35607F),
          iconColor: Color(0xFF35607F),
          hintStyle: TextStyle(color: Color(0xFF5D7182)),
          border: OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFB9CAD8)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: _navyEnd, width: 2),
          ),
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
          labelStyle: TextStyle(color: Colors.white70),
          floatingLabelStyle: TextStyle(color: Color(0xFF8BC7FF)),
          prefixIconColor: Color(0xFFB7D9F7),
          suffixIconColor: Color(0xFFB7D9F7),
          iconColor: Color(0xFFB7D9F7),
          hintStyle: TextStyle(color: Colors.white54),
          border: OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF477092)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF8BC7FF), width: 2),
          ),
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
      home: StreamBuilder<User?>(
        stream: AuthService().authStateChanges(),
        initialData: FirebaseAuth.instance.currentUser,
        builder: (context, snapshot) {
          final usuario = snapshot.data;
          if (usuario == null) {
            return const LoginScreen();
          }

          WidgetsBinding.instance.addPostFrameCallback((_) async {
            await carregarDadosUsuarioAtual();
          });

          return HomeScreen(modoEscuro: _modoEscuro, onAlternarTema: _alternarTema);
        },
      ),
    );
  }
}
