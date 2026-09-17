import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../data/app_data.dart';

class AuthService {
  FirebaseAuth get _auth => FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  String getNomeUsuarioLogado() {
    final user = currentUser;
    final nome = user?.displayName?.trim();
    if (nome != null && nome.isNotEmpty) {
      return nome;
    }

    final email = user?.email?.trim();
    if (email != null && email.isNotEmpty) {
      return email.split('@').first;
    }

    return 'Colportor';
  }

  Future<UserCredential> cadastrarComEmailSenha({
    required String email,
    required String senha,
  }) async {
    return _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: senha,
    );
  }

  Future<UserCredential> entrarComEmailSenha({
    required String email,
    required String senha,
  }) async {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: senha,
    );
  }

  Future<UserCredential> entrarComGoogle() async {
    final googleAccount = await _googleSignIn.authenticate();
    final googleAuth = googleAccount.authentication;

    final idToken = googleAuth.idToken;

    if (idToken == null) {
      throw FirebaseAuthException(
        code: 'google-sign-in-failed',
        message: 'Não foi possível obter o token de autenticação do Google.',
      );
    }

    final credential = GoogleAuthProvider.credential(
      idToken: idToken,
    );

    return _auth.signInWithCredential(credential);
  }

  Future<void> recuperarSenha({required String email}) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  Future<void> sair() async {
    resetarDadosUsuarioAtual();
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
