import 'package:firebase_auth/firebase_auth.dart';

import '../core/error/app_exceptions.dart';
import '../models/app_user.dart';
import 'auth_repository.dart';

/// Autenticacao real com Firebase Auth (bonus RF07). Mesma interface do
/// baseline (ADR-0005/0006): so muda a implementacao. O "username" da UI e
/// tratado como e-mail (requisito do Firebase Auth). Falhas viram
/// `AuthException` para a UI localizar a mensagem (ADR-0008).
class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._auth);

  final FirebaseAuth _auth;

  AppUser? _map(User? user) =>
      user == null ? null : AppUser(id: user.uid, username: user.email ?? user.uid);

  @override
  Future<AppUser?> currentSession() async => _map(_auth.currentUser);

  @override
  Future<AppUser> register(String username, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: username,
        password: password,
      );
      return _map(cred.user)!;
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Falha ao cadastrar', _reason(e.code));
    }
  }

  @override
  Future<AppUser> login(String username, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: username,
        password: password,
      );
      return _map(cred.user)!;
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Credenciais invalidas', _reason(e.code));
    }
  }

  /// Traduz o `code` do Firebase para um motivo acionavel (P2 do review).
  AuthErrorReason _reason(String code) => switch (code) {
        'email-already-in-use' => AuthErrorReason.userExists,
        'invalid-email' => AuthErrorReason.invalidEmail,
        'weak-password' => AuthErrorReason.weakPassword,
        'user-not-found' ||
        'wrong-password' ||
        'invalid-credential' =>
          AuthErrorReason.invalidCredentials,
        'network-request-failed' => AuthErrorReason.network,
        'too-many-requests' => AuthErrorReason.tooManyRequests,
        _ => AuthErrorReason.unknown,
      };

  @override
  Future<void> logout() => _auth.signOut();
}
