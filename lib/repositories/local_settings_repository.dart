import 'dart:convert';

import '../models/app_settings.dart';
import '../services/local_storage_service.dart';
import 'settings_repository.dart';

/// Preferencias de tema/idioma em `shared_preferences` (PF01/PF02, RN08),
/// sob a chave `settings` (SDD §6.2).
class LocalSettingsRepository implements SettingsRepository {
  LocalSettingsRepository(this._storage);

  static const String _key = 'settings';

  final LocalStorageService _storage;

  @override
  Future<AppSettings> load() async {
    final raw = _storage.getString(_key);
    if (raw == null) return const AppSettings();
    return AppSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  Future<void> save(AppSettings settings) =>
      _storage.setString(_key, jsonEncode(settings.toJson()));
}
