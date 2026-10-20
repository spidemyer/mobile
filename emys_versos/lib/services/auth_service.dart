import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  static final Future<void> _googleSignInInitialization = _googleSignIn
      .initialize();

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  // Registo com E-mail
  Future<UserCredential> signUpWithEmailAndPassword(
    String email,
    String password,
  ) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Login com E-mail
  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Login com Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      await _googleSignInInitialization;
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleUser.authentication.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
      rethrow;
    }
  }

  // Terminar sessão (Logout)
  Future<void> signOut() async {
    await _googleSignInInitialization;
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
