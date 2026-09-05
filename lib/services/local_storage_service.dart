import 'package:shared_preferences/shared_preferences.dart';

/// Wrapper fino sobre [SharedPreferences] (SDD §5.2). Sem regra de negocio —
/// so guarda/le listas de strings por chave. Recebe a instancia por injecao
/// para viabilizar os testes (ADR-0009).
class LocalStorageService {
  LocalStorageService(this._prefs);

  final SharedPreferences _prefs;

  /// Le a lista de strings da [key] (vazia se ausente).
  List<String> getStringList(String key) => _prefs.getStringList(key) ?? const [];

  /// Grava a lista de strings na [key].
  Future<void> setStringList(String key, List<String> values) =>
      _prefs.setStringList(key, values);

  /// Le a string da [key] (`null` se ausente).
  String? getString(String key) => _prefs.getString(key);

  /// Grava a string na [key].
  Future<void> setString(String key, String value) =>
      _prefs.setString(key, value);

  /// Remove a [key].
  Future<void> remove(String key) => _prefs.remove(key);
}
