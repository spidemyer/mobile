import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Mantém a tela ciente da sessão Firebase atual.
  User? get currentUser => _auth.currentUser;

  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_messageForCode(e.code));
    }
  }

  String _messageForCode(String code) {
    // A interface recebe mensagens úteis em vez dos códigos internos do Firebase.
    switch (code) {
      case 'invalid-credential':
      case 'user-not-found':
      case 'wrong-password':
        return 'E-mail ou senha inválidos.';
      case 'invalid-email':
        return 'Informe um e-mail válido.';
      case 'too-many-requests':
        return 'Muitas tentativas. Tente novamente mais tarde.';
      default:
        return 'Não foi possível entrar. Verifique sua conexão e tente novamente.';
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
