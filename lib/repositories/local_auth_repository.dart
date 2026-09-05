import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

import '../core/error/app_exceptions.dart';
import '../models/app_user.dart';
import '../services/local_storage_service.dart';
import 'auth_repository.dart';

/// Login local baseline (SDD §5.3/§6.2): cadastro e sessao guardados em
/// `shared_preferences`. A senha nunca e persistida crua — guarda-se um
/// `salt` aleatorio por usuario e o `SHA-256(salt + senha)`. O bonus troca
/// por Firebase Auth sem tocar nas telas.
class LocalAuthRepository implements AuthRepository {
  LocalAuthRepository(this._storage);

  static const String _usersKey = 'auth_users';
  static const String _sessionKey = 'auth_session';

  final LocalStorageService _storage;

  @override
  Future<AppUser?> currentSession() async {
    final raw = _storage.getString(_sessionKey);
    if (raw == null) return null;
    return AppUser.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  Future<AppUser> register(String username, String password) async {
    final users = _readUsers();
    if (users.any((u) => u['username'] == username)) {
      throw const AuthException('Usuario ja existe');
    }
    final salt = _newSalt();
    users.add({
      'id': username,
      'username': username,
      'salt': salt,
      'hash': _hash(salt, password),
    });
    await _storage.setStringList(
      _usersKey,
      users.map(jsonEncode).toList(),
    );
    final user = AppUser(id: username, username: username);
    await _saveSession(user);
    return user;
  }

  @override
  Future<AppUser> login(String username, String password) async {
    final match = _readUsers().where((u) => u['username'] == username);
    if (match.isEmpty) {
      throw const AuthException('Credenciais invalidas');
    }
    final stored = match.first;
    final ok = stored['hash'] == _hash('${stored['salt']}', password);
    if (!ok) {
      throw const AuthException('Credenciais invalidas');
    }
    final user = AppUser(id: username, username: username);
    await _saveSession(user);
    return user;
  }

  /// Salt aleatorio (16 bytes) em base64.
  String _newSalt() {
    final rnd = Random.secure();
    final bytes = List<int>.generate(16, (_) => rnd.nextInt(256));
    return base64Encode(bytes);
  }

  /// SHA-256 de salt + senha.
  String _hash(String salt, String password) =>
      sha256.convert(utf8.encode('$salt$password')).toString();

  @override
  Future<void> logout() => _storage.remove(_sessionKey);

  List<Map<String, dynamic>> _readUsers() => _storage
      .getStringList(_usersKey)
      .map((s) => jsonDecode(s) as Map<String, dynamic>)
      .toList();

  Future<void> _saveSession(AppUser user) =>
      _storage.setString(_sessionKey, jsonEncode(user.toJson()));
}
