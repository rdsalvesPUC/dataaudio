import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../repositories/auth_repository.dart';

/// Estado de sessao (RF07). Governa a navegacao condicional: sem login nao ha
/// acesso ao catalogo (RN01). `login`/`register` propagam `AuthException` em
/// falha para a UI localizar a mensagem (ADR-0008).
class AuthProvider extends ChangeNotifier {
  AuthProvider(this._repository);

  final AuthRepository _repository;

  AppUser? _user;
  AppUser? get user => _user;
  bool get isAuthenticated => _user != null;

  bool _restoring = true;
  bool get isRestoring => _restoring;

  /// Recupera a sessao persistida na inicializacao (login que sobrevive ao
  /// fechamento do app).
  Future<void> restoreSession() async {
    _restoring = true;
    notifyListeners();
    try {
      _user = await _repository.currentSession();
    } catch (_) {
      // Sessao persistida invalida/corrompida ou falha de storage: descarta e
      // segue deslogado, em vez de travar o app no spinner (Codex P2).
      _user = null;
    } finally {
      _restoring = false;
      notifyListeners();
    }
  }

  Future<void> login(String username, String password) async {
    _user = await _repository.login(username, password);
    notifyListeners();
  }

  Future<void> register(String username, String password) async {
    _user = await _repository.register(username, password);
    notifyListeners();
  }

  Future<void> logout() async {
    await _repository.logout();
    _user = null;
    notifyListeners();
  }
}
