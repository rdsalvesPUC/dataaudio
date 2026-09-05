import 'package:dataaudio/core/error/app_exceptions.dart';
import 'package:dataaudio/models/app_user.dart';
import 'package:dataaudio/models/track.dart';
import 'package:dataaudio/repositories/auth_repository.dart';
import 'package:dataaudio/repositories/favorites_repository.dart';
import 'package:dataaudio/repositories/listened_repository.dart';

/// Fakes em memoria compartilhados pelos testes de widget/provider — evitam
/// stubbing repetitivo e modelam o comportamento real (async, idempotente).

class FakeFavoritesRepository implements FavoritesRepository {
  FakeFavoritesRepository([List<Track>? initial]) {
    if (initial != null) _items.addAll(initial);
  }
  final List<Track> _items = [];

  @override
  Future<void> add(Track track) async {
    if (!_items.any((t) => t.id == track.id)) _items.add(track);
  }

  @override
  Future<List<Track>> getAll() async => List.of(_items);

  @override
  Future<void> remove(String id) async => _items.removeWhere((t) => t.id == id);
}

class FakeListenedRepository implements ListenedRepository {
  FakeListenedRepository([List<Track>? initial]) {
    if (initial != null) _items.addAll(initial);
  }
  final List<Track> _items = [];

  @override
  Future<void> add(Track track) async {
    if (!_items.any((t) => t.id == track.id)) _items.add(track);
  }

  @override
  Future<List<Track>> getAll() async => List.of(_items);

  @override
  Future<void> remove(String id) async => _items.removeWhere((t) => t.id == id);
}

class FakeAuthRepository implements AuthRepository {
  final Map<String, String> _users = {}; // username -> password
  AppUser? _session;

  @override
  Future<AppUser?> currentSession() async => _session;

  @override
  Future<AppUser> register(String username, String password) async {
    if (_users.containsKey(username)) {
      throw const AuthException('Usuario ja existe');
    }
    _users[username] = password;
    return _session = AppUser(id: username, username: username);
  }

  @override
  Future<AppUser> login(String username, String password) async {
    if (_users[username] != password) {
      throw const AuthException('Credenciais invalidas');
    }
    return _session = AppUser(id: username, username: username);
  }

  @override
  Future<void> logout() async => _session = null;
}
