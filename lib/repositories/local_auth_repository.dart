import 'dart:convert';

import '../core/error/app_exceptions.dart';
import '../models/app_user.dart';
import '../services/local_storage_service.dart';
import 'auth_repository.dart';

/// Login local baseline (SDD §5.3/§6.2): cadastro e sessao guardados em
/// `shared_preferences`. As credenciais ficam no dispositivo (adequado ao
/// escopo academico; o bonus troca por Firebase Auth sem tocar nas telas).
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
    users.add({'id': username, 'username': username, 'password': password});
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
    final match = _readUsers().where(
      (u) => u['username'] == username && u['password'] == password,
    );
    if (match.isEmpty) {
      throw const AuthException('Credenciais invalidas');
    }
    final user = AppUser(id: username, username: username);
    await _saveSession(user);
    return user;
  }

  @override
  Future<void> logout() => _storage.remove(_sessionKey);

  List<Map<String, dynamic>> _readUsers() => _storage
      .getStringList(_usersKey)
      .map((s) => jsonDecode(s) as Map<String, dynamic>)
      .toList();

  Future<void> _saveSession(AppUser user) =>
      _storage.setString(_sessionKey, jsonEncode(user.toJson()));
}
